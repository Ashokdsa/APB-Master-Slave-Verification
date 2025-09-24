// APB Interface: defines DUT signal connections, clocking blocks, and protocol assertions
interface apb_inf(input bit clk);
	
   //------------------------------------------------------------------------------------------
  // DUT Signal Declarations
  //------------------------------------------------------------------------------------------
  logic PCLK, PRESETn, transfer, READ_WRITE;
  logic [8:0] apb_write_paddr;
  logic [7:0]apb_write_data;
  logic [8:0] apb_read_paddr;
  logic PSLVERR;
  logic [7:0] apb_read_data_out;

 //------------------------------------------------------------------------------------------
  // Clocking Blocks
  //------------------------------------------------------------------------------------------
  clocking drv_cb @(posedge clk);	// Driver clocking block
    output PRESETn, transfer, READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data;
  endclocking
  
  clocking p_mon_cb@(posedge clk);	// Passive monitor clocking block
    input PSLVERR, apb_read_data_out;
  endclocking
  
  clocking a_mon_cb@(posedge clk);	// Active monitor clocking block
	  input PRESETn, transfer, READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data;
  endclocking
  
  //------------------------------------------------------------------------------------------
  // Assertions
  //------------------------------------------------------------------------------------------
  property p1;		 // Assertion p1: Check if clock toggles properly
    @(posedge clk) clk != $past(1, clk);
  endproperty:p1
  assert property(p1)begin
    $info("Pass Toggle CLK");
  end
  else begin
    $error("Fail Toggle CLK");
  end
  
  property p2;		// Assertion p2: Valid input check when transfer is active
    @(posedge clk) transfer |-> not($isunknown({READ_WRITE, apb_write_paddr, apb_read_paddr, apb_write_data}));
  endproperty:p2
  assert property(p2)begin
    $info("Pass VALID IP");
  end
  else begin
    $error("Fail VALID IP");
  end
  
  property p3;		// Assertion p3: Reset behavior check
    @(posedge clk) !PRESETn |-> (PSLVERR == 0 && apb_read_data_out == 0);
  endproperty:p3
  assert property(p3)begin
    $info("Pass RESET");
  end
  else begin
    $error("Fail RESET");
  end
  
  property p4;		// Assertion p4: Slave error condition check
	  @(posedge clk) transfer |-> (($isunknown(apb_write_data) && !READ_WRITE) || ($isunknown(apb_write_paddr) && !READ_WRITE) || ($isunknown(apb_read_paddr) && READ_WRITE)) |=> PSLVERR;
  endproperty:p4
  
  assert property(p4)begin
    $info("Pass ERR");
  end
  else begin
    $error("Fail ERR");
  end

  property p5;
    @(posedge clk)
    ((transfer && READ_WRITE)) ##1 first_match(($stable(apb_read_paddr) && READ_WRITE)[*2]);
  endproperty

  property p6;
    @(posedge clk) 
    ((transfer && !READ_WRITE)) ##1 first_match(($stable({apb_write_paddr,apb_write_data}) && !READ_WRITE)[*2]);
  endproperty
  
  assert property(p5) begin $info("READ INPUTS ARE STABLE"); end else begin $warning("READ INPUTS ARE NOT STABLE"); end
  assert property(p6) begin $info("WRITE INPUTS ARE STABLE"); end else begin $warning("WRITE INPUTS ARE NOT STABLE"); end
endinterface:apb_inf
