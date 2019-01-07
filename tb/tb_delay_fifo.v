`timescale 1ns / 1ps

`include "config.vh"

module tb_delay_fifo();
    parameter   DELAY_CYCLES    =   1;
    parameter   BITWIDTH        =   32;
    parameter   ADDRWIDTH       =   4;
    parameter   MEMHEIGHT       =   2 ** ADDRWIDTH;
    parameter   INVALIDHEIGHT   =   MEMHEIGHT / 4;
    parameter   VALIDHEIGHT     =   MEMHEIGHT - INVALIDHEIGHT;
    
    localparam  input_file_path =   { `path, "tb/data/delay_fifo_input.bin" };
    
    reg     aclk;
    reg     en;
    reg     [   BITWIDTH - 1 : 0    ]   din;
    wire    [   BITWIDTH - 1 : 0    ]   dout;
    reg     valid;
    reg     valid_d;
    wire    dvalid;

    reg     [   BITWIDTH - 1 : 0    ]   mem     [   MEMHEIGHT - 1 : 0     ];    
    reg     [   MEMHEIGHT - 1 : 0   ]   addr;
    
    reg     start;
    reg     stop;

    initial begin
        aclk <= 1'b1;
        en <= 1'b0;
        addr <= 'd0;
        
        $readmemh(input_file_path, mem);
    end
    
    integer i;
    
    initial begin
        #( `period );
        
        start = 1'b1;
        
        #( 2 * `period );
        
        #( DELAY_CYCLES * `period );
        
        for ( i = 0 ; i < VALIDHEIGHT ; i = i + 1 ) begin
            if ( dout == mem[ i ] && dvalid )
                $display("[ TEST CASE #%d ]     PASS", i);
            else if ( dvalid )
                $display("[ TEST CASE #%d ]     FAIL : %x expected(%x)", i, dout, mem[i]);
            else
                $display("[ TEST CASE #%d ]     FAIL : INVALID expected(VALID)", i);
            #( `period );
        end
        
        for ( i = 0 ; i < INVALIDHEIGHT ; i = i + 1 ) begin
            if ( dvalid )
                $display("[ TEST CASE #%d ]     FAIL : VALID expected(INVALID)", i + VALIDHEIGHT);
            else
                $display("[ TEST CASE #%d ]     PASS", i + VALIDHEIGHT);
        end
        
        #( 5 * `period );
        
        $finish;
    end

    always #( `period / 2 ) aclk <= ~aclk;

    always @( posedge aclk )
        if ( start ) begin
            en <= 1'b1;
            valid_d <= 1'b1;
        end
    
    always @( posedge aclk )
        if ( valid_d )
            valid <= 1'b1;
        else
            valid <= 1'b0;
    
    always @( posedge aclk )
        if ( stop ) begin
            valid_d <= 1'b0;
            valid <= 1'b0; 
        end
            
    always @( posedge aclk )
        if ( en )
            start <= 1'b0;
    
    always @( posedge aclk )
        if ( !en )
            stop <= 1'b0;
            
    always @( posedge aclk )
        if ( en && addr == VALIDHEIGHT - 1 )
            stop <= 1'b1;
            
    always @( posedge aclk )
        if ( en )
            addr <= addr + 1;
            
    always @( posedge aclk )
        if ( en )
            din <= mem[ addr ];

    delay_fifo #(
        .DELAY_CYCLES   (   DELAY_CYCLES    ),
        .BITWIDTH       (   BITWIDTH        )
    ) u_delay_fifo (
        .aclk   (   aclk    ),
        .en     (   en      ),
        .din    (   din     ),
        .valid  (   valid   ),
        .dout   (   dout    ),
        .dvalid (   dvalid  )
    );
    
endmodule
