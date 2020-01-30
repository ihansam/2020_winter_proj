module MAC_Unit(
    input [7:0] Activation, weight,
    input clk, rstn, en,
    input [1:0] ReducePrecLevel,
    output reg [2:0] count,
    output Win,
    output [7:0] WA,
    output done
    );
    
    // counter
    // reg [2:0] count;
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            count = 0;
        else if (en == 1) begin
            count = count + 1;
        end
    end

    // done = 1 whenever count == multiple of precision bits
    assign done = count[0] & ((count[1]&ReducePrecLevel[0])|(count[2]&count[1])|(ReducePrecLevel[1]&~ReducePrecLevel[0]));

    // calculate weight bit * Activation
    // wire Win = weight[count];
    assign Win = weight[count];
    // wire [7:0] WA;
    genvar i;
    for (i=0; i<8; i=i+1) begin
        and(WA[i], Activation[i], Win);
    end

endmodule

module tb_bitserial();
    reg [7:0] A, W;
    reg clk, rstn, en;
    reg [1:0] Precesion;
    wire [2:0] count;
    wire win;
    wire [7:0] WA;
    wire done;

    MAC_Unit MAC (A, W, clk, rstn, en, Precesion, count, win, WA, done);

    initial begin
        #0  clk = 0; rstn = 0; en = 0; Precesion = 2'b00; A = 0; W = 0;
        #10 rstn = 1;
        #5  A = 8'b00001011; W = 8'b00001001;
        #5  en = 1;
        #5  
        #70 W = 8'b01010101;
        #80 W = 8'b10101010;
        #85 en = 0; Precesion = 2'b01; W = 8'b11011000;
        #5  en = 1;
        #75 en = 0; Precesion = 2'b10;
        #5  en = 1;
        #75 en = 0;
    end

    always #5 clk = ~clk;

endmodule
