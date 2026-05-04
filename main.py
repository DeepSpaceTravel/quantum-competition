from qiskit import QuantumCircuit, transpile
from qiskit_aer import AerSimulator
from qiskit.circuit.classical import expr
from qiskit.circuit import QuantumRegister, ClassicalRegister, Clbit

def test_qc():
    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)

    qc.cx(0, 1)
    qc.h(0)
    qc.measure([0,1], [0,1])
    print(qc)

    simulator = AerSimulator()
    compiled_circuit = transpile(qc, simulator)
    job = simulator.run(compiled_circuit, shots=1024)
    
    result = job.result()
    
    counts = result.get_counts(compiled_circuit)
    print("\nTotal count for 00 and 11 are:", counts)


def dynamic_qc(qubit_num: int = 5): 
    qubits = QuantumRegister(qubit_num)
    clbits = ClassicalRegister(4)
    qc = QuantumCircuit(qubits, clbits)

    # Inital Bell State
    qc.h(0)
    qc.cx(0, 1)

    # Main circuit
    for qubit in range(2, qubit_num):
        qc.h(qubit)
    for qubit in range(1, qubit_num-1):
        qc.cz(qubit, qubit+1)

    for qubit in range(qubit_num):
        if qubit> 0 and qubit < qubit_num-1:
            # Measure in X-basis
            qc.h(qubit)
            if qubit % 2 == 0:
                qc.measure(qubit, qc.clbits[0])
                
                qc.h(qubit_num-1)
                with qc.if_test(expr.bit_xor(qc.clbits[0], qc.clbits[2])) as else_:
                    qc.z(qubit_num-1)
                qc.measure(qubit, 2)
            else: 
                # 1, 3, 5... bits
                qc.measure(qubit, qc.clbits[1])

                qc.h(qubit_num-1)
                with qc.if_test(expr.bit_xor(qc.clbits[1], qc.clbits[3])):
                    qc.x(qubit_num-1)
                qc.measure(qubit, 3)

    # Final Measurement
    # Revert to original bell state
    qc.cx(0, qubit_num-1)
    qc.h(0)
    qc.measure(0, 0)
    qc.measure(qubit_num-1, 1)


    print(qc)

    simulator = AerSimulator()

    compiled_circuit = transpile(qc, simulator)
    
    job = simulator.run(compiled_circuit, shots=1024)
    result = job.result()
    
    counts = result.get_counts(compiled_circuit)
    zz = 0
    zo = 0
    oz = 0
    oo = 0
    for bitstring, count in counts.items():
        if bitstring.endswith("00"):
            zz += count
        elif bitstring.endswith("01"):
            zo += count
        elif bitstring.endswith("10"):
            oz += count
        else: 
            oo += count
    results_dict = {
        "00": zz,
        "01": zo,
        "10": oz,
        "11": oo
    }

    print(results_dict)
    print(zz, zo, oz, oo)
    

def main():
    print("Hello from quantum-competition!")


if __name__ == "__main__":
    main()
    dynamic_qc()
    # test_qc()
    
