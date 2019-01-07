`timescale 1ns / 1ps

module MACC #(
    parameter   BITWIDTH    =   32
)(
    input   aclk,
    input   [   BITWIDTH - 1 : 0    ]   s_axis_a_tdata,
    input   s_axis_a_tvalid,
    input   [   BITWIDTH - 1 : 0    ]   s_axis_b_tdata,
    input   s_axis_b_tvalid,
    input   [   BITWIDTH - 1 : 0    ]   s_axis_c_tdata,
    input   s_axis_c_tvalid,
    output  [   BITWIDTH - 1 : 0    ]   m_axis_result_tdata,
    output  m_axis_result_tvalid  
);

reg dvalid;
reg [   BITWIDTH - 1 : 0    ]   dout;

wire valid;

assign valid = s_axis_a_tvalid && s_axis_b_tvalid && s_axis_c_tvalid;
assign m_axis_result_tvalid = dvalid;
assign m_axis_result_tdata = dout;

always @(posedge aclk)
    if ( valid )
        dout <= s_axis_a_tdata * s_axis_b_tdata + s_axis_c_tdata;
    else
        dout <= 'd0;

always @(posedge aclk)
    if ( valid )
        dvalid <= 1'b1;
    else
        dvalid <= 1'b0;

endmodule
