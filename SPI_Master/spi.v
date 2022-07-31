/*
Name : 
Date : 	31st july,2014
Description : The module is for SPI master which provides the interface between the processor and the slave peripherals.
*/

module spi_master( mosi,sclk,ss,tdata,done,miso,rdata,c_div,lsb_msb,start,write_back_finish,clk,rst);

//----------Output Ports--------------
	output reg mosi;
	output reg sclk;
	output reg ss;
	output done;
	output reg [7:0]tdata;
//------------Input Ports--------------
        input  clk; 
	input miso;
	input rst;
	input write_back_finish;
	input [7:0]rdata;
	input [1:0]c_div;
	input lsb_msb;
	input start;
//parameter...

parameter s_idle = 2'b00;
parameter s_load = 2'b01;
parameter s_tx_rx = 2'b10;
parameter s_wait = 2'b11;

parameter high = 1'b1;
parameter low = 1'b0;
//------------Internal Variables--------
      
reg [1:0] ps;
reg [1:0] ns;
//reg i;
reg load_finish, tx_rx, tx_rx_finish, load; 
reg [7:0] shift_reg;
//reg [7:0] control_reg = { 6'b00_0000, load, tx_rx};
//reg [7:0] status_reg = {6'b00_0000, load_finish, tx_rx_finish};

wire [7:0] control_reg;
wire [7:0] status_reg;

reg [4:0] clk_count;
reg [3:0] shift_count;

reg [4:0] mid;
//-------------Code Starts Here-------
//initial i=in;

assign control_reg = {6'b00_0000, load, tx_rx};
assign status_reg = {6'b00_0000, load_finish, tx_rx_finish};

always@(ps,start,load_finish,tx_rx_finish,write_back_finish)
begin
	case(ps)

	s_idle: ns =  start ? s_load : s_idle;
	s_load: ns =  load_finish ? s_tx_rx : s_load ; 
	s_tx_rx: ns = tx_rx_finish ? s_wait : s_tx_rx ; 
	s_wait:  ns = write_back_finish ?  s_idle : s_wait;  

	endcase
end

always@(ps, ns)
begin
	case(ps)

	s_idle:	begin
			load = low;
			tx_rx = low;			
			load_finish = low;
			tx_rx_finish = low;
			mid = 5'd0;
			clk_count = 5'd0;
			shift_count = 4'd0;
			ss = high;
		//	write_back = low;
		end
	s_load:  begin
			case(c_div)
				2'b00 : mid = 5'd2;
				2'b01 : mid = 5'd4;
				2'b10 : mid = 5'd8;
				2'b11 : mid = 5'd16;
			endcase		
			load = high;			
			ss = high;
		//	write_back = low;
		end

	s_tx_rx:begin
			load = low;
			load_finish = low;
			tx_rx = high;
		//	tx_rx_finish = low;
			ss = low;
		//	write_back = low;
		end

	s_wait:	begin
			load = low;
			load_finish = low;
			tx_rx = low;
			tx_rx_finish = low;
			ss = high;
		//	write_back = high;
		end	
	endcase
end


always @(posedge clk,negedge rst)
begin	
	if(!rst) begin
		ps <= s_idle;
	end

	else begin
		ps <= ns;
	end
end

//assign out = ps[0] & ps[1] & ~in;


//********************************** load data from processor **************************

always@(posedge clk)	
begin
	if(load) shift_reg <= rdata; //// latch

 
	if(load)load_finish <= high; // mux
	else load_finish <= low;

end

//********************************* tx and rx data from/to master ***********************

always@(posedge sclk)
begin
	if(tx_rx == high && shift_count != 4'b1000)
	begin
		case(lsb_msb)
			low: begin
				mosi <= shift_reg[0];
				shift_reg <= {miso,shift_reg[7:1]};	
				shift_count <= shift_count + 1;
			end
			
			high: begin
				mosi <= shift_reg[7];
				shift_reg <= {shift_reg[6:0],miso};	
				shift_count <= shift_count + 1;
			end
	
		endcase
		tx_rx_finish = low;
	end

	else if (shift_count == 4'b1000) tx_rx_finish = high;

	else tx_rx_finish = low;
end


//********************************* write back data to processor **************************

always@(posedge tx_rx_finish)
begin
	tdata <= shift_reg; // latch 
end



//********************************* clock divison block **********************************

always@(posedge clk)
begin
	clk_count = clk_count +1;
	case(mid)
		5'd2 : sclk = clk_count[1];	// sclk = clock/2
		5'd4 : sclk = clk_count[2];	// sclk = clock/4 
		5'd8 : sclk = clk_count[3];	// sclk = clock/8
		5'd16: sclk = clk_count[4];	// sclk = clock/16
		default : sclk = clk_count[1];	// default is sclk = clock/2
	endcase
end


assign done = (write_back_finish)? high : low ;

endmodule 
