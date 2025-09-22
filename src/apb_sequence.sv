//Need to add a queue to not repeat values while writing
//Apb Sequence generates read-write sequences

class apb_base_sequence extends uvm_sequence#(apb_sequence_item); //BASE sequence
  `uvm_object_utils(apb_base_sequence)    //Factory Registration
  apb_sequence_item seq;
  bit read_prev;
  int unsigned qu[$];

  function new(string name = "apb_base_sequence");
    super.new(name);
  endfunction:new

  task body();
    `uvm_do_with(seq,
    {
      seq.transfer == 1;
      seq.PRESETn == 1;
    })
  endtask
endclass

class apb_write_read_sequence#(int val = 2) extends apb_base_sequence;    //Generates both write and read transactions alternately
  `uvm_object_param_utils(apb_write_read_sequence#(val))    //Factory Registration

  function new(string name = "apb_write_read_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("base_sequence_item");
    read_prev = 1;
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;    // alternate read/write
        if(READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        else
          foreach(qu[i])
            seq.apb_write_paddr != qu[i];
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(!seq.READ_WRITE)
      begin
        seq.apb_write_paddr.rand_mode(0);     // Freeze addr after write
      end
      else
      begin
        qu.push_front(seq.apb_write_paddr);
        seq.apb_write_paddr.rand_mode(1);    // Allow addr change otherwise
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_write_read_sequence

class apb_reset_sequence#(int val = 2) extends apb_base_sequence;    //Generates reset scenarios by de-asserting PRESETn
  `uvm_object_param_utils(apb_reset_sequence#(val))    //Factory Registration

  function new(string name = "apb_reset_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("reset_sequence_item");
    read_prev = 1;
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;
        if(READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        else
          foreach(qu[i])
            seq.apb_write_paddr != qu[i];
      })
      else
          `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(!seq.READ_WRITE)
        seq.apb_write_paddr.rand_mode(0);
      else
      begin
        qu.push_front(seq.apb_write_paddr);
        seq.apb_write_paddr.rand_mode(1);
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_reset_sequence

class apb_read_write_sequence#(int val = 2) extends apb_base_sequence;    //- Forces alternate read and write operations at the same address
  `uvm_object_param_utils(apb_read_write_sequence#(val))    //Factory Registration

  function new(string name = "apb_read_write_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("crnr_sequence_item");
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;
        if(!READ_WRITE)
          seq.apb_write_paddr == seq.apb_read_paddr;    // same addr for R/W
        else
          foreach(qu[i])
            seq.apb_read_paddr != qu[i];
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(seq.READ_WRITE)
        seq.apb_read_paddr.rand_mode(0);
      else
      begin
        qu.push_front(seq.apb_read_paddr);
        seq.apb_read_paddr.rand_mode(1);
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_read_write_sequence

class apb_transfer_sequence#(int val = 2) extends apb_base_sequence;    //Generates transactions where transfer=0 (no valid transfer)
  `uvm_object_param_utils(apb_transfer_sequence#(val))    //Factory Registration

  function new(string name = "apb_transfer_sequence");
    super.new(name);
    read_prev = 1;    //Started with read
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("transfer_sequence_item");
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 0;    //No transfer
        seq.READ_WRITE != read_prev;
        if(READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        else
          foreach(qu[i])
            seq.apb_write_paddr != qu[i];
        seq.PRESETn == 1;
      })
      else
          `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(!seq.READ_WRITE)
        seq.apb_write_paddr.rand_mode(0);
      else
      begin
        qu.push_front(seq.apb_write_paddr);
        seq.apb_write_paddr.rand_mode(1);
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_transfer_sequence

class apb_write_sequence#(int val = 1) extends apb_base_sequence;    // Generates only write transactions
  `uvm_object_param_utils(apb_write_sequence#(val))    //Factory Registration

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("write_sequence_item");
    repeat(val) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE == 0;
        seq.PRESETn == 1;
        foreach(qu[i])
          seq.apb_write_paddr != qu[i];
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      qu.push_front(seq.apb_write_paddr);
      send_request(seq);
      wait_for_item_done();
    end
  endtask:body
endclass:apb_write_sequence

class apb_read_sequence#(int val = 1) extends apb_base_sequence;    //Generates only read transactions
  `uvm_object_param_utils(apb_read_sequence#(val))    //Factory Registration

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("read_sequence_item");
    repeat(val) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE == 1;    //Read
        seq.PRESETn == 1;
        foreach(qu[i])
          seq.apb_read_paddr != qu[i];
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      qu.push_front(seq.apb_read_paddr);
      send_request(seq);
      wait_for_item_done();
    end
  endtask:body
endclass:apb_read_sequence

class apb_same_sequence#(int val = 2) extends apb_base_sequence;    // Generates repeating transactions with the same field values
  `uvm_object_param_utils(apb_same_sequence#(val))    //Factory Registration
  bit count;

  function new(string name = "apb_same_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("same_sequence_item");
    read_prev = 1;
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.PRESETn == 1;
        seq.READ_WRITE == read_prev;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      $display("read_prev = %0d",read_prev);
      
      if(count>0)
      begin
        count = 0;
        seq.READ_WRITE.rand_mode(1);
        seq.apb_write_paddr.rand_mode(1);
        seq.apb_read_paddr.rand_mode(1);
        read_prev = !seq.READ_WRITE;
      end
      
      else
      begin
        count = 1;
        seq.READ_WRITE.rand_mode(0);
        seq.apb_write_paddr.rand_mode(0);
        seq.apb_read_paddr.rand_mode(0);
      end
      
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_same_sequence 

class apb_diff_slave_sequence#(int val = 2) extends apb_base_sequence;    //Generates read/write operations to different slaves
  `uvm_object_param_utils(apb_diff_slave_sequence#(val))    //Factory Registration
  bit choice,count;
  bit[7:0] prev;

  function new(string name = "apb_diff_slave_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("diff_slave_sequence_item");
    repeat(val) begin:repeat_val
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.PRESETn == 1;
        seq.apb_write_paddr[8] != choice && seq.apb_read_paddr[8] != choice;
        seq.apb_write_paddr == seq.apb_read_paddr;
        if(count)
          seq.apb_write_paddr[7:0] == prev && seq.apb_read_paddr[7:0] == prev;
      })
      else
          `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      choice = seq.READ_WRITE ? seq.apb_write_paddr[8] : seq.apb_read_paddr[8];
      if(count>0)
      begin
        count = 0;
        seq.READ_WRITE.rand_mode(1);
      end
      else
      begin
        prev = seq.apb_write_paddr;
        count++;
        seq.READ_WRITE.rand_mode(0);
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_diff_slave_sequence

/*class apb_one_clock_sequence#(int val = 2) extends apb_base_sequence;    //Generates transactions where transfer=0 after one clock signal
  `uvm_object_param_utils(apb_one_clock_sequence#(val))    //Factory Registration
  int count3;

  function new(string name = "apb_one_clock_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("one_clock_sequence_item");
    seq.change = 0;
    count3 = 0;
    repeat(val) begin:repeat_val
      wait_for_grant();
      seq.change = !seq.transfer;
      assert(seq.randomize() with 
      {
        seq.transfer == seq.change;    //alternate transfer
        soft seq.READ_WRITE != read_prev;
        if(!READ_WRITE)
          soft seq.apb_read_paddr == seq.apb_write_paddr;
        else
          foreach(qu[i])
            soft seq.apb_write_paddr != qu[i];
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      if(count3 > 0)
      begin
        seq.change = 1;
        seq.READ_WRITE.rand_mode(0);
        if(!seq.READ_WRITE)
          seq.apb_read_paddr.rand_mode(0);
        else
          seq.apb_write_paddr.rand_mode(0);
        count3 = 0;
      end
      else
      begin
        seq.change = 0;
        count3++;
        seq.READ_WRITE.rand_mode(1);
        seq.apb_read_paddr.rand_mode(0);
        seq.apb_write_paddr.rand_mode(0);
        if(seq.READ_WRITE)
        begin
          qu.push_front(apb_write_paddr);
          seq.apb_read_paddr.rand_mode(1);
        end
        else
          seq.apb_write_paddr.rand_mode(1);
      end
      read_prev = seq.READ_WRITE;
      if(seq.READ_WRITE)
      begin
        seq.apb_write_paddr.rand_mode(0);
      end
      else
      begin
        qu.push_front(seq.apb_write_paddr);
        seq.apb_write_paddr.rand_mode(1);
      end
      send_request(seq);
      wait_for_item_done();
    end:repeat_val
  endtask:body
endclass:apb_one_clock_sequence
*/

class apb_regress_sequence extends apb_base_sequence;    //Runs a collection of all sequences for full coverage
  apb_write_read_sequence#(1024) seq1;
  apb_reset_sequence#(4) seq2;
  apb_read_write_sequence#(2) seq3;
  apb_transfer_sequence#(3) seq4;
  //apb_write_sequence#(1) seq5;
  //apb_read_sequence#(1) seq6;
  apb_same_sequence#(4) seq7;
  apb_diff_slave_sequence#(4) seq8;
  `uvm_object_utils(apb_regress_sequence)

  function new(string name = "apb_regress_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("base_sequence_item");
    `uvm_info(get_name,"--\tTRYING TO READ BEFORE ANYTHING IS WRITTEN\t--",UVM_MEDIUM)
    `uvm_do(seq3)
    `uvm_info(get_name,"--\tWRITING AND READING ONTO ALL ADDRESSES\t--",UVM_MEDIUM)
    `uvm_do(seq1)
    `uvm_info(get_name,"--\tRESET TRIGGERED DURING EXECUTION\t--",UVM_MEDIUM)
    `uvm_do(seq2)
    `uvm_info(get_name,"--\tTRANSFER == 0\t--",UVM_MEDIUM)
    `uvm_do(seq4)
    //`uvm_do(seq5)
    //`uvm_do(seq6)
    `uvm_info(get_name,"--\tSAME SEQUENCE SENT TWICE TO THE SAME LOCATION\t--",UVM_MEDIUM)
    `uvm_do(seq7)
    `uvm_info(get_name,"--\tSAME SEQUENCE SENT TO A DIFFERENT SLAVE\t--",UVM_MEDIUM)
    `uvm_do(seq8)
  endtask:body
endclass:apb_regress_sequence
