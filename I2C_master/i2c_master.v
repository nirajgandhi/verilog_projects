//.............................................................................................//
//Date: 11 August 2014
//Name of Module: I2C Master
//.............................................................................................//

module i2c_master (c_sda,c_scl,rd_slave,sda,scl,clk,rs,rw,s_add,wr_slave,byte_ct,st);

//I2C bus signals declarations...............................................................
output c_sda ; 	// control signal for sda -in hardware it will go to nMOS (after inverted) -also possible to make, that it go in bufif0 of sda(inout)
output c_scl ; 		// control signal for scl -in hardware it will go to nMOS (after inverted)
input sda ;			// no need to declare as 'inout' because to give output data I have used control signal c_sda & c_scl
input scl ;			// 400 KHz => 8 MHz / 20 ;

//Output declarations.......................................................................
output reg [7:0] rd_slave ; 	// data read from slave and give as output

//Input declarations........................................................................
input clk ;			// here, system clock is considered as 8 MHz
input rs ;			// reset
input rw ;			// read/write , write if rw = 0, else read
input [6:0] s_add ; 		// slave address
//input [7:0] reg_p ;		// reg pointer to give address to slave
input [7:0] wr_slave ;		// write data - to slave - when rw = 0 
input [7:0] byte_ct ;		// gives number of bytes needs to transmit / receive
input st ;			// to start transmision - if 'st=1' => master will go to start state

//reg declarations..........................................................................
reg c_sda ; 			// control signal for sda -in hardware it will go to nMOS (after inverted), it will go in bufif0 of sda(inout)
reg c_scl ; 			// control signal for scl -in hardware it will go to nMOS (after inverted), it will go in bufif0 of scl(inout)
reg [4:0] ct_div ;		// for counter of clock devider logic
reg [7:0] ct_stop ;		// for counter - to detect stop condition - when ct_s equals byte_ct then stop condition occurs
reg [3:0] ct_bit ;		// for counter - to count bit transmited
reg [3:0] ct_rbit ;		// for counter while receiving data from slave
reg [2:0] ps ;
reg [2:0] ns ;
reg e_scl ;			// serial clock (scl) enable signal - make this signal high after start condition occurs
//reg s_flag ;			// start flag, once transmision starts it will be 0
reg tx_flag ;			// stop transmision after 8 bit transmited, it will be 0 to wait for ack
reg rx_flag ;			// stop receiving after 8 bit received

//wire declarations........................................................................
wire stop_cond ;		// stop condition, provided by slave
wire n_sda ;			// wire to get inverted sda - it will used to detect stop_cond from slave
//supply0 bf_in ;			// input signal to buffer of sda and scl

//parameter declarations...................................................................
parameter [2:0] ideal =   3'b000 ;
parameter [2:0] start =   3'b001 ;
parameter [2:0] send  =   3'b010 ;
parameter [2:0] stop  =   3'b011 ;
parameter [2:0] receive = 3'b100 ;

//............................................// Implementation of design //...................................................................................//

always @ (posedge clk, negedge rs)	// clock devider logic - using counter - count till 20 then toggle - enabled by e_scl signal
begin
 if(e_scl | ~rs) begin			// bus is not ideal when e_scl = 1 
  if(~rs)
   ct_div = 0 ;
  else 
   ct_div = ct_div + 1 ;
  
  if(ct_div == 20) begin
   ct_div = 0 ;
   c_scl = ~c_scl ;			//scl toggling starts, by toggling control over scl line
  end
 end
 else
  c_scl = 1 ;				// bus is ideal 
end
// this block can also be implemented in different way-> generate clock/20 all time but give it to c_scl only when e_scl=1, using 'assign' => clock gating	
//..............................................// FSM for I2C Master //.......................................................................................//

