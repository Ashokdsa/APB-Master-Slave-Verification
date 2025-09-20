//need to add a queue to not repeat values while writing
class apb_write_read_sequence extends uvm_sequence#(apb_sequence_item);
  `uvm_object_utils(apb_write_read_sequence)
  apb_sequence_item seq;
  bit read_prev;

  function new(string name = "apb_write_read_sequence");
    super.new(name);
  endfunction

  task body();
    repeat(2) begin
      seq = apb_sequence_item::type_id::create("base_sequence_item");
      wait_for_grant();
      assert(seq.randomize() with 
      {
        seq.transfer == 1;
        seq.READ_WRITE != read_prev;
        if(!READ_WRITE)
          seq.apb_read_paddr == seq.apb_write_paddr;
        seq.PRESETn == 1;
      })
      else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
      read_prev = seq.READ_WRITE;
      send_request(seq);
      wait_for_item_done();
    end
  endtask


  function void post_randomize();
    if(seq.READ_WRITE)
      seq.apb_write_paddr.rand_mode(0);
    else
      seq.apb_write_paddr.rand_mode(1);
  endfunction
endclass

class apb_reset_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_reset_sequence)

  function new(string name = "apb_reset_sequence");
    super.new(name);
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("reset_sequence_item");
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
    send_request(seq);
    wait_for_item_done();
  endtask

  function void post_randomize();
    if(seq.READ_WRITE)
      seq.apb_write_paddr.rand_mode(0);
    else
      seq.apb_write_paddr.rand_mode(1);
  endfunction
endclass

class apb_read_write_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_read_write_sequence)

  function new(string name = "apb_read_write_sequence");
    super.new(name);
    read_prev = 1;
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("crnr_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.READ_WRITE != read_prev;
      if(READ_WRITE)
        seq.apb_write_paddr == seq.apb_read_paddr;
      seq.PRESETn == 1;
    })
    else
      `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask

  function void post_randomize();
    if(!seq.READ_WRITE)
      seq.apb_read_paddr.rand_mode(0);
    else
      seq.apb_read_paddr.rand_mode(1);
  endfunction
endclass

class apb_transfer_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_transfer_sequence)

  function new(string name = "apb_transfer_sequence");
    super.new(name);
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("transfer_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 0;
      seq.READ_WRITE != read_prev;
      if(!READ_WRITE)
        seq.apb_read_paddr == seq.apb_write_paddr;
      seq.PRESETn == 1;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask

  function void post_randomize();
    if(seq.READ_WRITE)
      seq.apb_write_paddr.rand_mode(0);
    else
      seq.apb_write_paddr.rand_mode(1);
  endfunction
endclass

class apb_write_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_write_sequence)

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction

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
  endtask

  function void post_randomize();
    seq.apb_write_paddr.rand_mode(1);
  endfunction
endclass

class apb_read_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_read_sequence)

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("read_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.READ_WRITE == 0;
      seq.PRESETn == 1;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask

  function void post_randomize();
    seq.apb_write_paddr.rand_mode(1);
  endfunction
endclass

class apb_same_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_same_sequence)

  function new(string name = "apb_same_sequence");
    super.new(name);
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("same_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.PRESETn == 1;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask

  bit count;

  function void post_randomize();
    if(count>0)
    begin
      count = 0;
      seq.READ_WRITE.rand_mode(1);
      seq.apb_write_paddr.rand_mode(1);
      seq.apb_read_paddr.rand_mode(1);
    end
    else
    begin
      count++;
      seq.READ_WRITE.rand_mode(0);
      seq.apb_write_paddr.rand_mode(0);
      seq.apb_read_paddr.rand_mode(0);
    end
  endfunction
endclass

class apb_diff_slave_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_diff_slave_sequence)

  function new(string name = "apb_diff_slave_sequence");
    super.new(name);
  endfunction

  task body();
    seq = apb_sequence_item::type_id::create("diff_slave_sequence_item");
    wait_for_grant();
    assert(seq.randomize() with 
    {
      seq.transfer == 1;
      seq.PRESETn == 1;
      seq.apb_write_paddr[8] != choice && seq.apb_read_paddr[8] != choice;
      if(count)
        seq.apb_write_paddr[7:0] == prev && seq.apb_read_paddr[7:0] == prev;
    })
    else
        `uvm_fatal(get_name,"RANDOMIZATION FAILED");
    read_prev = seq.READ_WRITE;
    send_request(seq);
    wait_for_item_done();
  endtask

  bit choice,count;
  bit[7:0] prev;

  function void post_randomize();
    choice = seq.READ_WRITE ? seq.apb_write_paddr[8] : seq.apb_read_paddr[8];
    if(count>0)
    begin
      count = 0;
      seq.READ_WRITE.rand_mode(1);
    end
    else
    begin
      prev = 
      count++;
      seq.READ_WRITE.rand_mode(0);
    end
  endfunction
endclass

class apb_regress_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_regress_sequence)
  apb_write_read_sequence seq1;
  apb_reset_sequence seq2;
  apb_read_write_sequence seq3;
  apb_transfer_sequence seq4;
  apb_write_sequence seq5;
  apb_read_sequence seq6;
  apb_same_sequence seq7;
  apb_diff_slave_sequence seq8;

  function new(string name = "apb_regress_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_do(seq1)
    `uvm_do(seq2)
    `uvm_do(seq3)
    `uvm_do(seq4)
    `uvm_do(seq5)
    `uvm_do(seq6)
    `uvm_do(seq7)
    `uvm_do(seq8)
  endtask

  function void post_randomize();
    $display("nothing same");
  endfunction
endclass
