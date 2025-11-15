`timescale 1 ps / 1 ps

module divider_wrapper
   (M_AXIS_DOUT_0_tdata,
    M_AXIS_DOUT_0_tvalid,
    S_AXIS_DIVIDEND_0_tdata,
    S_AXIS_DIVIDEND_0_tvalid,
    S_AXIS_DIVISOR_0_tdata,
    S_AXIS_DIVISOR_0_tvalid,
    aclk_0);
    
  output [63:0]M_AXIS_DOUT_0_tdata;
  output M_AXIS_DOUT_0_tvalid;
  input [31:0]S_AXIS_DIVIDEND_0_tdata;
  input S_AXIS_DIVIDEND_0_tvalid;
  input [31:0]S_AXIS_DIVISOR_0_tdata;
  input S_AXIS_DIVISOR_0_tvalid;
  input aclk_0;

  wire [63:0]M_AXIS_DOUT_0_tdata;
  wire M_AXIS_DOUT_0_tvalid;
  wire [31:0]S_AXIS_DIVIDEND_0_tdata;
  wire S_AXIS_DIVIDEND_0_tvalid;
  wire [31:0]S_AXIS_DIVISOR_0_tdata;
  wire S_AXIS_DIVISOR_0_tvalid;
  wire aclk_0;
endmodule
