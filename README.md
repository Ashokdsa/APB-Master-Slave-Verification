# APB-Master-Slave-Verification
This contains the UVM testbench and documention for basic Verification of APB master and slave
<img width="5797" height="2744" alt="APB_DRAWING_MAINwith_bg" src="https://github.com/user-attachments/assets/f2bf52b6-efbb-4a48-8443-2a52a3af7d91" />

---
## Overview
This repository contains a simple UVM testbench for verifying the APB Master to Slave. The verification environment includes UVM components such as environment, driver, monitor, scoreboard, and test sequences. A Makefile is provided to compile, simulate, and clean the verification runs.

## Testbench Components
- **`apb_top.sv`**: Instantiates DUT and ties together the testbench.
- **`apb_test.sv`**: Instantiates and initializes the testbench components.
- **`apb_environment.sv`**: UVM environment coordinating verification agents.
- **`apb_driver.sv`**: Stimulus driver for DUT interface.
- **`apb_sequencer.sv`**: Contains a FIFO and handles the syncronzation between `apb_driver` and `apb_sequence`.
- **`apb_active_monitor.sv`**: Used to capture transactions.
- **`apb_passive_monitor.sv`**: Observes DUT signals.
- **`apb_active_agent.sv`**: Instantiates `apb_driver`, `apb_sequencer` and `apb_active_monitor`, and connects apb_sequencer and apb_driver.
- **`apb_passive_agent.sv`**: Instantiates the `apb_passive_monitor`.
- **`apb_scoreboard.sv`**: Checks correctness against expected behavior.
- **`apb_sequence.sv`**: Test scenarios driving the driver.
- **`apb_sequence_item.sv`**: Used to communicate between the testbench components.
- **`apb_interface.sv`**: Bundles together a set of signals and associated behaviors to simplify the connection and communication between modules.

## Repository Structure
├── docs # Test Plans and documentation \
├── src # Testbench source files (UVM components) \
│   ├── apb_active_agent.sv  \
│   ├── apb_passive_monitor.sv  \
│   ├── apb_subscriber.sv \
│   ├── apb_active_monitor.sv  \
│   ├── apb_pkg.svh             
│   ├── apb_test.sv \
│   ├── apb_driver.sv        
│   ├── apb_scoreboard.sv       
│   ├── apb_top.sv \
│   ├── apb_environment.sv    
│   ├── apb_sequence.sv         
│   ├── makefile \
│   ├── apb_interface.sv       
│   ├── apb_sequence_item.sv \
│   ├── apb_passive_agent.sv  \
│   └── apb_sequencer.sv \
└── README.md # Current File

## Running the Testbench
### Pre-Requisites
A **SystemVerilog simulator** that supports **UVM**, such as **QuestaSim**, **Cadence Xcelium**, or **Synopsys VCS**. \
\
*The makefile present in the **src/** contains only the execution commands for QuestaSim version 10.6c*

## Makefile Usage
The **Makefile** automates the compilation, and simulation of the **UVM** testbench. Which can be accessed only in the **src/** folder
1. To run the simulation with **UVM_DEBUG** Verbosity and with **apb_regress_test**.
  ```
  make
  ```
2. To run the simulation with **SPECIFIC** Verbosity and with **other test cases**.
  ```
  make TEST=<test_name> V=<required_verbosity>
  ```
  Example:
  `make TEST=apb_write_read_test V=UVM_MEDIUM` \
  \
3. To **clean up** log files, waveforms and cover report generated
  ```
  make clean
  ```
To simulate it **manually**
  ```
  source <Questa_location>
  vlog -sv +acc +cover +fcover -l apb.log apb_top.sv
  vsim -novopt work.top
  ```

Modify the Makefile as necessary for your simulator setup.
