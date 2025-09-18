interface inf(input bit clk);
  //input
  logic PRESETn, TRANSFER, READ_WRITE;
  logic [8:0] PWADDR, PRADDR;
  logic [7:0] PWDATA;
  //output
  logic [7:0] DATA_OUT;
  logic PSLVERR;
  
  clocking drv_cb @(posedge clk);
    output PRESETn, TRANSFER, READ_WRITE, PWADDR, PRADDR, PWDATA;
  endclocking
  
  clocking p_mon_cb@(posedge clk);
    input PSLVERR, DATA_OUT;
  endclocking
  
  clocking a_mon_cb@(posedge clk);
    input PRESETn, TRANSFER, READ_WRITE, PWADDR, PRADDR, PWDATA;
  endclocking
  
endinterface
