`timescale 1ns / 1ps

`include "config.vh"

module tb_PE();
parameter   BITWIDTH    =   32;
parameter   INSTRWIDTH  =   1;
parameter   ADDRWIDTH   =   3;

reg     aclk;
reg     en;
reg     aresetn;
reg     [   BITWIDTH - 1 : 0    ]   rdata;
reg     rvalid;
reg     [   BITWIDTH - 1 : 0    ]   accdata;
reg     accvalid;
reg     [   INSTRWIDTH - 1 : 0  ]   instr;
wire    [   BITWIDTH - 1 : 0    ]   dout;
wire    dvalid;

endmodule
