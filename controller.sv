module controller(
    input  logic [6:0] op, 
    input  logic [2:0] funct3, 
    input  logic       funct7_5, 
    input  logic       Zero, 
    output logic       PCSrc, 
    output logic [1:0] ResultSrc, 
    output logic       MemWrite, 
    output logic [2:0] ALUControl, 
    output logic       ALUSrc, 
    output logic [1:0] ImmSrc, 
    output logic       RegWrite
);
  logic [1:0] ALUOp;
  logic Branch, Jump;
  maindec md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7_5, ALUOp, ALUControl);
  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(
    input  logic [6:0] op, 
    output logic [1:0] ResultSrc, 
    output logic       MemWrite, 
    output logic       Branch, 
    output logic       ALUSrc, 
    output logic       RegWrite, 
    output logic       Jump, 
    output logic [1:0] ImmSrc, 
    output logic [1:0] ALUOp
);
  logic [10:0] controls;
  assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
  always_comb case(op)
    7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
    7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
    7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
    7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
    7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
    7'b1101111: controls = 11'b1_11_x_0_10_0_xx_1; // jal
    default:    controls = 11'bx_xx_x_x_xx_x_xx_x;
  endcase
endmodule

module aludec(
    input  logic       opb5, 
    input  logic [2:0] funct3, 
    input  logic       funct7b5, 
    input  logic [1:0] ALUOp, 
    output logic [2:0] ALUControl
);
  logic RtypeSub;
  assign RtypeSub = funct7b5 & opb5; 
  always_comb case(ALUOp)
    2'b00: ALUControl = 3'b000; // add
    2'b01: ALUControl = 3'b001; // sub
    default: case(funct3)
               3'b000: if (RtypeSub) ALUControl = 3'b001; else ALUControl = 3'b000;
					3'b100: ALUControl = 3'b100; //XOR
               3'b010: ALUControl = 3'b101; // slt
               3'b110: ALUControl = 3'b011; // or
               3'b111: ALUControl = 3'b010; // and
               default: ALUControl = 3'bxxx;
             endcase
  endcase
endmodule