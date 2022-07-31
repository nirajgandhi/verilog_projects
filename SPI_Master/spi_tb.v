

`include "spi.v"

module spi_tb;
	reg  clk; 
	reg miso;
	reg rst;
	reg write_back_finish;
	reg [7:0]rdata;
	reg [1:0]c_div;
	reg lsb_msb;
	reg start;

	wire mosi;
	wire sclk;
	wire ss;
	wire done;
	wire [7:0]tdata;


 spi_master uut(mosi,sclk,ss,tdata,done,miso,rdata,c_div,lsb_msb,start,write_back_finish,clk,rst);

	initial
	begin
		clk = 0; rst = 1; rdata = 8'd0;
		#10 rst = 0;
		#20 rst = 1;lsb_msb = 0; start = 0; c_div = 2'b00; miso = 0;

		#10 start = 1; lsb_msb = 1; rdata = 8'd1; write_back_finish = 0;
		#20 start = 0;
		#5000000 $finish;
	end

	always@(negedge spi_tb.uut.tx_rx_finish) 
		write_back_finish = 1'b1;

	always@(negedge spi_tb.uut.sclk)
	begin
		if(spi_tb.uut.tx_rx == 1'b1 && spi_tb.uut.tx_rx_finish != 1'b1) 
		begin
			if (spi_tb.uut.shift_count < 4'd8) miso = ~miso;
		end
	end

	always@(posedge write_back_finish)
	begin
		#20 write_back_finish = 1'b0;
		#10 start = 1; lsb_msb = ~lsb_msb; rdata = ~rdata; c_div = c_div + 1;

		#20 start = 0;
	
	end

	initial begin
		$dumpfile("SPI_master.vcd");
		$dumpvars(0,spi_tb);

	end


	always #5 clk = ~clk;
endmodule

