//need to add a queue to not repest values while writing
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
      req.READ_WRITE != $past(req.READ_WRITE);
      if(!READ_WRITE)
        req.apb_read_addr == req.apb_write_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  function void post_randomize();
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
      req.READ_WRITE != $past(req.READ_WRITE);
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
  endfunction

  function void body();
    req = apb_sequence_item::type_id::create("crnr_sequence_item");
    wait_for_grant();
    req.randomize() with 
    {
      req.transfer == 1;
      req.READ_WRITE != $past(req.READ_WRITE);
      if(READ_WRITE)
        req.apb_write_addr == req.apb_read_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction

  function void post_randomize();
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
      req.READ_WRITE != $past(req.READ_WRITE);
      if(!READ_WRITE)
        req.apb_read_addr == req.apb_write_addr;
      req.PRESETn == 1;
    }
    send_request(req);
    wait_for_item_done();
  endfunction
endclass

//NEED TO WRITE FROM HERE
class apb_write_write_sequence extends apb_write_read_sequence;
  `uvm_object_utils(apb_write_read_sequence)

  function new(string name = "apb_write_write_sequence");
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
    if(req.READ_WRITE)
      req.apb_write_addr.rand_mode(0);
    else
      req.apb_write_addr.rand_mode(1);
  endfunction
endclass
