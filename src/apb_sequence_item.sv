//APB sequence item 

class apb_sequence_item extends uvm_sequence_item;
  // Inputs to DUT
  rand logic [7:0] apb_write_data;
  rand logic transfer;
  rand logic READ_WRITE;
  rand logic PRESETn;
  rand logic [8:0] apb_read_paddr;
  rand logic [8:0] apb_write_paddr;
  // Outputs from DUT
  logic [7:0] apb_read_data_out;
  logic PSLVERR;

  bit change = 0;

  // Factory registration
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

  function new(string name = "apb_sequence_item");
   		 super.new(name);
 	 endfunction:new
  
endclass:apb_sequence_item
