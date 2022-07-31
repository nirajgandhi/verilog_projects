/*******************************************************\

**File Name   :i2c_tb.v

**Date        :Thursday 31 July 2014

**Description :



\********************************************************/

module i2c_tb();

wire s_d;

reg s_c;

i2c_slave i1(s_d, s_c);

initial
begin
s_c = 1'b0;
#5  s_d = 1'b1;
#10 s_d = 1'b1;
#10 s_d = 1'b0;
#10 s_d = 1'b0;
#10 s_d = 1'b1;
#10 s_d = 1'b0;
#10 s_d = 1'b0;
#10 s_d = 1'b0;

end

initial
forever #5 s_c = ~s_c;
initial
#100 $finish;

initial
begin
$dumpvars(0,i2c_tb);
$dumpfile("i2c.dump");
end


endmodule
