# RISC-V Single-Cycle Processor with Custom XOR Support

This repository contains a 32-bit RISC-V Single-Cycle Processor implemented in SystemVerilog. The architecture is based on the Harris & Harris model, with custom hardware modifications to support the XOR instruction.

---

## Project Overview

The core objective of this project was to extend the base RISC-V ISA by implementing the XOR R-type instruction. This involved modifying both the ALU hardware and the Control Unit decoding logic.

* Architecture: 32-bit RISC-V (RV32I Subset).
* HDL: SystemVerilog.
* Key Addition: Full hardware support for the XOR instruction.
* Verification: Validated using ModelSim/QuestaSim waveforms.

---

## Hardware Modifications

To enable XOR support, two major components were updated within the datapath and control logic:

### 1. ALU (Arithmetic Logic Unit) Expansion

The ALU logic in the alu.sv file was expanded to include the bitwise XOR (^) operation. This custom operation is mapped to the 100 control signal.

```systemverilog
// Updated ALU logic inside alu.sv
always_comb case(ALUControl)
    3'b000: ALUResult = SrcA + SrcB;
    3'b001: ALUResult = SrcA - SrcB;
    3'b010: ALUResult = SrcA & SrcB;
    3'b011: ALUResult = SrcA | SrcB;
    3'b100: ALUResult = SrcA ^ SrcB; // Custom XOR Support Added
    3'b101: ALUResult = (SrcA < SrcB) ? 1 : 0;
    default: ALUResult = 32'bx;
endcase
```

### 2. Control Unit (ALU Decoder)

The aludec module was updated to decode the funct3 field for the XOR instruction. When the processor fetches an R-type instruction with funct3 = 100, it triggers the XOR operation.

| Instruction | Opcode | Funct3 | Funct7 | ALUOp | ALUControl |
| --- | --- | --- | --- | --- | --- |
| XOR | 0110011 | 100 | 0000000 | 10 | 100 |

---

## Simulation and Verification

The design was verified using a hybrid riscvtest.txt dataset. The simulation proves both the correct functionality of the new XOR logic and the overall stability of the original system.

### XOR Logic Proof (at PC 0x08)

At memory address 0x08, the custom XOR instruction 0021C333 (xor x6, x3, x2) is executed:
* Operand A (x3): 0x0C (12)
* Operand B (x2): 0x05 (5)
* ALUResult: 0x09 (9)
* Verification: 12 (1100) XOR 5 (0101) = 9 (1001). Success.

### Final System Pass (at PC 0x50)

The processor executes the entire test suite without disrupting existing logic. It successfully writes the final value 0x19 (25) to memory address 0x64, triggering the Simulation Succeeded status.

---


## Environment and Tools

* Synthesis: Intel Quartus Prime
* Simulation: ModelSim / QuestaSim
* Language: SystemVerilog

---

## References

* Harris, S. L., & Harris, D. (2021). Digital Design and Computer Architecture: RISC-V Edition.
