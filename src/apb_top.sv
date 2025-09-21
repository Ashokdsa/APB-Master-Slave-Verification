`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_pkg.svh"
import apb_pkg::*;
`include "apb_interface.sv"
`include "/fetools/work_area/frontend/Batch_10/APB_project/apbtop.v"

module top;
  bit clk;

  always #5 clk = ~clk;

  apb_inf vif(clk);

  APB_Protocol DUT(.PCLK(clk),.PRESETn(vif.PRESETn),.transfer(vif.transfer),.READ_WRITE(vif.READ_WRITE),.apb_write_paddr(vif.apb_write_paddr),.apb_write_data(vif.apb_write_data),.apb_read_paddr(vif.apb_read_paddr),.PSLVERR(vif.PSLVERR),.apb_read_data_out(vif.apb_read_data_out));
  
  apb_test test;
  event act_e,pass_e;
  bit change;
  
  initial begin
    uvm_config_db#(virtual apb_inf)::set(null, "*", "vif", vif);
    uvm_config_db#(event)::set(null, "*", "ev1", act_e);
    uvm_config_db#(event)::set(null, "*", "ev2", pass_e);
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
