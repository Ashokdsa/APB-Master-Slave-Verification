// APB Active Monitor: Observes DUT signals and publishes transactions

class apb_active_monitor extends uvm_monitor;
  virtual apb_inf vif;  // Virtual interface handle for APB interface
  event act_e;          // Event to trigger sampling
  uvm_analysis_port #(apb_sequence_item) item_collected_port;    // Analysis port
  apb_sequence_item seq_item;

  // Register this component with UVM factory
  `uvm_component_utils(apb_active_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    seq_item = new();
    item_collected_port = new("item_collected_port", this);
  endfunction

  // Build phase: get interface and event handles from config DB
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
       @(act_e);          //waits for event and samples interface values
       @(vif.a_mon_cb);
        seq_item.transfer = vif.transfer;
        seq_item.PRESETn = vif.PRESETn;
        seq_item.READ_WRITE = vif.READ_WRITE;
        seq_item.apb_write_paddr = vif.apb_write_paddr;
        seq_item.apb_read_paddr = vif.apb_read_paddr;
        seq_item.apb_write_data = vif.apb_write_data;
       
        item_collected_port.write(seq_item);
        `uvm_info(get_name,"RECIEVED INPUTS",UVM_MEDIUM)
        if(get_report_verbosity_level() >= UVM_MEDIUM)
        begin
          $display("SYSTEM BUS SIGNALS: transfer = %0b PRESETn = %0b\nMAIN:\nREAD_WRITE = %0b",seq_item.transfer,seq_item.PRESETn,seq_item.READ_WRITE);
          if(seq_item.READ_WRITE)
            $display("WRITE_ADDR = %0d\tWRITE_DATA = %0d",seq_item.apb_write_paddr,seq_item.apb_write_data);
          else
            $display("READ_ADDR = %0d",seq_item.apb_read_paddr);
        end
       
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
    
