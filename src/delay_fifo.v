`timescale 1ns / 1ps

module delay_fifo #(
    parameter   DELAY_CYCLES    =   1,
    parameter   BITWIDTH        =   32
)(
    input   aclk,
    input   en,
    input   [BITWIDTH - 1 : 0]    din,
    input   valid,
    output  [BITWIDTH - 1 : 0]    dout,
    output  dvalid
);

    reg     [DELAY_CYCLES * BITWIDTH - 1 : 0]     fifo;
    reg     [DELAY_CYCLES - 1 : 0]                valid_fifo;

    assign  dout = { fifo };
    assign  dvalid = valid_fifo[0];

    always @(posedge aclk)
        if ( en )
            if ( DELAY_CYCLES > 1 )
                fifo <= { din, fifo[DELAY_CYCLES * BITWIDTH - 1:BITWIDTH] };
            else
                fifo <= din;
        else
            fifo <= 'd0;

    always @(posedge aclk)
        if ( en )
            if ( DELAY_CYCLES > 1 )
                valid_fifo <= { valid, valid_fifo[DELAY_CYCLES - 1:1] };
            else
                valid_fifo <= valid;
         else
            valid_fifo <= 'd0;
endmodule
