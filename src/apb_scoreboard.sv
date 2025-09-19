// Code your testbench here
// or browse Examples
`include "apb_sequence_item.sv"
`uvm_analysis_imp_decl(_passive)
`uvm_analysis_imp_decl(_active)

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  // Two analysis imps
  uvm_analysis_imp_active #(apb_sequence_item, apb_scoreboard) active_mon_export;
  uvm_analysis_imp_passive #(apb_sequence_item, apb_scoreboard) passive_mon_export;

  // Queues for reference and dut outputs
  apb_sequence_item ref_queue[$];   // reference model results  come back later 
  apb_sequence_item mon_queue[$];   // dut monitor results

  // Slave memories (based on 9th bit of address)
  logic [7:0] slave1_mem [0:255];
  logic [7:0] slave2_mem [0:255];

  // Handles
  apb_sequence_item ref_seq_in;
  apb_sequence_item ref_seq_out;
  apb_sequence_item mon_seq_out;
  apb_sequence_item rs_in;
  apb_sequence_item rs_out;
//   apb_sequence_item prev_ref_out;  // not sure about this

  // Stats
  int unsigned compares_total;
  int unsigned compares_pass;
  int unsigned compares_fail;

  // Constructor
  function new(string name="apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);

    active_mon_export  = new("active_mon_export",  this);
    passive_mon_export = new("passive_mon_export", this);

    ref_seq_in    = apb_sequence_item::type_id::create("ref_seq_in");
    ref_seq_out   = apb_sequence_item::type_id::create("ref_seq_out");
    mon_seq_out   = apb_sequence_item::type_id::create("mon_seq_out");
    rs_out = apb_sequence_item::type_id::create("rs_out");
    rs_in = apb_sequence_item::type_id::create("rs_in");

    foreach (slave1_mem[i]) slave1_mem[i] = 8'h00;
    foreach (slave2_mem[i]) slave2_mem[i] = 8'h00;

    compares_total = 0;
    compares_pass  = 0;
    compares_fail  = 0;
  endfunction

//write method for the passive monitor 
  virtual function void write_active(apb_sequence_item item); 
    rs_in.copy(item); // copy passive monitor transaction into ref_seq_in
    reference_model();
    if (rs_in.read_write == 0)  // only push while reading 
      ref_queue.push_back(rs_out);
  endfunction

 // write method for the active monitor 
  virtual function void write_passive(apb_sequence_item item1);
    mon_seq_out.copy(item1); // copy active monitor transaction into mon_seq_out
    mon_queue.push_back(mon_seq_out);  /// check if this is neccessary
  endfunction


// reference model 
  task reference_model();
	bit slave_sel;
    int unsigned idx;
    rs_out.copy(rs_in);

    if (rs_in.resetn == 0) 
      begin
        rs_out.apb_read_data_out = 8'h00;
        rs_out.pslverr = 1'b0;
        foreach (slave1_mem[i]) slave1_mem[i] = 8'h00;
        foreach (slave2_mem[i]) slave2_mem[i] = 8'h00;
	  end 
    else 
      begin
     	if (rs_in.transfer) 
          begin
      		if (rs_in.read_write) 
              begin
      			slave_sel = rs_in.apb_write_paddr[8];
      			idx = rs_in.apb_write_paddr[7:0];
      		    if (slave_sel == 0)
        		  slave1_mem[idx] = rs_in.apb_write_data;
      		    else
        		  slave2_mem[idx] = rs_in.apb_write_data;
                rs_out.pslverr=1'b0   // not sure about this pslverr
              end
            else 
              begin
      			slave_sel = rs_in.apb_read_paddr[8];
      			idx = rs_in.apb_read_paddr[7:0];
      			if (slave_sel == 0)
        		  rs_out.apb_read_data_out = slave1_mem[idx];
      			else
        		  rs_out.apb_read_data_out = slave2_mem[idx];
      			rs_out.pslverr = 1'b0;// not sure about the pslverr 
    		 end
          end
      end
    
  endtask

 // run phase to compare the ref out and the mon out 
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      forever begin
      // Wait until both queues have data
        wait(ref_queue.size() > 0 && mon_queue.size() > 0);

        ref_seq_out = ref_queue.pop_front();
        mon_seq_out = mon_queue.pop_front();
        compares_total++;

        bit pslverr_match = (ref_seq_out.pslverr === mon_seq_out.pslverr); // no need to compare
        bit data_match    = (ref_seq_out.apb_read_data_out === mon_seq_out.apb_read_data_out);

        if (pslverr_match && data_match) 
          begin
          compares_pass++;
            `uvm_info("APB_SCB", $sformatf("COMPARE PASS: ref=%s dut=%s", ref_seq_out.convert2string(), mon_seq_out.convert2string()), UVM_LOW)
          end 
        else 
          begin
            compares_fail++;
            `uvm_error("APB_SCB", $sformatf("COMPARE FAIL\n  REF: %s\n  DUT: %s",
            ref_seq_out.convert2string(), mon_seq_out.convert2string()))
          end
      end
    
  endtask

 //reprot summary
  virtual function void end_of_simulation();
    `uvm_info("APB_SCB_SUM", $sformatf("COMPARES total=%0d pass=%0d fail=%0d resets=%0d refq_left=%0d monq_left=%0d",
                compares_total, compares_pass, compares_fail, resets_seen,
                ref_queue.size(), mon_queue.size()), UVM_LOW)
  endfunction

endclass
