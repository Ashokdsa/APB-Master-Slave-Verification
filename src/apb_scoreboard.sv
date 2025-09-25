// APB Scoreboard collects transactions from both active and passive monitors via analysis imps.

`uvm_analysis_imp_decl(_passive)		//Analysis ipmlementation port declaration-passive monitor
`uvm_analysis_imp_decl(_active)			//Analysis ipmlementation port declaration-active monitor

class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  // Analysis implementation ports to receive transactions from monitors
  uvm_analysis_imp_active #(apb_sequence_item, apb_scoreboard) active_mon_export;
  uvm_analysis_imp_passive #(apb_sequence_item, apb_scoreboard) passive_mon_export;

  // Queues for reference and dut outputs
  apb_sequence_item ref_queue[$];   // Expected transactions from reference model
  apb_sequence_item mon_queue[$];   // Actual DUT outputs from passive monitor

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

  // Stat Counters
  int unsigned compares_total;
  int unsigned compares_pass;
  int unsigned compares_fail;


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

  endfunction:new

//Write method for the active monitor 
  virtual function void write_active(apb_sequence_item item); 
	  rs_in.copy(item); // Copy active monitor transaction into ref_seq_in
    write_val();
	if (rs_in.READ_WRITE)  // Only push while reading 
      ref_queue.push_back(rs_out);
  endfunction:write_active

 // Write method for the passive monitor 
  virtual function void write_passive(apb_sequence_item item1);
	mon_seq_out.copy(item1); // Copy passive monitor transaction into mon_seq_out
	if(ref_queue.size>0)
	  mon_queue.push_back(mon_seq_out);  // check if this is neccessary
  endfunction:write_passive


// Reference model 
  task write_val();
	bit slave_sel;
    int unsigned idx;
    rs_out.copy(rs_in);

    if (rs_in.PRESETn == 0) 
      begin
        rs_out.apb_read_data_out = 8'h00;
        rs_out.PSLVERR = 1'b0;
        foreach (slave1_mem[i]) slave1_mem[i] = 8'h00;
        foreach (slave2_mem[i]) slave2_mem[i] = 8'h00;
	  end 
    else 
      begin
     	if (rs_in.transfer) 
          begin
            if (!rs_in.READ_WRITE) 
              begin
      					slave_sel = rs_in.apb_write_paddr[8];
      					idx = rs_in.apb_write_paddr[7:0];
        				rs_out.PSLVERR = $isunknown(rs_in.apb_write_paddr);
      		    	if (slave_sel == 0 && !rs_out.PSLVERR)
        		  		slave1_mem[idx] = rs_in.apb_write_data;
      		    	else if(!rs_out.PSLVERR)
        		  		slave2_mem[idx] = rs_in.apb_write_data;
              end
            else 
              begin
      					slave_sel = rs_in.apb_read_paddr[8];
      					idx = rs_in.apb_read_paddr[7:0];
      					rs_out.PSLVERR = $isunknown(rs_in.apb_read_paddr);
      					if (slave_sel == 0 && !rs_out.PSLVERR)
        		  		rs_out.apb_read_data_out = slave1_mem[idx];
      					else if(rs_out.PSLVERR)
        		  		rs_out.apb_read_data_out = slave2_mem[idx];
    		 			end
              $display("PSLV = %0b CHANGE = %0b",rs_out.PSLVERR,rs_in.change);
      	    rs_out.PSLVERR = rs_out.PSLVERR | rs_in.change; // Not sure about the PSLVERR 
          end
      end
  endtask:write_val

  task run_phase(uvm_phase phase);
    bit PSLVERR_match;
    bit data_match;
    super.run_phase(phase);
      forever begin
        `uvm_info("APB_SCB", $sformatf("--\t%0d\t--", compares_total+1), UVM_LOW)
        wait(ref_queue.size() > 0 && mon_queue.size() > 0);		// Wait until both queues have data

        ref_seq_out = ref_queue.pop_front();
        mon_seq_out = mon_queue.pop_front();
        compares_total++;

        PSLVERR_match = (ref_seq_out.PSLVERR === mon_seq_out.PSLVERR);
        data_match    = (ref_seq_out.apb_read_data_out === mon_seq_out.apb_read_data_out);
				
				if (ref_seq_out.PSLVERR) 
					begin
						if (PSLVERR_match)
						begin
							`uvm_info("APB_SCB", $sformatf("---------\tCOMPARE MATCH PSLVERR: ref=%0d dut=%0d\t------",ref_seq_out.PSLVERR, mon_seq_out.PSLVERR), UVM_LOW)
							compares_pass++;
						end
						else
						begin
							`uvm_error("APB_SCB", $sformatf("---------\tCOMPARE FAILED SLVERR: ref=%0d dut=%0d\t--------", ref_seq_out.PSLVERR, mon_seq_out.PSLVERR))
							compares_fail++;
						end
					end
        else if (PSLVERR_match && data_match) 
          begin
          compares_pass++;
            `uvm_info("APB_SCB", $sformatf("------\tCOMPARE PASS: ref=%0d dut=%0d\t------", ref_seq_out.apb_read_data_out, mon_seq_out.apb_read_data_out), UVM_LOW)
          end 
        else  
          begin
            compares_fail++;
            `uvm_error("APB_SCB", $sformatf("M1 = %0d M2 = %0b --\tCOMPARE FAIL\n  REF: %0d\n  DUT: %0d\n--------------------",PSLVERR_match,data_match,
            ref_seq_out.apb_read_data_out, mon_seq_out.apb_read_data_out))
          end
      end
    
  endtask:run_phase

 //Reprot summary
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("APB_SCB_SUM", $sformatf("COMPARES total=%0d pass=%0d fail=%0d refq_left=%0d monq_left=%0d",
                compares_total, compares_pass, compares_fail,
                ref_queue.size(), mon_queue.size()), UVM_LOW)
  endfunction:report_phase

endclass:apb_scoreboard
