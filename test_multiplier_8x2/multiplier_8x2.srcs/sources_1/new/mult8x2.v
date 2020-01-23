module multiplier_8x2(
    input [1:0] W,          // signed or unsigned
    input [7:0] A,          // signed
    input mode,             // if 1, regards w signed, else unsigned
    output [9:0] Result);     

    wire [7:0] W_01A, notA, temp, W_10A;
    assign W_01A = {8{W[0]}} & A;
    assign notA = ~A;
    genvar i;
    for (i=0; i<8; i=i+1) begin
        MUX_2 mx (.A(A[i]), .B(notA[i]), .sel(mode), .O(temp[i]));        
    end
    assign W_10A = {8{W[1]}} & temp;

    wire CIN = W[1] & mode;
    wire [8:0] OP1, OP2;
    signExtender #(.size(7), .extsize(9)) op1se (W_01A[7:1], OP1);
    signExtender #(.size(8), .extsize(9)) op2se (W_10A, OP2);
    wire [8:0] sumres;
    ADDER #(.size(9)) sum (OP1, OP2, CIN, sumres);
    assign Result = {sumres, W_01A[0]};    
    
endmodule

module signExtender(I, O);      // size bit 신호 I를 extsize bit 신호 O로 sign extension
    parameter size = 10;
    parameter extsize = 12;
    input [size-1:0] I;
    output [extsize-1:0] O;

    assign O = {{(extsize-size){I[size-1]}}, {I}};

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

module MUX_2(
    input A, B, sel,
    output O);
    
    wire asp, bs, notsel;
    
    not(notsel, sel);
    nand(asp, A, notsel); 
    nand(bs, B, sel);
    nand(O, asp, bs);     
    
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