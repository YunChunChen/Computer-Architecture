/****************************************************************************************************

[Author]      Yun-Chun (Johnny) Chen
[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    An 8-bit arithmetic logic unit module.
[Description] This is a simple implementation of the 8-bit alu using event-driven construct,
              "always block". 
[Port]         ctrl : A 4-bit control signal.
                  x : An 8-bit input signal ranging from -128 to 127 (2's complement).
                  y : An 8-bit input signal ranging from -128 to 127 (2's complement).
              carry : Carry is the most significant bit of the results of addition and subtraction.
                      Other operations perform on either x or y, carry will be considered as a 
                      don't care term.
                out : An 8-bit output that stores the results of the operation.
              
*****************************************************************************************************/

module alu( ctrl, x, y, carry, out);
    
    input      [3:0] ctrl;
    input      [7:0] x;
    input      [7:0] y;
    output reg [7:0] out;
    output reg       carry;

    // x and y should lie within 127 and -128 
    always@(x or y or ctrl) begin
             if (ctrl == 4'b0000) {carry, out} = {x[7], x} + {y[7], y};
        else if (ctrl == 4'b0001) {carry, out} = {x[7], x} - {y[7], y};
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
