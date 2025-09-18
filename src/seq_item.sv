class seq_item extends uvm_sequence_item;
  //inputs
  rand bit [7:0] PWDATA;
  rand bit TRANSFER;
  rand bit READ_WRITE;
  rand bit PRESETN;
  rand bit [8:0] PRADDR;
  rand bit [8:0] PWADDR;
  //outputs
  bit [7:0] DATA_OUT;
  bit SLVERR;
  
  `uvm_object_utils_begin
  `uvm_field_int(PWDATA, UVM_ALL_ON)
  `uvm_field_int(READ_WRITE, UVM_ALL_ON)
  `uvm_field_int(TRANSFER, UVM_ALL_ON)
  `uvm_field_int(PRESETN, UVM_ALL_ON)
  `uvm_field_int(PRADDR, UVM_ALL_ON)
  `uvm_field_int(PWADDR, UVM_ALL_ON)
  `uvm_field_int(PRDATA, UVM_ALL_ON)
  `uvm_field_int(SLVERR, UVM_ALL_ON)
  `uvm_object_utils_end
  
endclass
