#import "@preview/charged-ieee:0.1.4": ieee
#import "@preview/quill:0.7.2": *
#import "@preview/physica:0.9.3": *
#set text(size: 11pt, lang: "zh")
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))

#show: ieee.with(
  title: [2026 電物競賽：量子電路的超距作用\
  遠距貝爾態製備設計報告],
  authors: (
    (
      name: "PIN-JIE WANG",
      department: [College of Science],
      organization: [NCCU],
      location: [Taipei, Taiwan],
      email: "111208064@g.nccu.edu.tw"
    ),
    (
      name: "HSUAN-TSE CHEN",
      department: [BA],
      organization: [NCCU],
      location: [Taipei, Taiwan],
      email: "tsechen0927@gmail.com"
    ),
  ),
  index-terms: ("Quantum Computing", "Competition"),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= 摘要
本計畫針對雙腳梯子狀量子處理器，設計一個具橫向可擴充性的量子電路，目標使距離為 $L$ 的兩端量子位元 $e_0$ 與 $e_l$ 達到最大量子糾纏。

本設計主要採用「Path Graph State Teleportation」技術：在 $q_0$ 與 $q_1$ 建立初始貝爾態，接著透過量子閘建立量子通道，再對中繼位元進行測量，並依測量結果即時施加前饋修正，將糾纏態傳遞至末端位元 $e_l$。

驗證方面透過密度矩陣計算保真度（Fidelity），衡量輸出態與理想貝爾態 $ket(Phi^+)$ 的接近程度；結果顯示在 multi-hop 情境下，Dynamic Circuit 的保真度明顯優於 SWAP 鏈方法。

= 問題摘要
本計畫旨在雙腳梯子狀（Double-legged ladder）佈局的量子處理器（QPU）上，設計一個具備橫向可擴充性的量子電路。目標是使位於梯子單腳兩端、物理距離為 $L$ 的量子位元 $e_0$ 與 $e_l$ 處於最大量子糾纏態（Bell State）。

= 量子電路設計架構
本設計不採用傳統的高成本 SWAP 鏈，而是利用「路徑圖態遠距傳輸（Path Graph State Teleportation）」技術。

- *初始糾纏建立*：於 $q_0 (e_0)$ 與 $q_1$ 施加 Hadamard 閘與 CNOT 閘，建立初始貝爾態 $ket(Phi^+ ) = 1/sqrt(2) (ket(00) + ket(11))$ 
- *量子通道製備*：將中繼位元 $q_2$ 至 $q_(n-1) (e_l)$ 初始化於 $ket(+ )$ 態，並施加相鄰 CZ 閘形成路徑圖態鏈結。
- *動態測量與前饋（Feed-forward）*：對中間位元進行 $X$ 基底測量。根據測量結果的 XOR 組合，即時對末端位元 $e_l$ 施加修正算子。
- *反推貝爾態*：測量與修正結束後，針對目標qubits做逆向解耦，施加CNOT與H閘，得出 $ket(00)$ 結果，逆推得知 $e_0$ 與 $e_1$ 處於 $ket(+ )$ 態。

= 數學推導
假設我們要在位元 $j$ 與 $j+1$ 之間傳遞糾纏，施加 CZ 閘後進行 $X$ 基底測量（結果為 $s_j in {0, 1}$）。
根據量子電路恆等式，這等同於將狀態推移並附帶一個隨機的 Pauli 修正。

對於長度為 $L$ 的鏈，其修正邏輯如下：
- *相位修正（Z-correction）*：受奇數索引位元測量結果之異或和（XOR sum）控制。
- *翻轉修正（X-correction）*：受偶數索引位元測量結果之異或和控制。
- *基底變換*：若測量總數為奇數，末端位元需額外施加一個 $H$ 閘以轉回運算基底。

最後，我們必須將下面四種Bell State轉回在Z-axis上具有明確定義的量子態，我們利用的方式是先套用CNOT，其Control 為沒有傳送的Qubit，Target為預期傳送的目的地Qubit，再套用Hadamard 閘於Control上，再進行測量。其四種Bell State映射於Z-Basis的推導如下：

The four Bell states for a 2 qubit system are:
$ ket(Phi^+) = 1/sqrt(2) (ket(00) + ket(11)) $
$ ket(Phi^-) = 1/sqrt(2) (ket(00) - ket(11)) $
$ ket(Psi^+) = 1/sqrt(2) (ket(01) + ket(10)) $
$ ket(Psi^-) = 1/sqrt(2) (ket(01) - ket(10)) $

