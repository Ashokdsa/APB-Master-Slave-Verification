//Passive APB Monitor observes the APB interface signals without driving them.

class apb_passive_monitor extends uvm_monitor;
  virtual apb_inf vif;      // Virtual interface handle for connecting to DUT signals
  uvm_analysis_port #(apb_sequence_item) item_collected_port;    // Analysis port
  apb_sequence_item seq_item;
  event pass_e;      // Event to trigger monitoring activity

  // Register the component with UVM factory
  `uvm_component_utils(apb_passive_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item = new();
    item_collected_port = new("item_collected_port", this);
  endfunction:new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev2", pass_e))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction:build_phase

  virtual task run_phase(uvm_phase phase);
   forever 
     begin
       @(pass_e);
        seq_item.apb_read_data_out = vif.apb_read_data_out;
        seq_item.PSLVERR = vif.PSLVERR;
        item_collected_port.write(seq_item);
        `uvm_info(get_name,"RECIEVED OUTPUT",UVM_MEDIUM)
        if(get_report_verbosity_level() >= UVM_MEDIUM)
          $display("READ_DATA_OUT = %0d\tPSLVERR = %0b",seq_item.apb_read_data_out,seq_item.PSLVERR);
    end
  endtask:run_phase
endclass:apb_passive_monitor
    
