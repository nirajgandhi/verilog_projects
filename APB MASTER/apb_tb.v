// Code your testbench here
module apb_tb() ;

// Input output port declarations
reg PCLK,PRESETn,PREADY,transfer,READ_WRITE_DATA;

//Environment side input 
  reg [31:0] ahb_write_add,ahb_write_data,ahb_read_add,PRDATA;

  wire [31:0] PADDR,PWDATA,ahb_read_data_out;
wire PWRITE,PSEL,PENABLE;


  apb apb1(ahb_write_add,ahb_write_data,transfer,ahb_read_add,ahb_read_data_out,PCLK,PRESETn,PREADY,PADDR,PWRITE,PWDATA,PRDATA,PSEL,PENABLE,READ_WRITE_DATA);

initial
begin
PRESETn = 0;
PREADY = 0;
transfer = 0;
PCLK = 0;
READ_WRITE_DATA = 1;
PRDATA = 0;
ahb_write_add = 32'h00;
ahb_write_data = 32'h45;
PRDATA = 32'b0;
#10 PRESETn = 1;
#20 transfer = 1;
#30 PREADY = 1;
    transfer = 0;
#10 PREADY = 0;
#20 ahb_write_add = 32'h04;
    ahb_write_data = 32'h55;
#10 transfer =1;
#30 PREADY = 1;
    transfer = 0;
#20 PREADY = 0;
#10 ahb_write_add = 32'h01;
    ahb_write_data = 32'h65;
#10 transfer =1;
#30 PREADY = 1;
    transfer = 0;
#20 PREADY = 0;
#20 READ_WRITE_DATA = 0;
#20 ahb_read_add = 32'h04;
#10 transfer = 1;
#30 PREADY = 1;
    transfer = 0;
#10 PREADY = 0;
#20 ahb_read_add = 32'h01;
#10 transfer = 1;
#30 PREADY = 1;
    transfer = 0;
#10 PREADY = 0;
#20 ahb_read_add = 32'h03;
#10 transfer = 1;
#30 PREADY = 1;
    transfer = 0;
#10 PREADY = 0;
#20 ahb_read_add = 32'h00;
#10 transfer = 1;
#30 PREADY = 1;
    transfer = 0;
#10 PREADY = 0;
#20 ahb_read_add = 32'h05;
#10 transfer = 1;
#30 PREADY = 1;
    transfer = 0;

//#30 PREADY = 1;
//#20 transfer = 0;
//#20 PREADY = 0;
end
 
always #5 PCLK = ~ PCLK;

initial #800 $finish;

initial
begin
 $dumpvars(0, apb_tb);
 $dumpfile("tb.vcd");
  end

endmodule




           
    
