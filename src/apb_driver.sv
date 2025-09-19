class apb_driver extends uvm_driver #(apb_sequence_item);
  virtual apb_inf vif;
  event act_e,pass_e;
  logic prev_transf=0;
  `uvm_component_utils(apb_driver)
    
  function new (string name, uvm_component parent);
    super.new(name, parent);
   
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev1", act_e))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev2", pass_e))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(seq); 
    drive();
    seq_item_port.item_done();
    end
  endtask
  virtual task drive();
    @(posedge vif.drv_cb);
    if(seq.READ_WRITE)
     begin
     vif.drv_cb.transfer<=seq.transfer;
     vif.drv_cb.PRESETn<=seq.PRESETn;
     vif.drv_cb.READ_WRITE<=seq.READ_WRITE;
     vif.drv_cb.apb_write_paddr<=seq.apb_write_paddr;
     vif.drv_cb.apb_write_data<=seq.apb_write_data;
     ->act_e;
       if(seq.transfer==1 &&(!prev_transf))  //IF FIRST TRANSFER, 
         repeat(3)@(posedge vif.drv_cb);
       else if(seq.transfer==1&&(prev_transf))  //NOT A FIRST TRANSFER  
         repeat(2)@(posedge vif.drv_cb);
       else if(seq.transfer==0)                    //NO TRANSFER 
            @(posedge vif.drv_cb);
       prev_transf=seq.transfer;
     ->pass_e;
     end
     else
     begin
     vif.drv_cb.transfer<=seq.transfer;
     vif.drv_cb.PRESETn<=seq.PRESETn;
     vif.drv_cb.READ_WRITE<=seq.READ_WRITE;
     vif.drv_cb.apb_read_paddr<=seq.apb_read_paddr;
     ->act_e;
      if(seq.transfer==1 &&(!prev_transf))
         repeat(3)@(posedge vif.drv_cb);
       else if(seq.transfer==1&&(prev_transf))
         repeat(2)@(posedge vif.drv_cb);
       else if(seq.transfer==0)
            @(posedge vif.drv_cb);
       prev_transf=seq.transfer;
       ->pass_e;
     end
  endtask
  
endclass
