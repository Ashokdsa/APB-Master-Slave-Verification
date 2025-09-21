interface apb_inf(input bit clk);
  //input
  logic PCLK, PRESETn, transfer, READ_WRITE;
  logic [8:0] apb_write_paddr;
  logic [7:0]apb_write_data;
  logic [8:0] apb_read_paddr;
  logic PSLVERR;
  logic [7:0] apb_read_data_out;
  
  clocking drv_cb @(posedge clk);
    output PRESETn, transfer, READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data;
  endclocking
  
  clocking p_mon_cb@(posedge clk);
    input PSLVERR, apb_read_data_out;
  endclocking
  
  clocking a_mon_cb@(posedge clk);
	  output PRESETn, transfer, READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data;
  endclocking
  
  //clock toggle assertion
  property p1;
    @(posedge clk) clk != $past(1, clk);
  endproperty
  assert property(p1)begin
    //`uvm_info("Pass Toggle CLK");
  end
  else begin
    //`uvm_error("Fail Toggle CLK");
  end
  
  //valid inputs
  property p2;
    @(posedge clk) transfer |-> not($isunknown({READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data}));
  endproperty
  assert property(p2)begin
    //`uvm_info("Pass VALID IP");
  end
  else begin
    //`uvm_error("Fail VALID IP");
  end
  
  //PRESETn
  property p3;
    @(posedge clk) !PRESETn |-> (PSLVERR == 0 && apb_read_data_out == 0);
  endproperty
  assert property(p3)begin
    //`uvm_info("Pass RESET");
  end
  else begin
    //`uvm_error("Fail RESET");
  end
  
  //SLVERR
  property p4;
    @(posedge clk) transfer |-> (($isunknown(apb_write_data) && READ_WRITE == 1) || ($isunknown(apb_write_paddr) && READ_WRITE == 1) || ($isunknown(apb_read_paddr) && READ_WRITE == 0));
  endproperty
  
  assert property(p4)begin
    //`uvm_info("Pass ERR");
  end
  else begin
    //`uvm_error("Fail ERR");
  end
    
endinterface
