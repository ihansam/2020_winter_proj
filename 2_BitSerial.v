module MAC_Unit(
    input [7:0] Activation, weight,
    input clk, rstn, en,
    input [1:0] ReducePrecLevel,
    output reg [2:0] count,
    output Win,
    output [7:0] WA,
    output done, triger,
    output [8:0] op1, op2,
    output [8:0] partsumres,
    output reg [15:0] PRODUCT);

    // counter part
    // reg [2:0] count;
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            count = 0;
        else if (en == 1) begin
            count = count + 1;
        end
    end

    // triger = 1 when last bit of weight enter, done = 1 when partial sum done 
    assign triger = count[0] & ((count[1]&ReducePrecLevel[0])|(count[2]&count[1])|(ReducePrecLevel[1]&~ReducePrecLevel[0]));
    assign done = ~count[0] & ((~count[1]&ReducePrecLevel[0])|(~count[2]&~count[1])|(ReducePrecLevel[1]&~ReducePrecLevel[0]));

    // calculate weight bit * Activation
    // wire Win = weight[count];
    assign Win = weight[count];
    // wire [7:0] WA;
    genvar i;
    for (i=0; i<8; i=i+1) begin
        and(WA[i], Activation[i], Win);
    end

    // partial sum operand decision
    // wire [8:0] op1, op2;
    wire [7:0] WAprime;
    for (i=0; i<8; i=i+1) begin
        not(WAprime[i], WA[i]);
    end
    generate
        for(i=0; i<8; i=i+1) begin
            MUX_2 mux (WA[i], WAprime[i], triger, op1[i]);
        end
    endgenerate
    assign op1[8] = op1[7];

    wire [15:0] prevProduct = PRODUCT;
    wire [8:0] presum = {prevProduct[15], prevProduct[15:8]};
    generate
        for(i=0; i<9; i=i+1) begin
            MUX_2 mux(presum[i], 0, done, op2[i]);
        end
    endgenerate
    
    // partial sum part
    // wire [8:0] partsumres;
    ADDER #(.size(9)) productACCUM (op1, op2, triger, partsumres);

    // partial sum register
    wire [15:0] dPRODUCT = {partsumres, prevProduct[7:1]};
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            PRODUCT = 0;
        else if (en == 1)
            PRODUCT = dPRODUCT;
    end

endmodule

module MUX_2(
    input A, B, sel,
    output O);
    
    wire asp, bs, notsel;
    
    not(notsel, sel);
    nand(asp, A, notsel); 
    nand(bs, B, sel);
    nand(O, asp, bs);     
    
endmodule

module ADDER(op1, op2, cin, res);           // without carry out
    parameter size = 12;
    input [size-1:0] op1, op2;
    input cin;
    output [size-1:0] res;
    wire [size:0] C;

    genvar i;
    assign C[0] = cin;
    
    generate
        for(i=0; i<size; i=i+1) begin
            fullAdder FAwoc (.A(op1[i]), .B(op2[i]), .ci(C[i]), .s(res[i]), .co(C[i+1]));
        end
    endgenerate

endmodule

module fullAdder(
    input A, B, ci,
    output s, co);

    wire AxorB, AB, AciorBci;

    xor(AxorB, A, B);
    xor(s, AxorB, ci);
    and(AB, A, B);
    and(AciorBci, AxorB, ci);
    or(co, AciorBci, AB);

endmodule

module tb_bitserial();
    reg [7:0] A, W;
    reg clk, rstn, en;
    reg [1:0] Precesion;
    wire [2:0] count;
    wire win;
    wire [7:0] WA;
    wire done, triger;
    wire [8:0] op1, op2;
    wire [8:0] ptsum;
    wire [15:0] PRODUCT;    

    MAC_Unit MAC (A, W, clk, rstn, en, Precesion, count, win, WA, done, triger, op1, op2, ptsum, PRODUCT);

    initial begin
        #0  clk = 0; rstn = 0; en = 0; Precesion = 2'b00; A = 0; W = 0;
        #10 rstn = 1;
        #5  A = 8'b01100111; W = 8'b00001010;
        #5  en = 1;
        #75 A = 8'b00111111; W = 8'b11100001;
        #80 A = 8'b10110100; W = 8'b01000000;
        #80 A = 8'b10101001; W = 8'b10110101;        
        #80 A = 8'b10000000; W = 8'b10000000;        
        #85  en = 0;
    end

    always #5 clk = ~clk;

endmodule