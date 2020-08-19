// NOT WORKING //

module MAC_Unit(
    input [7:0] Activation, weight,
    input clk, rstn, en,
    input [1:0] ReducePrecLevel,
    output reg [2:0] count,
    output reg [15:0] PRODUCT,
    output reg [19:0] RESULT);

    // counter part
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            count = 0;
        else if (en == 1) begin
            count = count + 1;
        end
    end
    // logic minimized count signal (triger = 1 when last weight bit enter, done = 1 when first weight bit enter)
    assign trigger = count[0] & ((count[1]&ReducePrecLevel[0])|(count[2]&count[1])|(ReducePrecLevel[1]&~ReducePrecLevel[0]));
    assign done = ~count[0] & ((~count[1]&ReducePrecLevel[0])|(~count[2]&~count[1])|(ReducePrecLevel[1]&~ReducePrecLevel[0]));

    // calculate partial product
    wire Win = weight[count];
    wire [7:0] WA = {8{Win}} & Activation;

    // partial products summation
    wire [8:0] op1, op2;
    wire [7:0] WAprime = ~WA;
    genvar i;
    generate                    // op1: new partial product WA, if last PP, ~WA 
        for(i=0; i<8; i=i+1) begin
            MUX_2 mux (WA[i], WAprime[i], trigger, op1[i]);
        end
    endgenerate
    assign op1[8] = op1[7];     // sign extention

    wire [15:0] prevProduct = PRODUCT;
    wire [8:0] presum = {prevProduct[15], prevProduct[15:8]};
    generate                    // op2: accumulated partial products, if first PP, 0
        for(i=0; i<9; i=i+1) begin
            MUX_2 mux(presum[i], 1'b0, done, op2[i]);
        end
    endgenerate
    
    wire [8:0] partsumres;
    assign partsumres = op1 + op2 + trigger;
    // ADDER #(.size(9)) productACCUM (op1, op2, trigger, partsumres);

    // product result register
    wire [15:0] dPRODUCT = {partsumres, prevProduct[7:1]};  // 1bit shift right
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            PRODUCT = 0;
        else if (en == 1)
            PRODUCT = dPRODUCT;
    end

    // accumulator part (accumres = accold + accnew)
    wire [19:0] accold, accnew, accumres;
    assign accold = RESULT;
    assign accnew = {{4{PRODUCT[15]}}, PRODUCT};
    wire [2:1] CIN;
    wire [2:0] COUT;
    MUX_2 cin2control (COUT[1], 1'b0, ReducePrecLevel[1], CIN[2]);     // decide adder carry in
    MUX_2 cin1control (COUT[0], 1'b0, ReducePrecLevel[0], CIN[1]);

    ADDERc #(14) acc2 (accold[19:6], accnew[19:6], CIN[2], accumres[19:6], COUT[2]);
    ADDERc #(2) acc1 (accold[5:4], accnew[5:4], CIN[1], accumres[5:4], COUT[1]);
    ADDERc #(4) acc0 (accold[3:0], accnew[3:0], 0, accumres[3:0], COUT[0]);
        
    // accumulator register, update whenever product calculate done
    always @(negedge done, negedge rstn) begin
        if(rstn == 0)
            RESULT = 0;
        else if (en == 1)
            RESULT = accumres;
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

module ADDERc(op1, op2, cin, res, cout);     // with carry out
    parameter size = 12;
    input [size-1:0] op1, op2;
    input cin;
    output [size-1:0] res;
    output cout;
    wire [size:0] C;

    assign C = op1 + op2 + cin;
    assign cout = C[size];
    assign res = C[size-1:0];

endmodule
