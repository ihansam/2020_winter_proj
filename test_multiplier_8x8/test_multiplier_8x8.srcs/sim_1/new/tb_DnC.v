module tb_DnC;
    
    reg [7:0] A, W;
    reg [1:0] PrecLevel;
    reg clk, rstn, en;
    wire [39:0] Products;
    wire [55:0] Result00;
    
    wire [15:0] Product00 = Products[15:0];
    wire [11:0] Product11 = Products[39:28];
    wire [11:0] Product10 = Products[11:0];
    wire [9:0] Product23 = Products[39:30];
    wire [9:0] Product22 = Products[29:20];
    wire [9:0] Product21 = Products[19:10];
    wire [9:0] Product20 = Products[9:0];
    wire [27:0] Result11 = Result00[55:28];
    wire [27:0] Result10 = Result00[27:0];
    wire [13:0] Result23 = Result00[55:42];
    wire [13:0] Result22 = Result00[41:28];
    wire [13:0] Result21 = Result00[27:14];
    wire [13:0] Result20 = Result00[13:0];
        
    MAC_Unit MAC(A, W, PrecLevel,clk, rstn, en,
    Products, Result00);
        
    initial begin
        rstn = 0; en = 0; PrecLevel=2'b00; clk = 0; A = 0; W = 0;
        #10 rstn = 1; en = 1;
            PrecLevel = 2'b00; // full prec
            A = 127; W = 127;
        #10 A = -128; W = -128;
        #10 A = 127; W = -128;
        #10 A = -128; W = 127;
        #10 A = 21; W = 89;
        #10 A = -51; W = 73;
        #10 A = 11; W = -13;
        #10 A = -59; W = -85;
        #10 rstn = 0; en = 0; A = 0; W = 0;
        #10 rstn = 1; en = 1; PrecLevel = 2'b01;    // 4bit prec
        #10 A = 127; W = 16'h77;
        #10 A = 127; W = 16'h78;
        #10 A = 127; W = 16'h87;
        #10 A = 127; W = 16'h88;
        #10 A = -128; W = 16'h88;
        #10 A = -128; W = 16'h87;
        #10 A = -128; W = 16'h78;
        #10 A = -128; W = 16'h77;
        #10 rstn = 0; en = 0; A = 0; W = 0;
        #10 rstn = 1; en = 1; PrecLevel = 2'b10;    // 2bit prec
        #10 A = 127; W = 8'b00011011;
        #10 A = 127; W = 8'b11100100;
        #10 A = -128; W = 8'b00011011;
        #10 A = -128; W = 8'b11100100;
            
        #10 A = 0; W = 0;            
            
         
    end

    always #5 clk = ~clk;
    
endmodule
