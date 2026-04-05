module riscv_single_cycle (
    input  logic        clk,
    input  logic        reset
);

// --- Wire Declarations (Matching the diagram) --
logic [31:0] PC, PCNext, PCPlus4, PCTarget;
logic [31:0] Instr;
logic [31:0] Result;
logic [31:0] SrcA, SrcB, WriteData;
logic [31:0] ImmExt;
logic [31:0] DataAdr;
logic [31:0] ALUResult, ReadData;
logic        Zero;

// --- Control Signals --
logic        PCSrc;
logic [1:0]  ResultSrc;
logic        MemWrite;
logic [2:0]  ALUControl;
logic        ALUSrc;
logic [1:0]  ImmSrc;
logic        RegWrite;

// --- Program Counter (PC) Register --
always_ff @(posedge clk, posedge reset) begin
    if (reset) PC <= 32'b0;
    else       PC <= PCNext;
end

// --- PC Adders --
assign PCPlus4  = PC + 32'd4;
assign PCTarget = PC + ImmExt;

// PC Multiplexer
assign PCNext = PCSrc ? PCTarget : PCPlus4;

// --- Instruction Memory --
// Note: Single-cycle requires asynchronous read memory
imem instruction_memory (
    .A(PC),
    .RD(Instr)
);

// --- Register File --
regfile registers (
    .clk(clk),
    .WE3(RegWrite),
    .A1(Instr[19:15]),
    .A2(Instr[24:20]),
    .A3(Instr[11:7]),
    .WD3(Result),
    .RD1(SrcA),
    .RD2(WriteData) // This also goes to Data Memory WD
);

// --- Sign Extension Unit --
extend sign_extender (
    .Instr(Instr[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
);

// --- ALU and SrcB Multiplexer --
assign SrcB = ALUSrc ? ImmExt : WriteData;

alu main_alu (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);
assign DataAdr = ALUResult;
// --- Data Memory --
// Note: Single-cycle requires asynchronous read memory
dmem data_memory (
    .clk(clk),
    .WE(MemWrite),
    .A(DataAdr),
    .WD(WriteData),
    .RD(ReadData)
);

// --- Result Multiplexer (3-to-1) --
always_comb begin
    case (ResultSrc)
        2'b00: Result = ALUResult;
        2'b01: Result = ReadData;
        2'b10: Result = PCPlus4;
        default: Result = 32'bx;
    endcase
end

// --- Control Unit --
controller ctrl_unit (
    .op(Instr[6:0]),
    .funct3(Instr[14:12]),
    .funct7_5(Instr[30]),
    .Zero(Zero),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite)
);

endmodule


module imem(
    input  logic [31:0] A,
    output logic [31:0] RD
);

// Create an array of 64 words, each 32 bits wide
logic [31:0] RAM [63:0];

// Load a program into the memory when simulation starts
initial begin
    $readmemh("C:/Users/HP/Desktop/4thSpring/FPGA/Labs/2/pre/riscvtestxor.txt", RAM);
end

// Asynchronous Read: Output updates instantly when Address (A) changes
assign RD = RAM[A[31:2]]; // This is the hardware equivalent of A >> 2

endmodule


module dmem (
    input  logic        clk,
    input  logic        WE,
    input  logic [31:0] A,
    input  logic [31:0] WD,
    output logic [31:0] RD
);

// Create an array of 64 words, each 32 bits wide
logic [31:0] RAM [63:0];

// Synchronous Write: Only write data on the rising edge of the clock
always_ff @(posedge clk) begin
    if (WE) begin
        RAM[A[31:2]] <= WD;
    end
end

// Asynchronous Read: Output updates instantly when Address (A) changes
assign RD = RAM[A[31:2]]; // This is the hardware equivalent of A >> 2

endmodule