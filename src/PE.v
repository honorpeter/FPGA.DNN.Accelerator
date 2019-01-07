`timescale 1ns / 1ps

module PE #(
    parameter   BITWIDTH    =   32,
    parameter   INSTRWIDTH  =   1,
    parameter   ADDRWIDTH   =   3
)(
    input   aclk,
    input   en,
    input   aresetn,
    input   [   BITWIDTH - 1 : 0    ]   rdata,
    input   rvalid,
    input   [   BITWIDTH - 1 : 0    ]   accdata,
    input   accvalid,
    input   [   INSTRWIDTH - 1 : 0  ]   instr,
    output  [   BITWIDTH - 1 : 0    ]   dout,
    output  dvalid
);

localparam  MEMWIDTH    =   2 ** ADDRWIDTH;

localparam  INSTR_LD  =   1'b0;
localparam  INSTR_ACC =   1'b1;

localparam  S_IDLE  =   2'b00;
localparam  S_LOAD  =   2'b01;
localparam  S_CALC  =   2'b10;

integer i;

reg     [   BITWIDTH - 1 : 0    ]   mem     [   MEMWIDTH - 1 : 0    ];
reg     [   1 : 0   ]   state;
reg     [   ADDRWIDTH - 1 : 0   ]   addr;

wire    [   BITWIDTH - 1 : 0    ]   macc_ifmap_data;
wire    [   BITWIDTH - 1 : 0    ]   macc_filter_data;
wire    [   BITWIDTH - 1 : 0    ]   macc_acc_data;
wire    [   BITWIDTH - 1 : 0    ]   macc_output_data;

wire    macc_ifmap_valid;
wire    macc_filter_valid;
wire    macc_acc_valid;
wire    macc_output_valid;

assign  macc_ifmap_data = ( state == S_CALC ) ? rdata : 'd0;
assign  macc_filter_data = ( state == S_CALC ) ? mem[ addr ] : 'd0;
assign  macc_acc_data = ( state == S_CALC ) ? macc_output_data : ( accvalid ) ? accdata : 'd0;

assign  macc_ifmap_valid = ( state == S_CALC && rvalid );
assign  macc_filter_valid = ( state == S_CALC );
assign  macc_acc_valid = ( state == S_CALC && accvalid );

assign  dvalid = macc_output_valid;

always @( negedge aresetn ) begin
    state <= S_IDLE;
    for ( i = 0 ; i < MEMWIDTH ; i = i + 1 )
        mem[i] <= 'd0;
end

always @( posedge aclk )
    if ( en )
        if ( state == S_IDLE )
            state <= ( instr == INSTR_LD ) ? S_LOAD : ( instr == INSTR_ACC ) ? S_CALC : S_IDLE;
        else
            state <= state;
    else
        state <= S_IDLE;

always @( posedge aclk )
    if ( state == S_IDLE )
        addr <= 'd0;
    else
        addr <= addr + 1;

always @( posedge aclk )
    if ( state == S_LOAD )
        mem[ addr ] <= ( rvalid ) ? rdata : 'd0;
        
MACC #(
    .BITWIDTH(  BITWIDTH    )
)   pe_macc (
    .aclk                   (   aclk                ),
    .s_axis_a_tdata         (   macc_ifmap_data     ),
    .s_axis_a_tvalid        (   macc_ifmap_valid    ),
    .s_axis_b_tdata         (   macc_filter_data    ),
    .s_axis_b_tvalid        (   macc_filter_valid   ),
    .s_axis_c_tdata         (   macc_acc_data       ),
    .s_axis_c_tvalid        (   macc_acc_valid      ),
    .m_axis_result_tdata    (   macc_output_data    ),
    .m_axis_result_tvalid   (   macc_output_valid   )
);

endmodule
