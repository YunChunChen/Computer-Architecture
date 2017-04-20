/*******************************************************************************************************

[Author]      Yun-Chun (Johnny) Chen
[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    This is the test bench of the alu.v module.
[Description] There are 16 functions to be verified. In order to verify them simultaneously, I
              declare 16 different objects of the alu module, and each one focuses on one operation 
              individually at one time.
[Note]        To avoid overflow issue, the input range of x and y should lie within -128 and 127 since
              x and y are 8-bit signed inputs. If the range of the input dissatisfied users' requirement,
              users are then suggested to modify the alu.v file and customize to their satisfaction. 

********************************************************************************************************/

`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module alu_tb;
    reg  [3:0] ctrl;
    reg  [3:0] ctrl1;
    reg  [3:0] ctrl2;
    reg  [3:0] ctrl3;
    reg  [3:0] ctrl4;
    reg  [3:0] ctrl5;
    reg  [3:0] ctrl6;
    reg  [3:0] ctrl7;
    reg  [3:0] ctrl8;
    reg  [3:0] ctrl9;
    reg  [3:0] ctrl10;
    reg  [3:0] ctrl11;
    reg  [3:0] ctrl12;
    reg  [3:0] ctrl13;
    reg  [3:0] ctrl14;
    reg  [3:0] ctrl15;
    reg  [3:0] ctrl16;
    reg  [7:0] x1;
    reg  [7:0] y1;
    reg  [7:0] x2;
    reg  [7:0] y2;
    reg  [7:0] x3;
    reg  [7:0] y3;
    reg  [7:0] x4;
    reg  [7:0] y4;
    reg  [7:0] x5;
    reg  [7:0] y5;
    reg  [7:0] x6;
    reg  [7:0] y6;
    reg  [7:0] x7;
    reg  [7:0] y7;
    reg  [7:0] x8;
    reg  [7:0] y8;
    reg  [7:0] x9;
    reg  [7:0] y9;
    reg  [7:0] x10;
    reg  [7:0] y10;
    reg  [7:0] x11;
    reg  [7:0] y11;
    reg  [7:0] x12;
    reg  [7:0] y12;
    reg  [7:0] x13;
    reg  [7:0] y13;
    reg  [7:0] x14;
    reg  [7:0] y14;
    reg  [7:0] x15;
    reg  [7:0] y15;
    reg  [7:0] x16;
    reg  [7:0] y16;
    wire       carry;
    wire       carry1;
    wire       carry2;
    wire [7:0] out;
    wire [7:0] out1;
    wire [7:0] out2;
    wire [7:0] out3;
    wire [7:0] out4;
    wire [7:0] out5;
    wire [7:0] out6;
    wire [7:0] out7;
    wire [7:0] out8;
    wire [7:0] out9;
    wire [7:0] out10;
    wire [7:0] out11;
    wire [7:0] out12;
    wire [7:0] out13;
    wire [7:0] out14;
    wire [7:0] out15;
    wire [7:0] out16;
    
    alu alu1 ( .ctrl(ctrl1), .x(x1), .y(y1), .carry(carry), .out(out1));
    alu alu2 ( .ctrl(ctrl2), .x(x2), .y(y2), .carry(carry), .out(out2));
    alu alu3 ( .ctrl(ctrl3), .x(x3), .y(y3), .carry(carry), .out(out3));
    alu alu4 ( .ctrl(ctrl4), .x(x4), .y(y4), .carry(carry), .out(out4));
    alu alu5 ( .ctrl(ctrl5), .x(x5), .y(y5), .carry(carry), .out(out5));
    alu alu6 ( .ctrl(ctrl6), .x(x6), .y(y6), .carry(carry), .out(out6));
    alu alu7 ( .ctrl(ctrl7), .x(x7), .y(y7), .carry(carry), .out(out7));
    alu alu8 ( .ctrl(ctrl8), .x(x8), .y(y8), .carry(carry), .out(out8));
    alu alu9 ( .ctrl(ctrl9), .x(x9), .y(y9), .carry(carry), .out(out9));
    alu alu10( .ctrl(ctrl10), .x(x10), .y(y10), .carry(carry), .out(out10));
    alu alu11( .ctrl(ctrl11), .x(x11), .y(y11), .carry(carry), .out(out11));
    alu alu12( .ctrl(ctrl12), .x(x12), .y(y12), .carry(carry), .out(out12));
    alu alu13( .ctrl(ctrl13), .x(x13), .y(y13), .carry(carry), .out(out13));
    alu alu14( .ctrl(ctrl14), .x(x14), .y(y14), .carry(carry), .out(out14));
    alu alu15( .ctrl(ctrl15), .x(x15), .y(y15), .carry(carry1), .out(out15));
    alu alu16( .ctrl(ctrl16), .x(x16), .y(y16), .carry(carry2), .out(out16));


   initial begin
       $dumpfile("alu.vcd");
       $dumpvars;
//        $fsdbDumpfile("alu.fsdb");
//        $fsdbDumpvars;
   end

    initial begin
        x1    = 8'b1111_1111;
        y1    = 8'b1111_1111;
        
 
        #(`CYCLE);
        // 0100 boolean not
        ctrl1 = 4'b0100;
	    
        #(`HCYCLE);
        if( out1 == 8'b0000_0000 ) $display( "PASS --- 0100 boolean not" );
        else $display( "FAIL --- 0100 boolean not" );
        // finish tb
        #(`CYCLE) $finish;
    end
    
    initial begin
        x2    = 8'b1111_1111;
        y2    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 0010 boolean and
        ctrl2 = 4'b0010;
 
        #(`HCYCLE);
        if( out2 == 8'b1111_1111 ) $display( "PASS --- 0010 boolean and" );
        else $display( "FAIL --- 0010 boolean and" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x3    = 8'b1111_1111;
        y3    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 0011 boolean or
        ctrl3 = 4'b0011;
        
        #(`HCYCLE);
        if( out3 == 8'b1111_1111 ) $display( "PASS --- 0011 boolean or" );
        else $display( "FAIL --- 0011 boolean or" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x4    = 8'b1111_1111;
        y4    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 0101 boolean xor
        ctrl4 = 4'b0101;
        
        #(`HCYCLE);
        if( out4 == 8'b0000_0000 ) $display( "PASS --- 0101 boolean xor" );
        else $display( "FAIL --- 0101 boolean xor" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x5    = 8'b1111_1111;
        y5    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 0110 boolean nor
        ctrl5 = 4'b0110;
        
        #(`HCYCLE);
        if( out5 == 8'b0000_0000 ) $display( "PASS --- 0110 boolean nor" );
        else $display( "FAIL --- 0110 boolean nor" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x6    = 8'b1111_1111;
        y6    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 0111 shift left logical variable
        ctrl6 = 4'b0111;
        
        #(`HCYCLE);
        if( out6 == 8'b1000_0000 ) $display( "PASS --- 0111 shift left logical variable" );
        else $display( "FAIL --- 0111 shift left logical variable");
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x7    = 8'b1111_1111;
        y7    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1000 shift right logical variable
        ctrl7 = 4'b1000;
        
        #(`HCYCLE);
        if( out7 == 8'b0000_0001 ) $display( "PASS --- 1000 shift right logical variable" );
        else $display( "FAIL --- 1000 shift right logical variable");
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x8    = 8'b1111_1111;
        y8    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1001 shift right arithmetic
        ctrl8 = 4'b1001;
        
        #(`HCYCLE);
        if( out8 == 8'b1111_1111 ) $display( "PASS --- 1001 shift right arithmetic" );
        else $display( "FAIL --- 1001 shift right arithmetic" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x9    = 8'b1111_1111;
        y9    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1010 rotate left
        ctrl9 = 4'b1010;
        
        #(`HCYCLE);
        if( out9 == 8'b1111_1111 ) $display( "PASS --- 1010 rotate left" );
        else $display( "FAIL --- 1010 rotate left" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x10    = 8'b1111_1111;
        y10    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1011 rotate right
        ctrl10 = 4'b1011;
        
        #(`HCYCLE);
        if( out10 == 8'b1111_1111 ) $display( "PASS --- 1011 rotate right" );
        else $display( "FAIL --- 1011 rotate right" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x11    = 8'b1111_1111;
        y11    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1100 equal
        ctrl11 = 4'b1100;
        
        #(`HCYCLE);
        if( out11 == 1 ) $display( "PASS --- 1100 equal" );
        else $display( "FAIL --- 1100 equal" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x12    = 8'b1111_1111;
        y12    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1101 no operation
        ctrl12 = 4'b1101;
        
        #(`HCYCLE);
        if( out12 == 0 ) $display( "PASS --- 1101 no operation" );
        else $display( "FAIL --- 1101 no operation" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x13    = 8'b1111_1111;
        y13    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1110 no operation
        ctrl13 = 4'b1110;
        
        #(`HCYCLE);
        if( out13 == 0 ) $display( "PASS --- 1110 no operation" );
        else $display( "FAIL --- 1110 no operation" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x14    = 8'b1111_1111;
        y14    = 8'b1111_1111;
   
 
        #(`CYCLE);
        // 1111 no operation
        ctrl14 = 4'b1111;
        
        #(`HCYCLE);
        if( out14 == 0 ) $display( "PASS --- 1111 no operation" );
        else $display( "FAIL --- 1111 no operation" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x15    = 8'b0000_0001;
        y15    = 8'b1111_1111;
 
        #(`CYCLE);
        // 0000 ADD
        ctrl15 = 4'b0000;
        
        #(`HCYCLE);
        if( (out15 == 8'b0000_0000) && (carry1 == 1'b0) ) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        x16    = 8'b1111_1111;
        y16    = 8'b0000_0000;
   
        #(`CYCLE);
        // 0000 SUB
        ctrl16 = 4'b0001;
        
        #(`HCYCLE);
        if( (out16 == 8'b1111_1111) && (carry2 == 1'b1) ) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0001 sub" );
        
        // finish tb
        #(`CYCLE) $finish;
    end

endmodule
