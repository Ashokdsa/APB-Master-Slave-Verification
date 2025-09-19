`include "uvm_macros.svh"
import uvm_pkg::*;
`include "interface.sv"
`include"apb_pkg.svh"


module top;
  bit clk;

  always #5 clk = ~clk;
  inf vif(clk);
  apb_test test;
  initial begin
    uvm_config_db#(virtual inf)::set(null, "*", "vif", vif);
    $dumpfile("wave.vcd");
    $dumpvars(0);
  end

  initial begin
    vif.PRESETn = 0;
    @(posedge clk);
    vif.PRESETn = 1;
    @(posedge clk);
  end

  initial begin
    run_test("apb_test");
    $finish;
  end
endmodule
