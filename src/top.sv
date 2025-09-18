`include "uvm_macros.svh"
import uvm_pkg::*;
`include "interface.sv"


module top;
  bit clk;
  always #5 clk = ~clk;
  inf vif(clk);
  initial begin
    uvm_config_db#(virtual inf)::set(null, "*", "vif", vif);
    $finish;
  end
endmodule