always @ (posedge clk, negedge rs)			// this block required to run on 'clk', because this block enables e_scl	
begin
	case (ps)
		ideal:	begin
			 if (st == 1) begin
			  ns = start ;
			  c_sda = 0 ;			// sda change from 1 to 0 => start
			  e_scl = 1 ;			// scl toggling starts
			  tx_flag = 1 ;			// start transmision bit , if it 0 then wait for ack
			  ct_bit = 8 ;	// = 9		// initialize count to start
			 end
			 else begin
			  ns = ideal ;
			  c_sda = 1 ;			// sda line in pullup condition
			  e_scl = 0 ;			// scl line in pullup condition
			  ct_stop = 0 ;
			  tx_flag = 0 ;			
			  rx_flag = 0 ;
			 end			
			end

		start: 	begin  
			 if (ct_bit == 15) // == 0	// ct_bit= 0/15 => 8 bit data transmited, waiting for ack  
			  if (scl==1 & sda==0) begin	// sda = 0 => ack received while scl=1
			   ct_bit = 8 ; // = 9		// initialize count to start sending 
			   ct_rbit = 8 ;		// initialize count to start 
			   if (~rw) begin
			    ns = send ;			// ack received and rw= 0 => go to send state, to start writing data to slave 
			    tx_flag = 1 ; end		// start transmision bit , if it 0 then wait for ack
			   else begin
			    ns = receive ;  		// ack received and rw= 1 => go to receive state, to start reading data from slave
			    rx_flag = 1 ; end
			  end	
			  else
			   ns = start ;			// if ack not received no state change
			 else
			  ns = start ;			// if 8 bit not transmited, no state change
			end

		send: 	begin
			 if (ct_bit == 15) // == 0 		// ct_bit= 0/15 => 8 bit data transmited, waiting for ack  
			  if (scl==1 & sda == 0)begin		// sda = 0 => ack received
			   tx_flag = 1 ;			// start transmision bit , if it 0 then wait for ack
			   ct_bit = 8 ;  // = 9			// initialize count to start 
			   if ( ct_stop == byte_ct-1 ) begin 	// if all bytes transmited to slave
			    ns = stop ;				// go to stop state to provide stop condition
			    c_sda = 0 ;	
			    tx_flag = 0 ;
			   end
			   else begin
			    ct_stop = ct_stop + 1 ;
			    ns = send ;				 
			   end
			  end
			 else
			  ns = send ;				 
			end

		stop:	begin					// to provide stop condition
			 if ( ct_div==10 & scl==1 ) begin	 
			   c_sda = 1 ;			   
			   ns = ideal ;
			 end
			 else begin
			   c_sda = 0 ;
			   ns = stop ;
			 end
			end

		receive: begin
			 if (ct_rbit == 15) begin		// ct_bit= 0/15 => 8 bit data received  
			   c_sda = 0 ;				// sda = 0 => ack transmited
			   rx_flag = 1 ;			// start receive bit , if it 0 then do not receive
			   ct_rbit = 8 ;			// initialize count to start 
			   if ( (ct_stop == byte_ct-1) ) begin	// if all bytes received from slave
			    ns = stop ;				// required number of bytes received => master provides stop condition 
			    c_sda = 0 ;	
			    rx_flag = 0 ;
			   end
			   else begin
			    ct_stop = ct_stop + 1 ;
			    ns = receive ;			 
			   end
			 end
			 else if (stop_cond)			// stop condition received from slave
			  ns = ideal ;
			 else
			  ns = receive ;			 
			end

		default: ns = ideal ;
	endcase							// $display("ns => %b",ns);
end

always @ (negedge clk, negedge rs)				// posedge clk - in hardware
begin
	if( ~rs )
	 ps <= ideal ;
	else
	 ps <= ns ;						// $display("ps => %b",ps);
end

//..............................................// Data transmision - receiveing logic //......................................................................//

always @ (posedge scl, negedge rs)		// after negative edge of scl, signal on scl should change 
begin
  if(~rs)
   ct_bit = 8 ;	// = 9				// initialize to 9 because after first edge data transmission starts		
  else   		   
   ct_bit = ct_bit - 1 ;			// to count bit - down counter
end
						// in hardware upper and below block can be combined and used at posedge ....
always @ (posedge scl, negedge rs)
begin
  if(~rs)
   ct_rbit = 8 ;				
  else   		   
   ct_rbit = ct_rbit - 1 ;			// to count bit - down counter
end

always @ (negedge scl)	//scl or clk ???	// whenever clock changes value - transmit receive change
begin
// if ( scl==0 ) begin
  if ( tx_flag==1 )
    if ( ps==start ) 				//................................// transmitting slave adress and rw bit //...................................//
      if ( ct_bit==1 ) // == 2 
       c_sda = rw ;				
     else 					// in simulation after start bit may get unknown glitch for one clock cycle - no problem of that glitch
       c_sda = s_add[ct_bit -2] ; // -3		// send slave address - MSB first
    else if ( ps==send ) 			// sending write data to slave
       c_sda = wr_slave[ct_bit-1] ; // -2	// write data to slave - MSB first
  else 
     c_sda = 1 ;				// 8 bit transmited => release sda line by giving c_sda = 1  
// end
end

always @ (posedge scl)
begin
   if ( ps==receive ) 				//......................................// receiving data from slave //........................................//
     if ( rx_flag==1 ) 
       rd_slave[ct_rbit] = sda ; 		// read data from slave - MSB first
     else
       c_sda = 1 ;				// 8 bit transmited => release sda line by giving c_sda = 1
end

always @ (posedge clk)	
begin
// if ( ct_div==10 ) begin
  if ( ct_bit==1 & scl==0 )			// stop transmision after ct = 1, => 8 bit transmited
     tx_flag = 0 ;				// this assignment may not behave proper with negedge of scl
						// after 10 clock cycle tx_flag changed so there is no race between tx_flag = 0 or 1
  if ( ct_rbit==0 & scl==0 )			// stop receiving after ct = 0, => 8 bit received
     rx_flag = 0 ;				// this assignment may not behave proper with posedge of scl
// end
end

not n1(n_sda,sda) ;				 
assign stop_cond = (scl==1 & (sda & n_sda)) ? 1 : 0 ;	// here to check stop condition from slave, there must be finite delay through inverter of sda

initial #40000 force stop_cond = 1 ;			// to verify stop condition from slave - to verify, that receive operation is stoped after stop condition
initial #40030 release stop_cond ;

// buffer controled by control signal c_sda/c_scl, when control signal= 0, sda/scl will be driven otherwise Z (in pullup)
//bufif0 /*(pull1,strong0)*/ bf_sda(sda,bf_in,c_sda) ;
//bufif0 /*(pull1,strong0)*/ bf_scl(scl,bf_in,c_scl) ;	

endmodule
