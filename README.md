# AMBA APB Bus – RTL Design & UVM Verification

A complete implementation of the **AMBA Advanced Peripheral Bus (APB)** protocol in **Verilog**, accompanied by a **UVM-based verification environment** featuring constrained-random verification, assertions, functional coverage, and a scoreboard.

---

## Overview

This project implements a complete APB subsystem consisting of:

- APB Master
- Address Decoder
- Response Multiplexer
- Four APB Slaves
- Register-based Memory
- UVM Verification Environment

The verification environment was developed following industry-standard UVM methodology to validate protocol compliance, functional correctness, and corner-case behavior.

---

# Architecture

<p align="center">
  <img src="docs/images/Design_Explaination.png" width="900"/>
</p>

> Replace the image above with your architecture diagram.

---

# Features

## RTL Design

- APB Master implementing the APB protocol
- Four APB Slave peripherals
- Address Decoder
- Response Multiplexer
- Register File implementation
- Wait-state support using **PREADY**
- Error response generation using **PSLVERR**
- Byte write support (**PSTRB**)
- Protection attributes (**PPROT**)

---

## Verification Environment

The verification environment includes:

- UVM Test
- UVM Environment
- UVM Agent
- Sequencer
- Driver
- Monitor
- Scoreboard
- Functional Coverage Collector
- Assertions (SVA)

---

# Verification Features

The following scenarios are verified:

- Reset behavior
- Single Write Transaction
- Single Read Transaction
- Back-to-Back Transfers
- Random Read/Write Transactions
- Invalid Address Access
- Wait-State Handling
- Error Response (PSLVERR)
- Address Decoder Operation
- Multiplexer Response Selection
- Register Read/Write Functionality
- APB Handshake Timing

---

# Functional Coverage

Coverage is collected for:

- Read vs Write operations
- All APB Slaves
- Valid addresses
- Invalid addresses
- Byte enable combinations
- Protection attribute combinations
- Wait-state scenarios
- Error responses
- Reset events
- Transaction type × Slave selection
- Transaction type × Error response
- Slave × Wait-state cross coverage

---

# Assertions

SystemVerilog Assertions are used to verify protocol correctness, including:

- Reset clears outputs
- SETUP phase behavior
- ACCESS phase behavior
- Transaction completion
- PSEL assertion
- PENABLE timing
- Read transaction protocol
- Write transaction protocol
- Wait-state handling
- Invalid address response
- Decoder correctness
- Signal stability during ACCESS

---

# APB Address Map

| Slave | Address Range |
|--------|---------------|
| Slave 0 | 0x0000 – 0x0FFF |
| Slave 1 | 0x1000 – 0x1FFF |
| Slave 2 | 0x2000 – 0x2FFF |
| Slave 3 | 0x3000 – 0x3FFF |

---

# Project Structure

```
APB_Bus/
│
├── rtl/
│   ├── apb_master.sv
│   ├── apb_slave.sv
│   ├── apb_decoder.sv
│   ├── apb_mux.sv
│   └── apb_top.sv
│
│

│
├── verification/
│   ├── sequence_item/
│   ├── sequences/
│   ├── driver/
│   ├── monitor/
│   ├── sequencer/
│   ├── agent/
│   ├── environment/
│   ├── scoreboard/
│   ├── coverage/
│   ├── interface/
│   ├── top/
│   └── tests/
│
├── simulation/
│   ├── src_files.list
│   └── run.do
│
└── docs/
    ├── images
          └──  Design_Explaination.list
    └── Verification_Plan.pdf
```

---

# Simulation

Compile the design and UVM environment:

```tcl
vlib work
vlog -f src_files.list
vsim top
run -all
```

Or simply execute:

```tcl
do run.do
```

---

# Verification Flow

```
Sequence
    │
    ▼
Sequencer
    │
    ▼
Driver
    │
    ▼
APB Interface
    │
    ▼
DUT
    │
    ▼
Monitor
    │
    ├────────────► Functional Coverage
    │
    └────────────► Scoreboard
```

---

# Tools & Technologies

- Verilog HDL
- SystemVerilog
- Universal Verification Methodology (UVM 1.2)
- SystemVerilog Assertions (SVA)
- Functional Coverage
- QuestaSim

---

# Future Improvements

- UVM Register Abstraction Layer (RAL)
- APB-to-AHB Bridge
- Parameterized Number of Slaves
- Random Wait-State Generator
- Continuous Integration (GitHub Actions)
- Coverage-Driven Verification

---

# Results

✔ Complete RTL implementation

✔ UVM Verification Environment

✔ Functional Coverage

✔ SystemVerilog Assertions

✔ Directed Tests

✔ Constrained-Random Verification

✔ Scoreboard-Based Checking

✔ Protocol Compliance Verification

---

# Author

**Abdelrahman Emad**

Digital Verification Engineer

- LinkedIn: *(www.linkedin.com/in/abdelrahmandakroury)*
- GitHub: *(https://github.com/dakrory2011)*

---

## License

This project is intended for educational and portfolio purposes.
