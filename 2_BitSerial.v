module MAC_UNIT(
    input [7:0] Activation, Weight,
    input [1:0] ReducePrecLevel,
    input clk, rstn,
    output reg [15:0] PRODUCT);

    reg [2:0] count;
    integer [2:0] clknum = 3'b111>>ReducePrecLevel;
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            count = 0;
        else
            count = count + 1;
    end
    
    wire ANDIN = Weight[count];
    wire aw[7:0];
    integer i;
    for (i=0; i<8; i=i+1) begin
        and(aw[i], Activation[i], ANDIN);
    end

    reg done;
    always @(*) begin
        if (count == clknum)
            done = 1'b1;
        else
            done = 1'b0;
    end
        
    wire [8:0] op1, op2;
    wire [8:0] result;
    wire [8:0] awprime;
    for (i=0; i<8; i=i+1) begin
        not(awprime[i], aw[i]);
    end
    
    generate
        for(i=0; i<8; i=i+1) begin
            MUX_2 mux(aw[i], awprime[i], done, op1[i]);
        end
    endgenerate
    assign op1[8] = op1[7];
    assign op2 = {PRODUCT[15], PRODUCT[15:8]}

    ADDER #(.size(9)) productACCUM (op1, op2, done, result);
    reg [15:0] dPRODUCT = {result, PRODUCT[6:0]};

    always @(posedge clk, negedge rstn, count) begin
        if (rstn == 0 or count == 0)
            PRODUCT = 0;
        else
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
