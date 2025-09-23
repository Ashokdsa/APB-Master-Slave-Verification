// Top-level module for APB UVM testbench

`include "apb_interface.sv"
`include "apb_pkg.svh"
import uvm_pkg::*;
import apb_pkg::*;
`include "/fetools/work_area/frontend/Batch_10/APB_project/apbtop.v"

module top;
  bit clk;

  // Clock generation : 10ns period 
  always #5 clk = ~clk;      

  // Interface instantiation
  apb_inf vif(clk);     

  // DUT instantiation
  APB_Protocol DUT(.PCLK(clk),.PRESETn(vif.PRESETn),.transfer(vif.transfer),.READ_WRITE(vif.READ_WRITE),.apb_write_paddr(vif.apb_write_paddr),.apb_write_data(vif.apb_write_data),.apb_read_paddr(vif.apb_read_paddr),.PSLVERR(vif.PSLVERR),.apb_read_data_out(vif.apb_read_data_out));
  
  apb_test test;
  event act_e,pass_e;    // Event handles for synchronization
  bit change;
  
  initial begin:setting_vif
    // UVM Configurations setting
    uvm_config_db#(virtual apb_inf)::set(null, "*", "vif", vif);
    uvm_config_db#(event)::set(null, "*", "ev1", act_e);
    uvm_config_db#(event)::set(null, "*", "ev2", pass_e);
    
    $dumpfile("wave.vcd");
    $dumpvars(0);
  end:setting_vif

  initial begin:initial_reset
    vif.PRESETn = 0;
    repeat(2)@(posedge clk);
  end:initial_reset

  initial begin:test_run
    run_test("apb_test");      // Start UVM test
    $finish;
  end:test_run

endmodule:top
