
// Date - 17th July, 2014
// File - 1 to 2 Demux
// Description - if s=0 then input goes in op[0], else op[1].

module Demux_1_2 (op, ip, s);
	//  Port Declaration
	input ip, s;
	output [1:0] op;
	// Wires and Registers
	reg [1:0] op;
	// Code
	always @(ip or op or s)
	if (s==0) begin
		op[0]=ip;
		op[1]=1'bz;
	end else begin
		op[0]=1'bz;
		op[1]=ip;
	end
endmodule
