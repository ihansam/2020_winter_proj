module MAC_Unit();
    input [7:0] Activetion, Weigt;
    input ReducePrecLevel, clk, rstn, en;
    wire [39:0] Products;
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
        case (ReducePrecLevel)      
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
    signExtender #(.size(12), .extamt(4)) ses2 (fsp10, sp0);

    wire [15:0] ssp3210;
    ADDER #(.size(16)) ssum (sp1, sp0, 0, ssp3210);

    // Product Register Part (need to choose input according to MODE)
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            // reset
        else if (en == 1)
            // do something
    end

    // Accumulate Register Part
    // do something

endmodule

module multiplier_8x2();     
    input [7:0] A;          //signed
    input [1:0] W;          //signed or unsigned ^^ 
    output [9:0] result;

    assign result = A*W;

endmodule

module shifter();
    parameter shamt = 2;
    parameter size = 10;
    input [size-1:0] X;
    output [size-1+shamt:0] O;

    assign O = X<<shamt;

endmodule

module signExtender();
    parameter size = 10;
    parameter extamt = 2;
    input [size-1:0] X;
    output [size-1+extamt:0] O;

    assign O = {extamt{X[size-1]}, X};

endmodule

module ADDER(op1, op2, cin, res);     // size bit의 두 operand 덧셈만
    parameter size = 12;
    input cin = 0;
    input [size-1:0] op1, op2;
    output [size-1:0] res;
    wire [size:0] C;

    genvar i;
    assign C[0] = cin;
    
    generate
        for(i=0; i<size; i=i+1) begin
            fullAdder FA (.a(op1[i]), .b(op2[i]), .ci(C[i]), .s(res[i]), .co(C[i+1]));
        end
    endgenerate

endmodule

module fullAdder(a, b, ci, s, co);
    input a, b, ci;
    output s, co;

    assign s = a^b^ci;
    assign co = (a&b)|(a&ci)|(b&ci);

endmodule