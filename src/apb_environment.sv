class apb_environment extends uvm_env;
  	apb_active_agent    active_agent;
  	apb_passive_agent   passive_agent;
  	apb_scoreboard 		scoreboard;
  	apb_subscriber 		subscriber;
  
  `uvm_component_utils(apb_environment)
  
  function new(string name = "apb_environment", uvm_component parent);
    	super.new(name, parent);
  	endfunction:new

  	function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
        active_agent = apb_active_agent::type_id::create("active_agent", this);
      	passive_agent = apb_passive_agent::type_id::create("passive_agent", this);
      	scoreboard = apb_scoreboard::type_id::create("scoreboard", this);
      	subscriber = apb_coverage::type_id::create("coverage", this);
  	endfunction:build_phase
  
    function void connect_phase(uvm_phase phase);    								   
      active_agent.active_monitor.item_collected_port.connect(scoreboard.item_collected_export_active); 
      passive_agent.passive_monitor.item_collected_port.connect(scoreboard.item_collected_export_passive);    
      active_agent.active_monitor.item_collected_port.connect(subscriber.analysis_export);
      passive_agent.passive_monitor.item_collected_port.connect(subscriber.pass_mon);
  	endfunction:connect_phase
endclass:apb_environment
