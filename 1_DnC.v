module MAC_Unit();
    input [7:0] Activetion, Weigt;
    input ReducePrecLevel, clk, rstn, en;
    output reg [55:0] Result;

    // Multiplier Part
    wire [1:0] w3, w2, w1, w0;
    assign w3 = Weigt[7:6];
    assign w2 = Weigt[5:4];
    assign w1 = Weigt[3:2];
    assign w0 = Weigt[1:0];

    wire [9:0] wx3, wx2, wx1, wx0;
    reg [3:0] MultMode;             // 0: unsigned mult, 1: signed mult
    always @(*) begin               
        case (ReducePrecLevel) begin     
        2'b00: MultMode = 4'b1000;  // full precesion
        2'b01: MultMode = 4'b1010;  // 4bit weigh precesion
        2'b10: MultMode = 4'b1111;  // 2bit weigh precesion
        2'b11: MultMode = 4'bxxxx;
        defualt: MultMode = 4'b0000;
        endcase
    end
    multiplier_8x2 m3 (w3, Activetion, MultMode[3], wx3);
    multiplier_8x2 m2 (w2, Activetion, MultMode[2], wx2);
    multiplier_8x2 m1 (w1, Activetion, MultMode[1], wx1);
    multiplier_8x2 m0 (w0, Activetion, MultMode[0], wx0);
    
    // First Sum of Products Part
    reg [11:0] fp3, fp2, fp1, fp0;    
    shifter shf3 (wx3, fp3);
    signExtender sef2(wx2, fp2);
    shifter shf1(wx1, fp1);
    signExtender sef0 (wx0, fp0);

    wire [11:0] fsp32, fsp10;
    ADDER fs1 (fp3, fp2, 0, fsp32);
        defparam fs1.size = 12
    ADDER fs0 (fp1, fp0, 0, fsp10);
        defparam fs0.size = 12
    
    // Second Sum of Products Part
    reg [15:0] sp1, sp0;
    shifter #(.size(12), .shamt(4)) shs1 (fsp32, sp1);
    signExtender #(.size(12), .extsize(16)) ses2 (fsp10, sp0);

    wire [15:0] ssp3210;
    ADDER #(.size(16)) ssum (sp1, sp0, 0, ssp3210);

    // Product Register Part (need to choose input according to MODE)
    reg [39:0] Products;    
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            Products = 0;
        else if (en == 1) begin
            case (ReducePrecLevel) begin      
                2'b00: Products[15:0] = ssp3210;                // full precesion
                2'b01: begin
                    Products[39:28] = fsp32;
                    Products[11:0] = fsp10;
                    end                                         // 4bit weigh precesion
                2'b10: Products = {{wx3}, {wx2}, {wx1}, {wx0}}; // 2bit weigh precesion
                2'b11: Products = x;
                defualt: Products = 0;
            endcase            
        end
    end

    // Accumulater Part
    reg [55:0] newAccum;
    always @(*) begin
        case (ReducePrecLevel) begin
            2'b00: signExtender #(.size(16), .extsize(56)) sigext0 (Products[15:0], newAccum);
            2'b01: begin
                signExtender #(.size(12), .extsize(28)) sigext1 (Products[11:0], newAccum[27:0]);
                signExtender #(.size(12), .extsize(28)) sigext2 (Products[39:28], newAccum[55:28]);
                end                
            2'b10: begin
                signExtender #(.size(10), .extsize(14)) sigext3 (Products[9:0], newAccum[13:0]);
                signExtender #(.size(10), .extsize(14)) sigext4 (Products[19:10], newAccum[27:14]);
                signExtender #(.size(10), .extsize(14)) sigext5 (Products[29:20], newAccum[41:28]);
                signExtender #(.size(10), .extsize(14)) sigext6 (Products[39:30], newAccum[55:42]);
                end
            2'b00: signExtender #(.size(40), .extsize(56)) sigext7 (Products, newAccum);
            default: newAccum = 0;
        endcase
    end

    reg [55:0] oldAccum, AccumRes;
    reg [3:0] CIN;
    reg [3:0] COUT;
    assign oldAccum = Result;
    ADDERc #(14) acc0 (oldAccum[13:0], newAccum[13:0], CIN[0], AccumRes[13:0], COUT[0]);
    ADDERc #(14) acc1 (oldAccum[27:14], newAccum[27:14], CIN[1], AccumRes[27:14], COUT[1]);
    ADDERc #(14) acc2 (oldAccum[41:28], newAccum[41:28], CIN[2], AccumRes[41:28], COUT[2]);
    ADDERc #(14) acc3 (oldAccum[55:42], newAccum[55:42], CIN[3], AccumRes[55:42], COUT[3]);
    always @(*) begin
        case(ReducePrecLevel) begin
            2'b00: CIN = {{COUT[2]}, {COUT[1]}, {COUT[0]}, 1'b0};
            2'b01: CIN = {{COUT[2]}, 1'b0, {COUT[0]}, 1'b0};
            2'b10: CIN = 4'b0;
            2'b11: CIN = 4'b0;
            default: CIN = 4'b0;
        endcase
    end

    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            Result = 0;
        else if (en == 1)
            Result = AccumRes;
    end

endmodule

module multiplier_8x2(
    input [1:0] W,          // signed or unsigned
    input [7:0] A,          // signed
    input mode,             // if 1, regards w signed, else unsigned
    output [9:0] Result);     

    wire [7:0] W_01A, notA, temp, W_10A;
    assign W_01A = {8{W[0]}} & A;
    assign notA = !A;
    genvar i;
    for (i=0; i<8; i=i+1) begin
        MUX_2 mx (.A(A[i]), .B(notA[i]), .sel(mode), .O(temp[i]));        
    end
    assign W_10A = {8{W[1]}} & temp;

    wire CIN = W[1] & mode;
    wire [8:0] OP1, OP2;
    signExtender #(.size(7), .extsize(9)) op1se (W_01A[7:1], OP1);
    signExtender #(.size(7), .extsize(9)) op2se (W_10A[7:1], OP2);
    wire [8:0] sumres;
    ADDER #(.size(9)) sum (OP1, OP2, CIN, sumres);
    assign Result = {sumres, W_01A[0]};    
    
endmodule

module shifter(I, O);           // O = I<<shamt
    parameter shamt = 2;
    parameter size = 10;
    input [size-1:0] I;
    output [size-1+shamt:0] O;

    assign O = {I, {shamt{1'b0}}};

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


module ADDERc(op1, op2, cin, res, cout);     // with carry out
    parameter size = 12;
    input [size-1:0] op1, op2;
    input cin;
    output [size-1:0] res;
    output cout;
    wire [size:0] C;

    genvar i;
    assign C[0] = cin;
    assign cout = C[size];

    generate
        for(i=0; i<size; i=i+1) begin
            fullAdder FAwc (.A(op1[i]), .B(op2[i]), .ci(C[i]), .s(res[i]), .co(C[i+1]));
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