import uvm_pkg::*;
class apb_sequence_item extends uvm_sequence_item;
  //inputs
  rand bit [7:0] apb_write_data;
  rand bit transfer;
  rand bit READ_WRITE;
  rand bit PRESETn;
  rand bit [8:0] apb_read_paddr;
  rand bit [8:0] apb_write_paddr;
  //outputs
  bit [7:0] apb_read_data_out;
  bit PSLVERR;

  bit change;
  
  `uvm_object_utils_begin(apb_sequence_item)
  `uvm_field_int(apb_write_data, UVM_ALL_ON)
  `uvm_field_int(READ_WRITE, UVM_ALL_ON)
  `uvm_field_int(transfer, UVM_ALL_ON)
  `uvm_field_int(PRESETn, UVM_ALL_ON)
  `uvm_field_int(apb_read_paddr, UVM_ALL_ON)
  `uvm_field_int(apb_write_paddr, UVM_ALL_ON)
  `uvm_field_int(apb_read_data_out, UVM_ALL_ON)
  `uvm_field_int(PSLVERR, UVM_ALL_ON)
  `uvm_object_utils_end
  
endclass
