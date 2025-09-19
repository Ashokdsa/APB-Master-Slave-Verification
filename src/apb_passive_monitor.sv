class apb_passive_monitor extends uvm_monitor;
  virtual apb_inf vif;
  uvm_analysis_port #(apb_sequence_item) item_collected_port;
  apb_sequence_item seq_item;

  `uvm_component_utils(apb_passive_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item = new();
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev2", pass_e))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
   forever 
     begin
       @(pass_e);
        seq_item.apb_read_data_out = vif.mon_cb.apb_read_data_out;
        seq_item.PSLVERR = vif.mon_cb.PSLVERR;
        item_collected_port.write(seq_item);
    end
  endtask
endclass
    
