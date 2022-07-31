//.............................................................................................//
//Date: 11 August 2014
//Name of Module: Test bench for I2C Master
//.............................................................................................//

module i2c_master_tb();

wire c_sda ;			
wire c_scl ;			

wire [7:0] rd_slave ; 	

reg sda ;			
reg scl ;	
reg clk ;			
reg rs ;			
reg rw ;			
reg [6:0] s_add ; 		
reg [7:0] wr_slave ;		
reg [7:0] byte_ct ;		
reg st ;			

i2c_master i2c_m(c_sda,c_scl,rd_slave,sda,scl,clk,rs,rw,s_add,wr_slave,byte_ct,st);

initial
begin
	clk=0;
	rs=1; #1
	rs=0; #1
	rs=1;
end

always #5 clk=~clk;
initial #55000 $finish;

always @ (c_scl) scl = c_scl ;	// same scl clock
 
always @ ( negedge scl )	//block to give ack signals
begin
 if ( i2c_m.ct_bit==0 | i2c_m.ct_rbit==0 )
  sda = 0 ;
 else
  sda = 1 ;
end

initial
begin
 $dumpfile("dump.vcd");
 $dumpvars(0,i2c_master_tb);
end

//...........................................................................................................................................................
initial				// initial block to verify start, send and stop operation
begin
st = 0 ;
#42 ;
s_add = 7'b1100101;
byte_ct = 3 ;			//to transmit number of bytes
wr_slave = 8'b01011010 ;	// data to be transmited
rw = 0 ;
st = 1 ;
#100;
st = 0 ;			// to don't restart transmision after once completed
end
//...........................................................................................................................................................

//assign sda = (i2c_m.ct_bit) == 0 ? 0 : 1'bz ;	// this statement is added to behave like, slave is providing ack signal after every 8 bit 
						// 'i2c_m.ct_bit' will behave like enable signal - this statement required with inout port

//always if ((i2c_m.ct_bit) == 0 ) force sda = 0 ; else force sda = 1'bz ;
//..........................................................................................................................................................
initial 			// initial block to verify receive operation
begin
#15000 ; 			// wait for this much time to verify transmision
st = 0 ;
#32 ;
s_add = 7'b1011101;
byte_ct = 3 ;		//to receive number of bytes
rw = 1 ;
st = 1 ;
#100;
st = 0 ;		// to don't restart receiving after once received all required data
end
//...........................................................................................................................................................

//...........................................................................................................................................................
initial 			// initial block to verify stop condition from slave
begin
#32000 ; 			// wait for this much time to verify transmision
st = 0 ;
#32 ;
s_add = 7'b1011101;
byte_ct = 3 ;		//to receive number of bytes
rw = 1 ;
st = 1 ;
#100;
st = 0 ;		// to don't restart receiving after once received all required data
end
//...........................................................................................................................................................

//...........................................................................................................................................................
initial 			// initial block to verify reset condition
begin
#30000 ; 			// wait for this much time to verify transmision
st = 0 ;
#32 ;
s_add = 7'b1011101;
byte_ct = 3 ;		//to receive number of bytes
rw = 1 ;
st = 1 ;
#100;
st = 0 ;		// to don't restart receiving after once received all required data
#1000 ;
rs = 0 ;
#10
rs = 1 ;
end
//...........................................................................................................................................................

endmodule
