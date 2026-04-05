module testbench();
  logic clk;
  logic reset;
  
  riscv_single_cycle dut(clk, reset);

  initial begin
    reset <= 1; # 22; reset <= 0;
  end
  
  always begin
    clk <= 1; # 5; clk <= 0; # 5;
  end
endmodule