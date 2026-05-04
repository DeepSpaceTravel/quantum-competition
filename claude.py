from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
from qiskit.circuit.classical import expr
from qiskit_aer.noise import NoiseModel, depolarizing_error

def build_xor(clbits_list, indices):
    """XOR of selected classical bits. Returns Clbit or expr."""
    if not indices:
        return None
    bits = [clbits_list[i] for i in indices]
    if len(bits) == 1:
        return bits[0]
    result = expr.bit_xor(bits[0], bits[1])
    for b in bits[2:]:
        result = expr.bit_xor(result, b)
    return result

def if_nonzero(qc, condition, gate_fn):
    """if_test that handles both single Clbit and expr."""
    if isinstance(condition, expr.Expr):
        with qc.if_test(condition):
            gate_fn()
    else:
        with qc.if_test((condition, 1)):
            gate_fn()

def teleport(n: int):
    """
    Teleport qubit 1 of Bell state (q0,q1) to q(n-1).
    Measures q0 and q(n-1): should be |00>.
    """
    qc = QuantumCircuit(n, n)

    # 1. Bell state on q0, q1
    qc.h(0)
    qc.cx(0, 1)

    # 2. Path graph state: H on q2..q(n-1), CZ along chain
    for q in range(2, n):
        qc.h(q)
    for q in range(1, n - 1):
        qc.cz(q, q + 1)

    # 3. Measure intermediate qubits in X basis
    #    Measurement i (1-indexed) stored in clbit[i-1]
    for i, q in enumerate(range(1, n - 1), start=1):
        qc.h(q)
        qc.measure(q, i - 1)

    # 4. Correction on q(n-1)
    #    Odd measurements  (s1,s3,...) → clbits[0,2,4,...] → controls Z
    #    Even measurements (s2,s4,...) → clbits[1,3,5,...] → controls X
    num_meas = n - 2
    odd_indices  = list(range(0, num_meas, 2))   # [0, 2, 4, ...]
    even_indices = list(range(1, num_meas, 2))   # [1, 3, 5, ...]

    xor_odd  = build_xor(qc.clbits, odd_indices)
    xor_even = build_xor(qc.clbits, even_indices)

    if num_meas % 2 == 1:
        # Odd total measurements: transform ends with H, so apply H first
        qc.h(n - 1)
        if_nonzero(qc, xor_odd,  lambda: qc.z(n - 1))
        if xor_even:
            if_nonzero(qc, xor_even, lambda: qc.x(n - 1))
    else:
        # Even total measurements: no H, apply X then Z
        if xor_even:
            if_nonzero(qc, xor_even, lambda: qc.x(n - 1))
        if_nonzero(qc, xor_odd, lambda: qc.z(n - 1))

    # 5. Verify: undo Bell state → should get |00>
    qc.cx(0, n - 1)
    qc.h(0)
    print(qc)
    qc.measure(0,     num_meas)
    qc.measure(n - 1, num_meas + 1)

    # Noisy Simulator Setup
    noise_model = NoiseModel()
    error_1 = depolarizing_error(0.1, 1)
    error_2 = depolarizing_error(0.02, 2)
    noise_model.add_all_qubit_quantum_error(error_1, ['h', 'z', 'x'])
    noise_model.add_all_qubit_quantum_error(error_2, ['cx', 'cz'])

    # Uncomment for Noisy Model
    # noisy_sim = AerSimulator(noise_model=noise_model)
    # t_qc = transpile(qc, noisy_sim)
    # counts = noisy_sim.run(t_qc, shots=4096).result().get_counts()
    
    # Uncomment for Ideal Model
    # ideal_sim = AerSimulator()
    # t_qc = transpile(qc, ideal_sim)
    # counts = ideal_sim.run(t_qc, shots=4096).result().get_counts()
    
    # Check the last two bits (indices num_meas and num_meas+1)
    # In Qiskit bitstring order, these are the first two characters from the right
    good = sum(v for k, v in counts.items() if k[-(num_meas+1)] == '0' and k[-(num_meas+2)] == '0')
    print(f"n={n:2d}: |00> success rate = {good/4096:.1%}")
    return counts

if __name__ == "__main__":
    for n in range(3, 7):
        teleport(n)