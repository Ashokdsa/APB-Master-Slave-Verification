class apb_driver extends uvm_driver #(apb_sequence_item);
  virtual apb_inf vif;
  `uvm_component_utils(apb_driver)
    
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_inf)::get(this, "", "vif", vif))
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
     vif.drv_cb.transfer<=seq.transfer;
     vif.drv_cb.READ_WRITE<=seq.READ_WRITE;
     vif.drv_cb.apb_write_paddr<=seq.apb_write_paddr;
     vif.drv_cb.apb_read_paddr<=seq.apb_read_paddr;
     vif.drv_cb.apb_write_data<=seq.apb_write_data;

    repeat(2)@(posedge vif.DRV.CLK);
  endtask
  
endclass
