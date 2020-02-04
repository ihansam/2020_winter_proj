module tb_bitserial();
    reg [7:0] A, W;
    reg clk, rstn, en;
    reg [1:0] Precision;
    wire [2:0] count;
    wire [15:0] PRODUCT;
    wire [19:0] ACCUM;
    wire [15:4] PRODUCT4b = PRODUCT[15:4];
    wire [19:4] ACC4b = ACCUM[19:4];
    wire [15:6] PRODUCT2b = PRODUCT[15:6];
    wire [19:6] ACC2b = ACCUM[19:6];    

    MAC_Unit MAC (A, W, clk, rstn, en, Precision, count, PRODUCT, ACCUM);

    initial begin
        #0  clk = 0; rstn = 0; en = 0; Precision = 2'b00; A = 0; W = 0;
        #10 rstn = 1;
        #5  A = 8'b01100111; W = 8'b00001010;
        #5  en = 1;
        #75 A = 8'b00111111; W = 8'b11100001;
        #80 A = 8'b10110100; W = 8'b01000000;
        #80 A = 8'b10101001; W = 8'b10110101;        
        #80 A = 8'b10000000; W = 8'b10000000;        
        #95 en = 0; rstn = 0; Precision = 2'b01; A = 0; W = 0;
        #10 rstn = 1; A = 8'b01111011; W = 8'b0100_1000;
        #10  en = 1;
        #75 A = 8'b10011000; W = 8'b01111011;
        #95 en = 0; rstn = 0; Precision = 2'b10; A = 0; W = 0;
        #10 rstn = 1; A = 8'b01011100; W = 8'b01_00_11_10;
        #10 en = 1;
        #75 A = 8'b11010001; W = 8'b10_00_11_01;
        #95 en = 0;
        
    end

    always #5 clk = ~clk;

endmodule