/*************************************************************************

#    Date: 2/8/14
#    Design: Testbench for JTAG TAP controller
#    Description: In this testbench the given test case is for transfering 
#    1111 as instruction to instruction reg.As well as it check for tms_rst
#    which reset after 5 countinues TMS=1.
**************************************************************************/

`include "tap_top.v"

module tb;
reg tclk;
reg tms;
reg td_i;
reg trst;

wire td_o;

//Instantiation of tap module
tap tap_U(tclk,tms,td_i,td_o,trst);

initial
begin
 tclk=0;
 trst=1;
 tms=0;
 td_i=0;

 #5 trst=0;
 #5 trst=1;
 td_i=1;
 #20 tms=1;
 #20 tms=1;
 #20 tms=0;
 #20 tms=0;
 #20 tms=0;
 #20 tms=0;
 #20 tms=0;
 #20 tms=0;
 #20 tms=0;
 #20 tms=1;
 #20 tms=1;

 
 
 #200000 $finish;
 

end



//Dumping the signals in .vcd file.
initial
begin
 $dumpvars(0,tb);
 $dumpfile("tap_top.vcd");
end

//Generates the clock of 20 unit time.
always
begin
 #10 tclk = ~tclk;
end
endmodule
