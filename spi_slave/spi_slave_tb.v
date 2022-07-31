// Code your testbench here
// SPI slave mode 3 test bench

module spi_slave_tb ();

//wire declaration
 wire miso;
 wire [7:0] rxr;
 wire rdone;
 wire tdone;

//reg declaration
 reg mosi;
 reg [7:0] txr;
 reg mol=1;
 reg sck;
 reg ss;
 reg rst;

//calling DUT
 spi_slave j1 (miso,rxr,rdone,tdone,mosi,txr,sck,ss,mol,rst);

//giving inputs
 initial
  begin
  sck=1'b0; ss=1'b0; rst=1'b1; #1 rst=1'b0; #3 rst=1'b1;
  #1 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b1;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b0;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #8 ss=1'b1;
  #10 ss=1'b0;
  #2 txr = 8'd89;
  #20 txr = 8'd12;
  #18 ss=1'b1;
  #30 ss=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b0; txr=8'd107;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b1;
  #2 mosi=1'b1;
  #2 mosi=1'b1;
  #2 mosi=1'b0;
  #2 mosi=1'b0;
  #2 mosi=1'b0;
  #2 mosi=1'b1; ss=1'b1;
  #10 $finish;
  end

 always #2 sck = ~sck;

 initial
  begin
  $dumpvars (0,spi_slave_tb);
    $dumpfile ("dump.vcd");
  end

endmodule
