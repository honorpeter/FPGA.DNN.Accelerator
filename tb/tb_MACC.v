`timescale 1ns / 1ps

`include "config.vh"

module tb_MACC();

parameter   BITWIDTH    =   32;
parameter   ADDRWIDTH   =   4;
parameter   MEMHEIGHT   =   2 ** ADDRWIDTH;

localparam  input_A_data_path   =   { `path, "tb/data/MACC_input_A.bin" };
localparam  input_B_data_path   =   { `path, "tb/data/MACC_input_B.bin" };
localparam  input_C_data_path   =   { `path, "tb/data/MACC_input_C.bin" };
localparam  expected_data_path  =   { `path, "tb/data/MACC_expected.bin" };

localparam  S_RUNNING     =   1'b1;
localparam  S_STOPPED     =   1'b0;   

reg     [   BITWIDTH - 1 : 0    ]   mem_a_data  [   MEMHEIGHT - 1 : 0   ];
reg     [   BITWIDTH - 1 : 0    ]   mem_b_data  [   MEMHEIGHT - 1 : 0   ];
reg     [   BITWIDTH - 1 : 0    ]   mem_c_data  [   MEMHEIGHT - 1 : 0   ];
reg     [   BITWIDTH - 1 : 0    ]   mem_result  [   MEMHEIGHT - 1 : 0   ];

reg     aclk;
reg     [   BITWIDTH - 1 : 0    ]   a_data;
reg     [   BITWIDTH - 1 : 0    ]   b_data;
reg     [   BITWIDTH - 1 : 0    ]   c_data;
wire    a_valid;
wire    b_valid;
wire    c_valid;
wire    [   BITWIDTH - 1 : 0    ]   d_data;
wire    d_valid;

reg     state;
reg     start;
reg     stop;

reg     [   ADDRWIDTH - 1 : 0   ]   addr;

assign  a_valid = ( state == S_RUNNING );
assign  b_valid = ( state == S_RUNNING );
assign  c_valid = ( state == S_RUNNING );

always  #(`period / 2)  aclk = ~aclk;

initial begin
    $readmemh(input_A_data_path, mem_a_data);
    $readmemh(input_B_data_path, mem_b_data);
    $readmemh(input_C_data_path, mem_c_data);
    $readmemh(expected_data_path, mem_result);
    
    aclk <= 1'b1;
    state <= S_STOPPED;
    start <= 1'b0;
    addr <= 'b0;
end

integer i;

initial begin
    #( `period );
    start = 1'b1;
    #( 2 * `period );
    for ( i = 0 ; i < MEMHEIGHT ; i = i + 1 ) begin
        #( `period );
        if ( d_data == mem_result[i] && d_valid )
            $display( "[ TEST CASE #%d ]    PASS", i );
        else
            $display( "[ TEST CASE #%d ]    FAIL : %x expected(%x)", i, d_data, mem_result[i] );
    end
end

always @(posedge aclk)
    if ( stop )
        state <= S_STOPPED;

always @(posedge aclk)
    if ( start )
        state <= S_RUNNING;

always @(posedge aclk)
    if ( state == S_RUNNING )
        start <= 1'b0;

always @(posedge aclk)
    if ( state == S_STOPPED )
        stop <= 1'b0;

always @(posedge aclk)
    if ( state == S_RUNNING )
        addr <= addr + 1;
    else
        addr <= 'd0;

always @(posedge aclk)
    if ( state == S_RUNNING && addr == MEMHEIGHT - 1 )
        stop <= 'd1;

always @(posedge aclk)
    if ( state == S_RUNNING ) begin
        a_data <= mem_a_data[addr];
        b_data <= mem_b_data[addr];
        c_data <= mem_c_data[addr];
    end
    else begin
        a_data <= 'd0;
        b_data <= 'd0;
        c_data <= 'd0;
    end

MACC #(
    .BITWIDTH(  BITWIDTH    )
)   u_macc  (
    .aclk(aclk),
    .s_axis_a_tdata(a_data),
    .s_axis_a_tvalid(a_valid),
    .s_axis_b_tdata(b_data),
    .s_axis_b_tvalid(b_valid),
    .s_axis_c_tdata(c_data),
    .s_axis_c_tvalid(c_valid),
    .m_axis_result_tdata(d_data),
    .m_axis_result_tvalid(d_valid)
);

endmodule
