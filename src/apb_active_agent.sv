
class apb_active_agent extends uvm_agent;
  	apb_driver    driver;
  	apb_sequencer sequencer;
  	apb_active_monitor   active_monitor;

  `uvm_component_utils(apb_active_agent)

  function new (string name = "apb_active_agent", uvm_component parent);
    	super.new(name, parent);
  	endfunction:new

  	function void build_phase(uvm_phase phase);
       uvm_config_db#(uvm_active_passive_enum) :: get(this,"","is_active",is_active);
      if(get_is_active() == UVM_ACTIVE)begin
      	driver = apb_driver::type_id::create("driver", this);
      	sequencer = apb_sequencer::type_id::create("sequencer", this);
      end
      active_monitor = apb_active_monitor::type_id::create("monitor", this);
  	endfunction:build_phase

  	function void connect_phase(uvm_phase phase);
      		if(get_is_active() == UVM_ACTIVE)
      		driver.seq_item_port.connect(sequencer.seq_item_export);
  	endfunction:connect_phase

endclass:apb_active_agent
