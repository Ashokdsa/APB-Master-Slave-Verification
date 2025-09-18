class apb_passive_agent extends uvm_agent;
  	apb_passive_monitor  passive_monitor;

  `uvm_component_utils(apb_passive_agent)

  function new (string name = "apb_passive_agent", uvm_component parent);
    	super.new(name, parent);
  	endfunction:new

  	function void build_phase(uvm_phase phase);
       uvm_config_db#(uvm_active_passive_enum) :: get(this,"","is_active",is_active);
      passive_monitor = apb_passive_monitor::type_id::create("passive_monitor", this);
  	endfunction:build_phase
endclass:apb_passive_agent
