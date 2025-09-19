`include "uvm_macros.svh"
import uvm_pkg::*;
`include "interface.sv"
`include"apb_pkg.svh"
`include "/fetools/work_area/frontend/Batch_10/APB_project/apbtop.v"

module top;
  import apb_pkg::*;
  bit clk;

  always #5 clk = ~clk;

  inf vif(clk);

  APB_Protocol(.PCLK(clk),PRESETn,transfer,READ_WRITE,apb_write_paddr,apb_write_data,apb_read_paddr,PSLVERR,apb_read_data_out);
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
