// APB Driver: Drives DUT pins based on sequence items from sequencer

class apb_driver extends uvm_driver #(apb_sequence_item);
  virtual apb_inf vif;    // Virtual interface to access DUT signals
  event act_e,pass_e;     // Events used to trigger monitors (active and passive)
  logic prev_transf=0;    // Keeps track of previous transfer value for timing logic
  `uvm_component_utils(apb_driver)
    
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction:new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev1", act_e))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    
    if(!uvm_config_db#(event)::get(this, "", "ev2", pass_e))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

  endfunction:build_phase
  
  virtual task run_phase(uvm_phase phase);
    @(vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req); 
      $display("SEQ ENTERED DRIVER");
      drive();
      seq_item_port.item_done();
    end
  endtask:run_phase
  virtual task drive();    
    @(vif.drv_cb);
    $display("-----------------------------------------------------------------------------------------------------");
    `uvm_info(get_name,"SENT THE VALUES TO DUT",UVM_MEDIUM)
    if(get_report_verbosity_level() >= UVM_MEDIUM)
      $display("SYSTEM BUS SIGNALS: transfer = %0b PRESETn = %0b\nMAIN:\nREAD_WRITE = %0b",req.transfer,req.PRESETn,req.READ_WRITE);
    if(req.READ_WRITE)    // Check if operation is WRITE
    begin
      if(get_report_verbosity_level() >= UVM_MEDIUM)
        $display("READ_ADDR = %0d\tbin = %9b",req.apb_read_paddr,req.apb_read_paddr);
      vif.transfer<=req.transfer;
      vif.PRESETn<=req.PRESETn;
      vif.READ_WRITE<=req.READ_WRITE;
      vif.apb_read_paddr<=req.apb_read_paddr;
      `uvm_info(get_name,"ACTIVE MON TRIGGERED",UVM_MEDIUM)
      ->act_e;          // Trigger active monitor
      repeat(2)@(vif.drv_cb);
      // if(req.change)
      // begin
      //   seq_item_port.item_done();
      //   seq_item_port.get_next_item(req); 
      //   vif.transfer<=req.transfer;
      //   vif.PRESETn<=req.PRESETn;
      //   vif.READ_WRITE<=req.READ_WRITE;
      //   vif.apb_write_paddr<=req.apb_write_paddr;
      //   vif.apb_write_data<=req.apb_write_data;
      //   vif.apb_read_paddr<=req.apb_read_paddr;
      //   `uvm_info(get_name,"INSERTED ERROR",UVM_MEDIUM);
      // end
      /*if(req.transfer==1 &&(!prev_transf))  //IF FIRST TRANSFER, 
      else if(req.transfer==1&&(prev_transf))  //NOT A FIRST TRANSFER  
        repeat(1)@(vif.drv_cb);*/
      prev_transf=req.transfer;
      ->pass_e;            // Trigger passive monitor
      if(get_report_verbosity_level() >= UVM_MEDIUM)
        `uvm_info(get_name,"PASSIVE MON TRIGGERED",UVM_MEDIUM)
    end
    else      // Drive read signals
    begin
      $display("WRITE_ADDR = %0d\tbin = %9b\nWRITE_DATA = %0d",req.apb_write_paddr,req.apb_write_paddr,req.apb_write_data);
      vif.transfer<=req.transfer;
      vif.PRESETn<=req.PRESETn;
      vif.READ_WRITE<=req.READ_WRITE;
      vif.apb_write_paddr<=req.apb_write_paddr;
      vif.apb_write_data<=req.apb_write_data;
      ->act_e;      // Trigger active monitor
      repeat(2)@(vif.drv_cb);
      `uvm_info(get_name,"ACTIVE MON TRIGGERED",UVM_MEDIUM)
      /*if(req.transfer==1 &&(!prev_transf))
        repeat(2)@(vif.drv_cb);
      else if(req.transfer==1&&(prev_transf))
        repeat(1)@(vif.drv_cb);*/
      prev_transf=req.transfer;
      ->pass_e;      // Trigger passive monitor
      `uvm_info(get_name,"PASSIVE MON TRIGGERED",UVM_MEDIUM)
     end
  endtask:drive
endclass:apb_driver
