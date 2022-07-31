`define SYS_CLOCK 	10_000_000
`define BAUD_RATE 	9600
`define CLOCK_PER_BIT 	(`SYS_CLOCK / `BAUD_RATE)

module rx_new(dout, ferr, perr, din, clock, reset);

	// Output Declarations
	output [7:0] dout;
	output reg ferr, perr;

	// Input Declarations
	input din, clock, reset;

	// Register Declarations
	reg [15:0]counter;
	reg [3:0] bit_index;
	reg baud_clock, rx_ready, fall_edge, parity;
	reg [2:0] c_state, n_state;
	reg [7:0] temp_dout;
	
	// Wire Declaration
	wire temp_parity;

	// Parameter Declarations
	parameter [2:0] IDLE    = 3'b000;
	parameter [2:0] DATA    = 3'b001;
	parameter [2:0] PARITY  = 3'b010;
	parameter [2:0] STOP1   = 3'b011;
	parameter [2:0] STOP2   = 3'b100;

	// Body of Code
	always @(negedge din)
	begin
		if(c_state == IDLE)
		begin
			if(!din)
			begin
				fall_edge = 1;
				baud_clock = 0;
			end
			else
				fall_edge = 0;
		end
	end
	always @(posedge clock)
	begin
		if(fall_edge == 1)
		begin
			if(counter == ((`CLOCK_PER_BIT/2)-1))
			begin
				baud_clock <= ~baud_clock;
				counter <= 0;
			end
			else
				counter = counter + 1;
		end
	end

	//always @(posedge clock)
	//	temp_parity <= ^dout;

	always @(posedge baud_clock)
	begin
		case(c_state)
			IDLE:	begin	
					//fall_edge = 1'b0;
					bit_index = 4'd0;
					temp_dout = 8'd0;
					if(din == 0)	n_state = DATA;
					else 		n_state = IDLE;
				end

			DATA:	begin
					if(bit_index < 8) begin
						//dout <= (din << bit_index);
						temp_dout[bit_index] = din;
						bit_index = bit_index + 1;
					//	temp_parity <= ^dout;
					end
					else n_state = PARITY;
				end
			PARITY:	begin
					//parity <= din;
					//temp_parity <= ^dout;
					//if(din == temp_parity)	n_state = STOP1;
					if(!perr)	n_state = STOP1;
					else begin
						n_state = IDLE;
						//perr    = 1'b1;
						rx_ready = 1'b0;
					end
				end
			STOP1:	begin
					if(din == 1)	n_state = STOP2;
					else begin
						n_state = IDLE;	
						//ferr = 1'b1; 
						rx_ready = 1'b0; 
					end
				end
			STOP2:	begin
					if(din == 1) begin
						n_state = IDLE; 
						//fall_edge = 1'b0; 
						rx_ready = 1'b1; 
					end
					else begin
						n_state  = IDLE;
						//ferr     = 1'b1; 
						rx_ready = 1'b0; 
					end
				end
			default: begin 
					n_state = IDLE; 
					//fall_edge = 1'b0; 
				end
		endcase
	end
	
	assign temp_parity = ^temp_dout;
	assign perr = (bit_index == 8) ? (parity == temp_parity) ? 0 : 1 : 0;
	assign dout = (rx_ready == 1) ? temp_dout : 8'd0;

	always @(posedge baud_clock, negedge reset)
	begin
		if(!reset) begin
			c_state <= IDLE; 
			n_state <= IDLE; 
			counter <= 16'd0;
			bit_index <= 4'd0;
			temp_dout <= 8'd0;
			parity <= 1'b0;
			//temp_parity <= 1'b0;
			ferr <= 1'b0;
			perr <= 1'b0;
			end
		else
			c_state <= n_state;
	end
endmodule
