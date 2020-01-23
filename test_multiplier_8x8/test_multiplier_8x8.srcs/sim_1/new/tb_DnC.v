module tb_DnC;
    
    reg [7:0] A, W;
    reg [1:0] PrecLevel;
    reg clk, rstn, en;
    wire [55:0] Result;
    
    MAC_Unit MAC(A, W, PrecLevel,clk, rstn, en,
    Result);
    
    initial begin
        rstn = 0; en = 0; PrecLevel=2'b00; clk = 0; A = 0; W = 0;
        #10 rstn = 1; en = 1;
            A = 8'b00001111; W = 8'b00011011;
         
    end

    always #5 clk = ~clk;
    
endmodule
