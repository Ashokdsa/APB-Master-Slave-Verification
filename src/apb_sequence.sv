//Need to add a queue to not repeat values while writing
//Apb Sequence generates read-write sequences

class apb_write_read_sequence extends uvm_sequence#(apb_sequence_item);    //Generates both write and read transactions alternately
  `uvm_object_utils(apb_write_read_sequence)    //Factory Registration
  apb_sequence_item seq;
  bit read_prev;

  function new(string name = "apb_write_read_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("base_sequence_item");
    repeat(2) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;    // alternate read/write
        if(!READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(seq.READ_WRITE)
        seq.apb_write_paddr.rand_mode(0);     // Freeze addr after write
      else
        seq.apb_write_paddr.rand_mode(1);    // Allow addr change otherwise
      send_request(seq);
      wait_for_item_done();
    end:repeat
  endtask:body
endclass:apb_write_read_sequence

class apb_reset_sequence extends apb_write_read_sequence;    //Generates reset scenarios by de-asserting PRESETn
  `uvm_object_utils(apb_reset_sequence)    //Factory Registration

  function new(string name = "apb_reset_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("reset_sequence_item");
    repeat(4) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;
        if(!READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
      })
      else
          `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(seq.READ_WRITE)
        seq.apb_write_paddr.rand_mode(0);
      else
        seq.apb_write_paddr.rand_mode(1);
      send_request(seq);
      wait_for_item_done();
    end:repeat
  endtask:body
endclass:apb_reset_sequence

class apb_read_write_sequence extends apb_write_read_sequence;    //- Forces alternate read and write operations at the same address
  `uvm_object_utils(apb_read_write_sequence)    //Factory Registration

  function new(string name = "apb_read_write_sequence");
    super.new(name);
    read_prev = 1;    //Started with write
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("crnr_sequence_item");
    repeat(3) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;
        if(READ_WRITE)
          seq.apb_write_paddr == seq.apb_read_paddr;    // same addr for R/W
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(!seq.READ_WRITE)
        seq.apb_read_paddr.rand_mode(0);
      else
        seq.apb_read_paddr.rand_mode(1);
      send_request(seq);
      wait_for_item_done();
    end:repeat
  endtask:body
endclass:apb_read_write_sequence

class apb_transfer_sequence extends apb_write_read_sequence;    //Generates transactions where transfer=0 (no valid transfer)
  `uvm_object_utils(apb_transfer_sequence)    //Factory Registration

  function new(string name = "apb_transfer_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("transfer_sequence_item");
    repeat(3) begin
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 0;    //No transfer
        seq.READ_WRITE != read_prev;
        if(!READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        seq.PRESETn == 1;
      })
      else
          `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      if(seq.READ_WRITE)
        seq.apb_write_paddr.rand_mode(0);
      else
        seq.apb_write_paddr.rand_mode(1);
      send_request(seq);
      wait_for_item_done();
    end:repeat
  endtask:body
endclass:apb_transfer_sequence

class apb_write_sequence extends apb_write_read_sequence;    // Generates only write transactions
  `uvm_object_utils(apb_write_sequence)    //Factory Registration

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("write_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.READ_WRITE == 1;
      seq.PRESETn == 1;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask:body
endclass:apb_write_sequence

class apb_read_sequence extends apb_write_read_sequence;    //Generates only read transactions
  `uvm_object_utils(apb_read_sequence)    //Factory Registration

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("read_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.READ_WRITE == 0;    //Read
      seq.PRESETn == 1;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask:body
endclass:apb_read_sequence

class apb_same_sequence extends apb_write_read_sequence;    // Generates repeating transactions with the same field values
  `uvm_object_utils(apb_same_sequence)    //Factory Registration
  bit count;

  function new(string name = "apb_same_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("same_sequence_item");
    read_prev = 1;
    repeat(4) begin
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
    end:repeat
  endtask:body
endclass:apb_same_sequence 

class apb_diff_slave_sequence extends apb_write_read_sequence;    //Generates read/write operations to different slaves
  `uvm_object_utils(apb_diff_slave_sequence)    //Factory Registration
  bit choice,count;
  bit[7:0] prev;

  function new(string name = "apb_diff_slave_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("diff_slave_sequence_item");
    repeat(5) begin
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
    end:repeat
  endtask:body
endclass:apb_diff_slave_sequence

class apb_regress_sequence extends apb_write_read_sequence;    //Runs a collection of all sequences for full coverage
  apb_write_read_sequence seq1;
  apb_reset_sequence seq2;
  apb_read_write_sequence seq3;
  apb_transfer_sequence seq4;
  apb_write_sequence seq5;
  apb_read_sequence seq6;
  apb_same_sequence seq7;
  apb_diff_slave_sequence seq8;
  `uvm_object_utils(apb_regress_sequence)

  function new(string name = "apb_regress_sequence");
    super.new(name);
  endfunction:new

  task body();
    seq = apb_sequence_item::type_id::create("base_sequence_item");
    `uvm_do(seq1)
    //`uvm_do(seq2)
    //`uvm_do(seq3)
    //`uvm_do(seq4)
    //`uvm_do(seq5)
    //`uvm_do(seq6)
    //`uvm_do(seq7)
    //`uvm_do(seq8)
  endtask:body
endclass:apb_regress_sequence
