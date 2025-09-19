class apb_active_monitor extends uvm_monitor;
  virtual apb_inf vif;
  event act_e;
  uvm_analysis_port #(apb_sequence_item) item_collected_port;
  apb_sequence_item seq_item;

  `uvm_component_utils(apb_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item = new();
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev1", act_e))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction

  virtual task run_phase(uvm_phase phase);
   forever 
     begin
       @(act_e);
       @(posedge vif.mon_cb);
        seq_item.transfer = vif.mon_cb.transfer;
        seq_item.PRESETn = vif.mon_cb.PRESETn;
        seq_item.READ_WRITE = vif.mon_cb.READ_WRITE;
        seq_item.apb_write_paddr = vif.mon_cb.apb_write_paddr;
        seq_item.apb_read_paddr = vif.mon_cb.apb_read_paddr;
        seq_item.apb_write_data = vif.mon_cb.apb_write_data;
       
        item_collected_port.write(seq_item);
       
//        if(vif.mon_cb.transfer==1 &&(!prev_transf))
//          repeat(3)@(posedge vif.MON.CLK);
//        else if(vif.mon_cb.transfer==1&&(prev_transf))
//          repeat(2)@(posedge vif.MON.CLK);
//        else if(vif.mon_cb.transfer==0)
//          @(posedge vif.MON.CLK);
//        prev_transf=seq.transfer;
    end
  endtask
endclass
    
