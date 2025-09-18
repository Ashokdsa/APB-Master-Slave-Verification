//need to add a queue to not repeat values while writing
class apb_write_read_sequence extends uvm_sequence#(apb_sequence_item);
  `uvm_object_utils(apb_write_read_sequence)

  function new(string name = "apb_write_read_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("base_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE != read_prev;
      if(!READ_WRITE)
        req.apb_read_addr == req.apb_write_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  bit read_prev;

  function void post_randomize();
    read_prev = ~read_prev;
    if(req.READ_WRITE)
      req.apb_write_addr.rand_mode(0);
    else
      req.apb_write_addr.rand_mode(1);
  endfunction
endclass

class apb_reset_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_reset_sequence)

  function new(string name = "apb_reset_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("reset_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE != read_prev;
      if(!READ_WRITE)
        req.apb_read_addr == req.apb_write_addr;
    }
    send_request(req);
    wait_for_item_done();
  endfunction
endclass

class apb_read_write_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_read_write_sequence)

  function new(string name = "apb_read_write_sequence");
    super.new(name);
    read_prev = 1;
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("crnr_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE != read_prev;
      if(READ_WRITE)
        req.apb_write_addr == req.apb_read_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  function void post_randomize();
    read_prev = ~read_prev;
    if(!req.READ_WRITE)
      req.apb_read_addr.rand_mode(0);
    else
      req.apb_read_addr.rand_mode(1);
  endfunction
endclass

class apb_transfer_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_transfer_sequence)

  function new(string name = "apb_transfer_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("transfer_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 0;
      req.READ_WRITE != read_prev;
      if(!READ_WRITE)
        req.apb_read_addr == req.apb_write_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction
endclass

class apb_write_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_write_sequence)

  function new(string name = "apb_write_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("write_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE == 1;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  function void post_randomize();
    req.apb_write_addr.rand_mode(1);
  endfunction
endclass

class apb_read_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_read_sequence)

  function new(string name = "apb_read_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("read_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE == 0;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  function void post_randomize();
    req.apb_write_addr.rand_mode(1);
  endfunction
endclass

class apb_same_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_same_sequence)

  function new(string name = "apb_same_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("same_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  bit count;

  function void post_randomize();
    if(count>0)
    begin
      count = 0;
      req.READ_WRITE.rand_mode(1);
      req.apb_write_addr.rand_mode(1);
      req.apb_read_addr.rand_mode(1);
    end
    else
    begin
      count++;
      req.READ_WRITE.rand_mode(0);
      req.apb_write_addr.rand_mode(0);
      req.apb_read_addr.rand_mode(0);
    end
  endfunction
endclass

class apb_diff_slave_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_diff_slave_sequence)

  function new(string name = "apb_diff_slave_sequence");
    super.new(name);
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("diff_slave_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.PRESETn == 1;
      req.apb_write_addr[8] != choice && req.apb_read_addr[8] != choice;
      if(count)
        req.apb_write_addr[7:0] == prev && req.apb_read_addr[7:0] == prev;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  bit choice,count;
  bit[7:0] prev;

  function void post_randomize();
    choice = req.READ_WRITE ? req.apb_write_addr[8] : req.apb_read_addr[8];
    if(count>0)
    begin
      count = 0;
      req.READ_WRITE.rand_mode(1);
    end
    else
    begin
      prev = 
      count++;
      req.READ_WRITE.rand_mode(0);
    end
  endfunction
endclass
