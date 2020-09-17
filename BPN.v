module MAC_Unit(
    input [7:0] Activation, Weight,
    input [1:0] ReducePrecLevel,
    input clk, rstn, en,
    output reg [39:0] Products,    
    output reg [55:0] Result);

    // Partial Multiplier Part
    wire [1:0] w3, w2, w1, w0;
    assign w3 = Weight[7:6];
    assign w2 = Weight[5:4];
    assign w1 = Weight[3:2];
    assign w0 = Weight[1:0];

    wire [9:0] wx3, wx2, wx1, wx0;
    reg [3:0] MultMode;             // 0: unsigned mult, 1: signed mult
    always @(*) begin               
        case (ReducePrecLevel)     
        2'b00: MultMode = 4'b1000;  // full precesion
        2'b01: MultMode = 4'b1010;  // 4bit weigh precesion
        2'b10: MultMode = 4'b1111;  // 2bit weigh precesion
        2'b11: MultMode = 4'bxxxx;
        default: MultMode = 4'b1000;
        endcase
    end
    
    multiplier_8x2 m3 (w3, Activation, MultMode[3], wx3);
    multiplier_8x2 m2 (w2, Activation, MultMode[2], wx2);
    multiplier_8x2 m1 (w1, Activation, MultMode[1], wx1);
    multiplier_8x2 m0 (w0, Activation, MultMode[0], wx0);
    
    // First Sum of Partial Products
    wire [11:0] fp3, fp2, fp1, fp0;    
    shifter shf3 (wx3, fp3);
    signExtender sef2(wx2, fp2);
    shifter shf1(wx1, fp1);
    signExtender sef0 (wx0, fp0);

    wire [11:0] fsp32, fsp10;
    assign fsp32 = fp3 + fp2;
    assign fsp10 = fp1 + fp0;
    // ADDER #(.size(12)) fs1 (fp3, fp2, 0, fsp32);
    // ADDER #(.size(12)) fs0 (fp1, fp0, 0, fsp10);
    
    // Second Sum of Partial Products
    wire [15:0] sp1, sp0;
    shifter #(.size(12), .shamt(4)) shs1 (fsp32, sp1);
    signExtender #(.size(12), .extsize(16)) ses2 (fsp10, sp0);

    wire [15:0] ssp3210;
    assign ssp3210 = sp1 + sp0;
    // ADDER #(.size(16)) ssum (sp1, sp0, 0, ssp3210);

    // Product Register Part (choose input according to ReducePrecLevel)
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            Products <= 0;
        else if (en == 1) begin
            case (ReducePrecLevel)
                2'b00: Products[15:0] <= ssp3210;                // full precesion
                2'b01: begin                                    // 4bit weigh precesion
                    Products[39:28] <= fsp32;
                    Products[11:0] <= fsp10;
                    end                                         
                2'b10: Products <= {{wx3}, {wx2}, {wx1}, {wx0}}; // 2bit weigh precesion
                2'b11: Products <= 40'bx;
                default: Products <= 40'b0;
            endcase
        end
    end

    // Accumulater Part
    reg [55:0] newAccum;
    always @(*) begin           // optimize new product result
        case (ReducePrecLevel)
            2'b00: newAccum = {{40{Products[15]}}, {Products[15:0]}};
            2'b01: newAccum = {{16{Products[39]}}, {Products[39:28]}, {16{Products[11]}}, {Products[11:0]}};            
            2'b10: newAccum = {{4{Products[39]}}, {Products[39:30]}, {4{Products[29]}}, {Products[29:20]}, {4{Products[19]}}, {Products[19:10]}, {4{Products[9]}}, {Products[9:0]}};
            2'b11: newAccum = 56'b0;
            default: newAccum = 56'b0;
        endcase
    end
    
	wire [55:0] oldAccum; 
    wire [55:0] AccumRes;
    reg [3:0] CIN;
    wire [3:0] COUT;
    assign oldAccum = Result;
    
    ADDERc #(14) acc0 (oldAccum[13:0], newAccum[13:0], CIN[0], AccumRes[13:0], COUT[0]);
    ADDERc #(14) acc1 (oldAccum[27:14], newAccum[27:14], CIN[1], AccumRes[27:14], COUT[1]);
    ADDERc #(14) acc2 (oldAccum[41:28], newAccum[41:28], CIN[2], AccumRes[41:28], COUT[2]);
    ADDERc #(14) acc3 (oldAccum[55:42], newAccum[55:42], CIN[3], AccumRes[55:42], COUT[3]);
    
    always @(*) begin               // decide carry in
        case(ReducePrecLevel)
            2'b00: CIN = {{COUT[2]}, {COUT[1]}, {COUT[0]}, 1'b0};
            2'b01: CIN = {{COUT[2]}, 1'b0, {COUT[0]}, 1'b0};
            2'b10: CIN = 4'b0;
            2'b11: CIN = 4'b0;
            default: CIN = 4'b0;
        endcase
    end

    // Register
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            Result <= 0;
        else if (en == 1)
            Result <= AccumRes;
    end

endmodule

module multiplier_8x2(
    input [1:0] W,          // signed or unsigned
    input [7:0] A,          // signed
    input mode,             // if 1, regards w as signed, else unsigned
    output [9:0] Result);     

    wire [7:0] W_01A, notA, temp, W_10A;
    assign W_01A = {8{W[0]}} & A;
    
    assign notA = ~A;
    genvar i;
    for (i=0; i<8; i=i+1) begin
        MUX_2 mx (.A(A[i]), .B(notA[i]), .sel(mode), .O(temp[i]));        
    end
    assign W_10A = {8{W[1]}} & temp;
    
    wire [8:0] OP1, OP2;
    wire CIN = W[1] & mode;
    wire [8:0] sumres;
    signExtender #(.size(7), .extsize(9)) op1se (W_01A[7:1], OP1);
    signExtender #(.size(8), .extsize(9)) op2se (W_10A, OP2);
    assign sumres = OP1 + OP2 + CIN;
    // ADDER #(.size(9)) sum (OP1, OP2, CIN, sumres);

    assign Result = {sumres, W_01A[0]};    
    
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

module ADDERc(op1, op2, cin, res, cout);     // with carry out
    parameter size = 12;
    input [size-1:0] op1, op2;
    input cin;
    output [size-1:0] res;
    output cout;
    wire [size:0] C;

    assign C = op1 + op2 + cin;
    assign res = C[size-1:0];
    assign cout = C[size];

endmodule
