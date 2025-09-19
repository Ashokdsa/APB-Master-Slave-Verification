 endclocking
  
  //clock toggle assertion
  property p1;
    @(posedge clk) clk != $past(1, clk);
  endproperty
  assert property(p1)begin
    $info("Pass Toggle CLK");
  end
  else begin
    $info("Fail Toggle CLK");
  end
  
  //valid inputs
  property p2;
    @(posedge clk) transfer |-> not($isunknown({READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data}));
  endproperty
  assert property(p2)begin
    $info("Pass VALID IP");
  end
  else begin
    $info("Fail VALID IP");
  end
  
  //PRESETn
  property p3;
    @(posedge clk) !PRESETn |-> (PSLVERR == 0 && apb_read_data_out == 0);
  endproperty
  assert property(p3)begin
    $info("Pass RESET");
  end
  else begin
    $info("Fail RESET");
  end
  
  //SLVERR
  property p4;
    @(posedge clk) transfer |-> (($isunknown(apb_write_data) && READ_WRITE == 1) || ($isunknown(apb_write_paddr) && READ_WRITE == 1) || ($isunknown(apb_read_paddr) && READ_WRITE == 0));
  endproperty
  
  assert property(p4)begin
    $info("Pass ERR");
  end
  else begin
    $info("Fail ERR");
  end
    
endinterface
