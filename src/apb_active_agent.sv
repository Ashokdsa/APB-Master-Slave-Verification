// Active APB agent class which instantiates driver, sequencer and active monitor

class apb_active_agent extends uvm_agent;
  	apb_driver    driver;
  	apb_sequencer sequencer;
  	apb_active_monitor   active_monitor;
  
  // Register this component with UVM factory
  `uvm_component_utils(apb_active_agent)

  function new (string name = "apb_active_agent", uvm_component parent);
    	super.new(name, parent);
  	endfunction:new

  	function void build_phase(uvm_phase phase);
      if(!uvm_config_db#(uvm_active_passive_enum) :: get(this,"","is_active",is_active))
        `uvm_fatal("NO vif","IS_ACTIVE is not defined")
      // If agent is ACTIVE, build driver and sequencer
      if(get_is_active() == UVM_ACTIVE)begin
        driver = apb_driver::type_id::create("driver", this);
      	sequencer = apb_sequencer::type_id::create("sequencer", this);
      end
      // Monitor is created in both ACTIVE and PASSIVE modes
      active_monitor = apb_active_monitor::type_id::create("monitor", this);
  	endfunction:build_phase

  	function void connect_phase(uvm_phase phase);
      if(get_is_active() == UVM_ACTIVE)
      begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
        $display("CONNECT DONE");
      end
  	endfunction:connect_phase

endclass:apb_active_agent
