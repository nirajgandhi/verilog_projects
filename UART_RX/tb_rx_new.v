`define CLOCK_PERIOD 100

module tb_rx_new();

	wire [7:0] dout;
	wire ferr, perr;

	reg din, clock, reset;

	rx_new dut(dout, ferr, perr, din, clock, reset);

	// Clock Generation
	initial begin
		clock = 0;
		forever #50 clock = ~clock;
	end

	initial #1000000 $finish;

	initial
	begin
		reset = 1'b1;
	#10	reset = 1'b0;
	#10	reset = 1'b1;
		din = 1'b1;	// Idle Bus
	#(280)		din = 1'b0;	// Start Bit
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 0
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 1
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 2
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 3
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 4
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 5
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 6
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 7
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Parity bit
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Stop Bit 1
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Stop Bit 2

	
	#(7000)				din = 1'b0;	// Start Bit
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 0
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 1
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 2
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 3
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 4
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 5
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Bit 6
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Bit 7
	#(10 * `CLOCK_PERIOD)		din = 1'b0;	// Parity bit
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Stop Bit 1
	#(10 * `CLOCK_PERIOD)		din = 1'b1;	// Stop Bit 2
	end

	initial
	begin
		$dumpvars(0,tb_rx_new);
		$dumpfile("rx_new.dump");
	end
endmodule
