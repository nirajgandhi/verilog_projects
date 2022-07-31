/*************************************************************************************************************************************/
/*                                                                                                                                   */
/*                                                                                                                                   */
/*     Design : SPI slave                                                                                                            */
/*     Designed by : 																			                                     */
/*                                                                                                                                   */
/*     Description :                                                                                                                 */
/*                                                                                                                                   */
/*                                                                                                                                   */
/*                                                                                                                                   */
/*                                                                                                                                   */
/*************************************************************************************************************************************/



module spi_slave (miso,rxr,rdone,tdone,mosi,txr,sck,ss,mol,rst);

//Output declaration
 output miso;                               // Master In Slave Out, from this pin serially data will go to Master
 output reg [7:0] rxr;                      // Serially received data will be given to this output port
 output reg rdone;                          // This pin will set when 8bit data is received
 output reg tdone;                          // This pin will set when 8bit data is transmitted

//Input Declaration 
 input mosi;                                // Master Out Slave In, from this pin serially data will come from Master
 input [7:0] txr;                           // Serially transmit data will be taken from this port
 input mol;                                 // MSB or LSB, if it is set MSB is recevied/sent first else LSB sent/received
 input sck,ss,rst;                          // Serial clk from Master, Slave select, Ascynchronous active low Reset

//Reg Declaration for internal use
 reg [3:0] cnt;                             // Counter to count 8bits of receiving/transemitting data
 reg [7:0] rsf;                             // Shift Register for receiving data
 reg [7:0] tsf;                             // Shift Register for sending data

//--------------------block for receiving data----------------------------------------------------------------------------------//
 always @ (posedge sck, negedge rst)        // Sencetive to POSEDGE of sck and NEGEGDE rst
   if (rst==1'b0)                           // If Reset is active
     begin rsf<=8'd0; rxr<=8'd0; rdone<=1'b0; cnt<=4'd0; end  // Reseting every variables to zero related to receiver
   else if (ss==1'b0)                       // If Slave is secected
     begin
     if (mol==0)
       rsf <= {mosi,rsf[7:1]};              // if LSB is received 1st
     else
       rsf <= {rsf[6:0],mosi};              // if MSB is received 1st
     cnt <= cnt + 4'd1;                   // Increment the counter by one
       if (cnt==4'd8)                        // if counter is 8
       begin rxr<=rsf; rdone<=1'b1; cnt<=4'd0; end // Received data will be given to o/p port, rdone get set and counter to zero
     else
       rdone<=1'b0;                         
     end
   else
     begin rsf<=8'd0; rdone<=1'b0; cnt<=4'd0; end  // Ideal state

//------------------block for transmitting data---------------------------------------------------------------------------------//    
 always @ (posedge sck, negedge rst)        // Sencitive to POSEDGE of sck and NEGEDGE of rst
   if (rst==1'b0)                           // If reset is actiove
     begin tsf<=8'hFF; tdone<=1'b0; end     // Resetting all pins and ports related to transmitter
   else if ((ss==1'b0) && (cnt==4'd0))      // if Slave is selected and counter is zero
     tsf<=txr;                              // then load the data from transmitter regiser to trasnmitting Shift register
   else if ((ss==1'b0) && (cnt!=4'd0))      // if Slave is selected and counter is not zero
         begin                              
         if (mol==0)                        // if LSB is sending 1st 
           begin
           //miso <= tsf[0];
           tsf <= {1'b1,tsf[7:1]};
           end
         else
           begin                            // if MSB is sending 1st
           //miso <= tsf[7];
           tsf <= {tsf[6:0],1'b1};
           end
         if (cnt==8)
           tdone=1'b1;                      // if counter is 8 flag tdone is set 
         else
           tdone=1'b0;                      // else flag tdone is not set
         end
   else
     begin tsf<=8'hFF; tdone<=1'b0; end     // Ideal state
   
 
 assign miso = (ss==0) ? ((mol==0) ? tsf[0] : tsf [7]) : 1'bz; // assigning serial bits of transmitting shift register to Master In Slave Out(miso) 

endmodule
