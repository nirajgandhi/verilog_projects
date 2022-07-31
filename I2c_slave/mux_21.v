
// Date - 18th July, 2014
// File - 2*1 Mux
// Description - s=0 then op=a, else op=b

module Mux_2_1 (op, a, b, s);
	// Output Ports
	output reg op;
	// Input Ports
	input a, b, s;
	// Code
	always @ (s, a, b)
	begin
		case (s)
		1'b0:	op<=a;
		1'b1:	op<=b;
		default: op=1'bz;
		endcase	
	end
endmodule
