interface inf(input bit clk);
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
  
endinterface
