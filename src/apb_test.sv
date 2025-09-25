//APB test 

class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)    //Factory Registration
  apb_environment apb_env;
  apb_base_sequence base;

  function new(string name = "apb_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction:new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_env = apb_environment::type_id::create("apb_env",this);
  endfunction:build_phase

  function void end_of_elaboration();
    uvm_top.print_topology();
  endfunction:end_of_elaboration
/*
  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);    //Raise Objection
      `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE)
      base = apb_base_sequence::type_id::create("apb_sequence");    // Create and start the sequence dynamically
      base.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
*/
endclass:apb_test

class apb_write_read_test extends apb_test;
  `uvm_component_utils(apb_write_read_test);
  apb_write_read_sequence#(30) seq;
  function new(string name = "apb_wr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_write_read_sequence#(30)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_reset_test extends apb_test;
  `uvm_component_utils(apb_reset_test);
  apb_reset_sequence#(2) seq;
  function new(string name = "apb_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_reset_sequence#(2)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_read_write_test extends apb_test;
  `uvm_component_utils(apb_read_write_test);
  apb_read_write_sequence#(2) seq;
  function new(string name = "apb_read_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_read_write_sequence#(2)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_transfer_test extends apb_test;
  `uvm_component_utils(apb_transfer_test);
  apb_transfer_sequence#(8) seq;
  function new(string name = "apb_transfer_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_transfer_sequence#(8)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_write_test extends apb_test;
  `uvm_component_utils(apb_write_test);
  apb_write_sequence#(10) seq;
  function new(string name = "apb_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_write_sequence#(10)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_read_test extends apb_test;
  `uvm_component_utils(apb_read_test);
  apb_read_sequence#(10) seq;
  function new(string name = "apb_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_read_sequence#(10)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_same_test extends apb_test;
  `uvm_component_utils(apb_same_test);
  apb_same_sequence#(6) seq;
  function new(string name = "apb_same_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_same_sequence#(6)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_diff_slave_test extends apb_test;
  `uvm_component_utils(apb_diff_slave_test);
  apb_diff_slave_sequence#(10) seq;
  function new(string name = "apb_diff_slave_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_diff_slave_sequence#(10)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_one_clock_test extends apb_test;
  `uvm_component_utils(apb_one_clock_test);
  apb_one_clock_sequence#(6) seq;
  function new(string name = "apb_one_clock_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_one_clock_sequence#(6)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_check_test extends apb_test;
  `uvm_component_utils(apb_check_test);
  apb_check_sequence#(2) seq;
  function new(string name = "apb_check_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_check_sequence#(2)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass

class apb_invalid_test extends apb_test;
  `uvm_component_utils(apb_invalid_test);
  apb_invalid_sequence#(2) seq;
  function new(string name = "apb_invalid_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_invalid_sequence#(2)::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass:apb_invalid_test

class apb_regress_test extends apb_test;
  `uvm_component_utils(apb_regress_test);
  apb_regress_sequence seq;
  function new(string name = "apb_regress_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);//Raise Objection
    `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE);
    seq = apb_regress_sequence::type_id::create();
    seq.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);    //Drop Objection
    phase_done.set_drain_time(this,20);    // Drain time before dropping objection
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask:run_phase
endclass