Applying CNOT to each of the four states: 
$ "CNOT"_01 ket(Phi^+) = 1/sqrt(2) (ket(00) + ket(10)) $
$ "CNOT"_01 ket(Psi^-) = 1/sqrt(2) (ket(01) + ket(11)) $
$ "CNOT"_01 ket(Phi^+) = 1/sqrt(2) (ket(00) - ket(10)) $
$ "CNOT"_01 ket(Psi^-) = 1/sqrt(2) (ket(01) - ket(11)) $

Applying H onto the first qubit: \
$ hat(H)_0 "CNOT"_01  ket(Phi^+) = \
1/sqrt(2) (1/sqrt(2)(ket(0)+ket(1))+1/sqrt(2)(ket(0)-ket(1))) ket(0) \
= ket(00) $\
$ hat(H)_0 "CNOT"_01  ket(Phi^-) = \
1/sqrt(2) (1/sqrt(2)(ket(0)+ket(1))+1/sqrt(2)(ket(0)-ket(1))) ket(1) \
= ket(01) $
$ hat(H)_0 "CNOT"_01  ket(Psi^+) = \
1/sqrt(2) (1/sqrt(2)(ket(0)+ket(1))-1/sqrt(2)(ket(0)-ket(1))) ket(0) \
= ket(10) $
$ hat(H)_0 "CNOT"_01  ket(Psi^+) = \
1/sqrt(2) (1/sqrt(2)(ket(0)+ket(1))-1/sqrt(2)(ket(0)-ket(1))) ket(1) \
= ket(11) $
透過上述可得知，我們可以將四種Bell State，以one-to-one的形式映射至Z-Basis上，以利測量。

= 驗證方法與結果
本程式透過以下兩種方式驗證電路正確性

- *保真度分析（State Fidelity）*：透過使用 compute_bell_fidelity 函式，計算產生的態與理想貝爾態 $ket(Phi^+)$ 的間的重疊度。在無雜訊模擬下，Dynamic cicuit與SWAP兩種方法保真度皆達到 $1.0$。
  因此，在實作過程中我們加入noise medel，比較採用dynamic circuit與單純使用SWAP方式的Fidelity差異。由程式碼最終結果可以清楚看出，在經過幾次Hop後，SWAP法的Fidelity相較於Dynamic circuit低許多。
- *逆向解耦驗證（Inverse Bell Test）*：在電路末端對 $(e_0, e_l)$ 施加逆向貝爾測量電路（CNOT + H）。若傳送成功，測量結果理論上應恆為 $ket(00)$，意味成功產生理想貝爾態$ket(Phi^+)$。(詳見上述數學推導)
- *雜訊模擬*：程式中加入了去極化雜訊模型（Depolarizing error），模擬真實 QPU 環境下的成功率衰減情形。我們的實作中，雜訊來源為0.01的相位偏移；在程式碼中的 noisy_sim 即代表使用 Qiskit Aer 模擬器模擬真實硬體中的噪聲環境。

 
= 可擴充性說明
本電路設計具備高度靈活性：
1. *結構通用化*：核心邏輯使用迴圈生成，不論長度 $L$ 為多少，其前饋修正邏輯均能自動適應。在程式碼中，我們建立通用函式 build_dynamic_circuit ，包含 qc.measure 與 qc.if_test 的動態傳送電路。基於這個電路與其他函式(包含build_noisy_model、build_xor)，我們僅須改變量子數即可運行數次Hop。
 
// 2. *佈局適應性*：雖使用雙腳梯子佈局，但本算法僅需單側腳位即可完成，另一側可用於其他併行運算或作為備援路徑。

= 研究過程與 AI 工具使用聲明
依據競賽規則：
- *學習過程*：研究了基於測量的量子計算（MBQC）與遠距傳輸原理，優化了對相鄰雙位元閘的依賴。此部分主要參考幾篇相關論文，並以論文內提供之想法為基礎，將其擴充成量子電路，同時參考網路文獻，學習程式碼的撰寫。
- *AI 使用範圍*：使用 Claude 輔助，協助dynamic circuit的 XOR 動態測量與前饋機制程式碼撰寫。
- *參考資料*：Qiskit 官方文件、量子傳輸相關論文、網路文獻。@kang2024teleporting

= 研究過程程式使用套件
- 程式碼主要基於Python提供之Qiskit套件進行撰寫。

