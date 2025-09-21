class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)
  apb_environment apb_env;
  apb_write_read_sequence base;

  function new(string name = "apb_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //apb_write_read_sequence::type_id::set_type_override(apb_reset_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_read_write_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_transfer_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_write_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_read_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_same_sequence::get_type());
    //apb_write_read_sequence::type_id::set_type_override(apb_diff_slave_sequence::get_type());
    apb_env = apb_environment::type_id::create("apb_env",this);
  endfunction

  function void end_of_elaboration();
    //uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);
      `uvm_info(get_name,"SEQUENCE STARTED",UVM_NONE)
      base = apb_write_read_sequence::type_id::create("apb_sequence");
      base.start(apb_env.active_agent.sequencer);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
    `uvm_info(get_name,"SEQUENCE ENDED",UVM_NONE)
    $display("--------------------------------------------------TEST ENDED--------------------------------------------------");
  endtask
endclass
