// Subscriber for collecting functional coverage of APB transactions

`uvm_analysis_imp_decl(_passive_mon)    // Declare a new analysis_imp for passive monitor connection

class apb_subscriber extends uvm_subscriber#(apb_sequence_item);
  `uvm_component_utils(apb_subscriber)    // Factory registration
  uvm_analysis_imp_passive_mon#(apb_sequence_item,apb_subscriber) pass_mon;      // Analysis implementation to connect passive monitor
  apb_sequence_item drv;    //Drver side sequence item handles 
  apb_sequence_item mon;    //Monitor side sequence item handles 
  
covergroup input_cg;      // Input coverage group 
  transfer_cp:   coverpoint drv.transfer { bins enabled = {1}; bins disabled = {0}; }
  write_addr_cp: coverpoint drv.apb_write_paddr {bins w_addr_slv1[]  = {[0:255]}; bins w_addr_slv2[]  = {[256:511]};}
  read_addr_cp:  coverpoint drv.apb_read_paddr {bins r_addr_slv1[]  = {[0:255]}; bins r_addr_slv2[]  = {[256:511]};}
  READ_WRITE_cp: coverpoint drv.READ_WRITE{ bins read_write = {0,1}; }
  write_data_cp: coverpoint drv.apb_write_data { bins data_vals[] = {[0:255]}; }
  READ_WRITExwrite_addr: cross READ_WRITE_cp, write_addr_cp;    // Cross coverage to check combinations of read/write with addresses
  READ_WRITExread_addr:  cross READ_WRITE_cp, read_addr_cp;    // Cross coverage to check combinations of read/write with addresses
endgroup:input_cg
  
  covergroup output_cg;     // Output coverage group
    read_data_cp: coverpoint mon.apb_read_data_out { bins rdata_vals[] = {[0:255]}; }
    slverr_cp:    coverpoint mon.PSLVERR { bins no_err = {0}; bins err = {1}; }
    read_dataxslverr: cross slverr_cp, read_data_cp;    // Cross coverage between error status and read data
  endgroup:output_cg

  function new(string name = "subs", uvm_component parent = null);
    super.new(name,parent);
    input_cg = new();
    output_cg = new();
  endfunction:new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    pass_mon = new("pass_mon",this);
  endfunction:build_phase

  virtual function void write(apb_sequence_item t);     // write() - receives transactions from the DRIVER
    drv = t;
   	input_cg.sample();
    `uvm_info(get_name,"[DRIVER]:INPUT RECIEVED",UVM_HIGH)
  endfunction:write

  virtual function void write_passive_mon(apb_sequence_item seq);     // write_passive_mon() - receives transactions from the PASSIVE monitor
    mon = seq;
    output_cg.sample();
    `uvm_info(get_name,"[MONITOR]:INPUT RECIEVED",UVM_HIGH)
  endfunction:write_passive_mon

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name,$sformatf("INPUT COVERAGE = %0f\n OUTPUT COVERAGE = %0f",input_cg.get_coverage(),output_cg.get_coverage()),UVM_NONE);
  endfunction:report_phase

endclass:apb_subscriber
