`timescale 1ns / 1ps


module tb_mult8x2;
    reg [1:0] W;
    reg [7:0] A;
    reg mode;
    wire [9:0] OUT;
    multiplier_8x2 mp (W, A, mode, OUT);
    integer i, j;
    initial
    begin
        mode = 0;
        for (i=0; i<4; i=i+1) begin
            for(j=0; j<256; j=j+1) begin
                #2 W=i; A=j;         
            end
        end
        mode = 1;
        for (i=0; i<4; i=i+1) begin
            for(j=0; j<256; j=j+1) begin
                #2 W=i; A=j;         
            end
        end
    end

endmodule

