/***************************************************************
#    Date: 2/8/14
#    Design: State machine for TAP contorller of JTAG
#    Description: FSM is designed using one-hot coding.
****************************************************************/


`define	IR_LENGTH	4			//Instruction register 4-bit wide
`define DR_LENGTH 	4			//Data register 4-bit wide


//Top module it has input and outputs clk,TMS,Data in,data out and rst

module tap(tclk,tms,td_i,td_o,trst);

//Input declaration
input tclk;
input tms;
input td_i;
input trst;

//output declaration
output td_o;

//States of FSM 
reg     test_logic_reset;
reg     run_test_idle;
reg     select_dr_scan;
reg     capture_dr;
reg     shift_dr;
reg     exit1_dr;
reg     pause_dr;
reg     exit2_dr;
reg     update_dr;
reg     select_ir_scan;
reg     capture_ir;
reg     shift_ir;
reg     exit1_ir;
reg     pause_ir;
reg     exit2_ir;
reg     update_ir;

//Intermediate combinational logig reg and wire
reg     tms_q1, tms_q2, tms_q3, tms_q4;
wire    tms_reset;

//It moniters the TMS signal, this module is used for generating tms_reset signal

always @ (posedge tclk)
begin
  tms_q1 <= #1 tms;
  tms_q2 <= #1 tms_q1;
  tms_q3 <= #1 tms_q2;
  tms_q4 <= #1 tms_q3;
end

//In JTAG for 5 consecutive TMS=1 causes reset. 

assign tms_reset = tms_q1 & tms_q2 & tms_q3 & tms_q4 & tms;    // 5 consecutive TMS=1 causes reset
assign td_o=td_i;					       // Always pass serial input to output pin

// In this design it check from which state it can transfer to 
//the state defined in  always block. It moniters the TMS and 
//State signal.All the State of FSM are written in same formate.

// test_logic_reset state

always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    test_logic_reset<= 1'b1;
  else if (tms_reset)
    test_logic_reset<= 1'b1;
  else
    begin
      if(tms & (test_logic_reset | select_ir_scan)) 
        test_logic_reset<= 1'b1;
      else
        test_logic_reset<= 1'b0;
    end
end

// run_test_idle state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    run_test_idle<= 1'b0;
  else if (tms_reset)
    run_test_idle<= 1'b0;
  else
  if(~tms & (test_logic_reset | run_test_idle | update_dr | update_ir))
    run_test_idle<= 1'b1;
  else
    run_test_idle<= 1'b0;
end

// select_dr_scan state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    select_dr_scan<= 1'b0;
  else if (tms_reset)
    select_dr_scan<= 1'b0;
  else
  if(tms & (run_test_idle | update_dr | update_ir))
    select_dr_scan<= 1'b1;
  else
    select_dr_scan<= 1'b0;
end

// capture_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    capture_dr<= 1'b0;
  else if (tms_reset)
    capture_dr<= 1'b0;
  else
  if(~tms & select_dr_scan)
    capture_dr<= 1'b1;
  else
    capture_dr<= 1'b0;
end

// shift_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    shift_dr<= 1'b0;
  else if (tms_reset)
    shift_dr<= 1'b0;
  else
  if(~tms & (capture_dr | shift_dr | exit2_dr))
    shift_dr<= 1'b1;
  else
    shift_dr<= 1'b0;
end

// exit1_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    exit1_dr<= 1'b0;
  else if (tms_reset)
    exit1_dr<= 1'b0;
  else
  if(tms & (capture_dr | shift_dr))
    exit1_dr<= 1'b1;
  else
    exit1_dr<= 1'b0;
end

// pause_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    pause_dr<= 1'b0;
  else if (tms_reset)
    pause_dr<= 1'b0;
  else
  if(~tms & (exit1_dr | pause_dr))
    pause_dr<= 1'b1;
  else
    pause_dr<= 1'b0;
end

// exit2_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    exit2_dr<= 1'b0;
  else if (tms_reset)
    exit2_dr<= 1'b0;
  else
  if(tms & pause_dr)
    exit2_dr<= 1'b1;
  else
    exit2_dr<= 1'b0;
end

// update_dr state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    update_dr<= 1'b0;
  else if (tms_reset)
    update_dr<= 1'b0;
  else
  if(tms & (exit1_dr | exit2_dr))
    update_dr<= 1'b1;
  else
    update_dr<= 1'b0;
end

// select_ir_scan state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    select_ir_scan<= 1'b0;
  else if (tms_reset)
    select_ir_scan<= 1'b0;
  else
  if(tms & select_dr_scan)
    select_ir_scan<= 1'b1;
  else
    select_ir_scan<= 1'b0;
end

// capture_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    capture_ir<= 1'b0;
  else if (tms_reset)
    capture_ir<= 1'b0;
  else
  if(~tms & select_ir_scan)
    capture_ir<= 1'b1;
  else
    capture_ir<= 1'b0;
end

// shift_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    shift_ir<= 1'b0;
  else if (tms_reset)
    shift_ir<= 1'b0;
  else
  if(~tms & (capture_ir | shift_ir | exit2_ir))
    shift_ir<= 1'b1;
  else
    shift_ir<= 1'b0;
end

// exit1_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    exit1_ir<= 1'b0;
  else if (tms_reset)
    exit1_ir<= 1'b0;
  else
  if(tms & (capture_ir | shift_ir))
    exit1_ir<= 1'b1;
  else
    exit1_ir<= 1'b0;
end

// pause_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    pause_ir<= 1'b0;
  else if (tms_reset)
    pause_ir<= 1'b0;
  else
  if(~tms & (exit1_ir | pause_ir))
    pause_ir<= 1'b1;
  else
    pause_ir<= 1'b0;
end

// exit2_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    exit2_ir<= 1'b0;
  else if (tms_reset)
    exit2_ir<= 1'b0;
  else
  if(tms & pause_ir)
    exit2_ir<= 1'b1;
  else
    exit2_ir<= 1'b0;
end

// update_ir state
always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    update_ir<= 1'b0;
  else if (tms_reset)
    update_ir<= 1'b0;
  else
  if(tms & (exit1_ir | exit2_ir))
    update_ir<= 1'b1;
  else
    update_ir<= 1'b0;
end


//  jtag_ir:  JTAG Instruction Register                                           

reg [`IR_LENGTH-1:0]  jtag_ir;          // Instruction register

always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    jtag_ir[`IR_LENGTH-1:0] <=`IR_LENGTH'b0;
  else if(capture_ir)
    jtag_ir <= #1 4'b0101;          // This value is fixed.
  else if(shift_ir)
    jtag_ir[`IR_LENGTH-1:0] <= {td_i, jtag_ir[`IR_LENGTH-1:1]};
end


//   End: jtag_ir                                                                  

//  jtag_dr:  JTAG Data Register                                           

reg [`DR_LENGTH-1:0]  jtag_dr;          // Data register

always @ (posedge tclk or negedge trst)
begin
  if(!trst)
    jtag_dr[`DR_LENGTH-1:0] <=`DR_LENGTH'b0;
  else if(capture_dr)
    jtag_dr <= 4'b0101;          // This value is fixed.
  else if(shift_dr)
    jtag_dr[`DR_LENGTH-1:0] <={td_i, jtag_dr[`DR_LENGTH-1:1]};
end


//   End: jtag_dr                                                                  


endmodule


