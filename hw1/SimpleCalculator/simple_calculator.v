/*****************************************************************************************************

[Author]      Yun-Chun (Johnny) Chen
[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    This is the module of a simple calculator.
[Description] This module combines the alu module and the register file module to realize a 
              simple calculator unit. For the implementation details of the alu module and 
              the register file module, please refer to the ALU directory and the RegisterFile
              directory.
[Port]        Sel : When Sel = 0, DataIn is passed to port x of ALU.
                    When Sel = 1, the data loaded to port x of ALU is from the register file.
              Other port's declaration details, please refer to the alu.v module and register_file.v
              module.

******************************************************************************************************/

module register_file( Clk, WEN, RW, busW, RX, RY, busX, busY);
    input            Clk, WEN;
    input      [2:0] RW, RX, RY;
    input      [7:0] busW;
    output reg [7:0] busX, busY;
    
    reg        [7:0] register [7:0]; // 8 registers to be written 

    always@(*) begin
        register[0] = 8'd0;
        register[1] = 8'd0;
        register[2] = 8'd0;
        register[3] = 8'd0;
        register[4] = 8'd0;
        register[5] = 8'd0;
        register[6] = 8'd0;
        register[7] = 8'd0;
    end

    always@(posedge Clk) begin
 	    if (WEN && RW != 0)
    	    register[RW] <= busW;
    end

    always@(RX, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7]) begin
        busX <= register[RX];
    end

    always@(RY, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7]) begin
        busY <= register[RY];
    end
endmodule

module alu( ctrl, x, y, carry, out);
    input      [3:0] ctrl;
    input      [7:0] x;
    input      [7:0] y;
    output reg [7:0] out;
    output reg       carry;

    // x and y should lie within 127 and -128 
    always@(x or y or ctrl) begin
             if (ctrl == 4'b0000) begin {carry, out} = {x[7], x} + {y[7], y}; end
        else if (ctrl == 4'b0001) begin {carry, out} = {x[7], x} - {y[7], y}; end
        else if (ctrl == 4'b0010) out = x & y;
        else if (ctrl == 4'b0011) out = x | y;
        else if (ctrl == 4'b0100) out = ~x;
        else if (ctrl == 4'b0101) out = x ^ y;
        else if (ctrl == 4'b0110) out = ~(x | y);
        else if (ctrl == 4'b0111) out = y << x[2:0];
        else if (ctrl == 4'b1000) out = y >> x[2:0];    
        else if (ctrl == 4'b1001) out = {x[7], x[7:1]};  
        else if (ctrl == 4'b1010) out = {x[6:0], x[7]};
        else if (ctrl == 4'b1011) out = {x[0], x[7:1]};
        else if (ctrl == 4'b1100) out = ( x == y ) ? 1 : 0;
        else if (ctrl == 4'b1101) out = 0;
        else if (ctrl == 4'b1110) out = 0;
        else if (ctrl == 4'b1111) out = 0;
    end 	
endmodule

module Mux( out, in1, in2, sel);
    output reg [7:0] out;
    input      [7:0] in1; // DataIn
    input      [7:0] in2; // busX
    input            sel;
 
    always@(in1, in2) begin
        if (sel) out <= in2;
        else     out <= in1;
    end   
endmodule

module simple_calculator( Clk, WEN, RW, RX, RY, DataIn, Sel, Ctrl, busY, Carry);
    input         Clk;
    input         WEN;
    input   [2:0] RW, RX, RY;
    input   [7:0] DataIn;
    input         Sel;
    input   [3:0] Ctrl;
    output  [7:0] busY;
    output        Carry;

    wire    [7:0] busX;           // register_file's busX
    wire    [7:0] ALUOutput;      // ALU's out and register's input
    wire    [7:0] MuxOutput;      // mux's output and alu's input	
    reg     [7:0] register [7:0]; // 8 registers to be written


    register_file _regFile ( .Clk(Clk), .WEN(WEN), .RW(RW), .busW(ALUOutput), .RX(RX), .RY(RY), .busX(busX), .busY(busY)); 
    alu           _alu ( .ctrl(Ctrl), .x(MuxOutput), .y(busY), .carry(Carry), .out(ALUOutput));    
    Mux           _mux ( .out(MuxOutput), .in1(DataIn), .in2(busX), .sel(Sel));	
    	
endmodule
