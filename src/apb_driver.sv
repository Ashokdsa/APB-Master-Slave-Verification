class apb_driver extends uvm_driver #(apb_sequence_item);
  virtual apb_inf vif;
  event act_e,pass_e;
  logic prev_transf=0;
  bit change_val;
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

    if(!uvm_config_db#(bit)::get(this, "", "bit_val", change_val))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    repeat(2)@(vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req); 
      drive();
      seq_item_port.item_done();
    end
  endtask
  virtual task drive();
    //@(vif.drv_cb);
   // @(posedge vif.drv_cb);
    $display("---------------------------------------------------------------------------");
    `uvm_info(get_name,"SENT THE VALUES TO DUT",UVM_MEDIUM)
    if(get_report_verbosity_level() >= UVM_MEDIUM)
      $display("SYSTEM BUS SIGNALS: transfer = %0b PRESETn = %0b\nMAIN:\nREAD_WRITE = %0b",req.transfer,req.PRESETn,req.READ_WRITE);

      $display("WRITE_ADDR = %0d\tWRITE_DATA = %0d",req.apb_write_paddr,req.apb_write_data);
      vif.transfer<=req.transfer;
      vif.PRESETn<=req.PRESETn;
      vif.READ_WRITE<=req.READ_WRITE;
      vif.apb_write_paddr<=req.apb_write_paddr;
      vif.apb_write_data<=req.apb_write_data;
      vif.apb_read_paddr<=req.apb_read_paddr;
      change_val <= req.change;
      
      `uvm_info(get_name,"ACTIVE MON TRIGGERED",UVM_MEDIUM)
      ->act_e;
      
      if(req.transfer==1 &&(!prev_transf))  //IF FIRST TRANSFER, 
      begin
        repeat(1)@(vif.drv_cb);
        `uvm_warning(get_name,$sformatf("CHANGE = %0b",req.change))
        if(req.change)
        begin
          seq_item_port.item_done();
          seq_item_port.get_next_item(req); 
          vif.transfer<=req.transfer;
          vif.PRESETn<=req.PRESETn;
          vif.READ_WRITE<=req.READ_WRITE;
          vif.apb_write_paddr<=req.apb_write_paddr;
          vif.apb_write_data<=req.apb_write_data;
          vif.apb_read_paddr<=req.apb_read_paddr;
          `uvm_warning(get_name,"ADDED next sequence in between")
        end
        repeat(2)@(vif.drv_cb);
      end
      else if(req.transfer==1&&(prev_transf))  //NOT A FIRST TRANSFER  
      begin
        repeat(1)@(vif.drv_cb);
        `uvm_warning(get_name,$sformatf("CHANGE = %0b",req.change))
        if(req.change)
        begin
          seq_item_port.item_done();
          seq_item_port.get_next_item(req); 
          vif.transfer<=req.transfer;
          vif.PRESETn<=req.PRESETn;
          vif.READ_WRITE<=req.READ_WRITE;
          vif.apb_write_paddr<=req.apb_write_paddr;
          vif.apb_write_data<=req.apb_write_data;
          vif.apb_read_paddr<=req.apb_read_paddr;
          `uvm_warning(get_name,"ADDED next sequence in between")
        end
        repeat(2)@(vif.drv_cb);
      end
      prev_transf=req.transfer;
      ->pass_e;
       if(get_report_verbosity_level() >= UVM_MEDIUM)
        `uvm_info(get_name,"PASSIVE MON TRIGGERED",UVM_MEDIUM)
         repeat(1)@(vif.drv_cb);
  endtask
endclass
