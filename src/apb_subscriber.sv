`include "defines.svh"
`uvm_analysis_imp_decl(_passive_mon)

class apb_subscriber extends uvm_subscriber#(apb_sequence_item);
  `uvm_component_utils(apb_subscriber)
  uvm_analysis_imp_passive_mon#(apb_sequence_item,apb_subscriber) pass_mon;
  apb_sequence_item drv;
  apb_sequence_item mon;
  
covergroup input_cg;
  transfer_cp:   coverpoint drv.transfer { bins enable = {1}; bins disable = {0}; }
  write_addr_cp: coverpoint drv.apb_write_paddr {bins w_addr_slv1[]  = {[0:255]}; bins w_addr_slv2[]  = {[256:511]};}
  read_addr_cp:  coverpoint drv.apb_read_paddr {bins r_addr_slv1[]  = {[0:255]}; bins r_addr_slv2[]  = {[256:511]};}
  READ_WRITE_cp: coverpoint drv.READ_WRITE{ bins read_write = {0,1}; }
  write_data_cp: coverpoint drv.apb_write_data { bins data_vals[] = {[0:255]}; }
  READ_WRITExwrite_addr: cross READ_WRITE_cp, write_addr_cp;
  READ_WRITExread_addr:  cross READ_WRITE_cp, read_addr_cp;
endgroup
  
  covergroup output_cg;
    read_data_cp: coverpoint mon.apb_read_data_out { bins rdata_vals[] = {[0:255]}; }
    slverr_cp:    coverpoint mon.PSLVERR { bins no_err = {0}; bins err = {1}; }
    read_dataxslverr: cross slverr_cp, read_data_cp;
  endgroup

  function new(string name = "subs", uvm_component parent = null);
    super.new(name,parent);
    input_cg = new();
    output_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pass_mon = new("pass_mon",this);
  endfunction

  virtual function void write(apb_sequence_item t);
    drv = t;
   	input_cg.sample();
    `uvm_info(get_name,"[DRIVER]:INPUT RECIEVED",UVM_HIGH)
  endfunction

  virtual function void write_passive_mon(alu_sequence_item seq);
    mon = seq;
    output_cg.sample();
    `uvm_info(get_name,"[MONITOR]:INPUT RECIEVED",UVM_HIGH)
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name,$sformatf("INPUT COVERAGE = %0f\n OUTPUT COVERAGE = %0f",input_cg.get_coverage(),output_cg.get_coverage()),UVM_NONE);
  endfunction

endclass
