class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)
  apb_environment apb_env;
  apb_write_read_sequence base;

  function new(string name = "apb_test",uvm_component = null)
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  //HAVE TO DO THIS
    //base_sequence::type_id::set_type_override(alu_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_glo_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_err_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_corner_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_time_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_w_time_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_flag_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_mult_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_mult_time_sequence::get_type());
    //base_sequence::type_id::set_type_override(alu_crn_mult_sequence::get_type());
    base_sequence::type_id::set_type_override(regression_sequence::get_type());
    apb_env = apb_environment::type_id::create("apb_env",this);
  endfunction

  function void end_of_elaboration();
    uvm_top.print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    super.run_phase(phase);
    phase.raise_objection(this);
      base = apb_write_read_sequence::type_id::create("apb_sequence");
      base.start(apb_env.apb_active_agent.apb_sequencer);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endfunction
endclass
