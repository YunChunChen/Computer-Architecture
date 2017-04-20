/***************************************************************************************************

[Author]      Yun-Chun (Johnny) Chen
[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    This is an 8x8 register file.
[Description] A register file consists of a set of registers which can be read or written. There 
              are 8 registers in the register file, and the width of the register is 8 bits.  
[Port]        busW : an 8-bit input data bus.              
              busX : an 8-bit output data bus. 
              busY : an 8-bit output data bus.
               WEN : Active high write enable.
                RW : Select 1 among 8 registers to be written. 
                RX : Select 1 among 8 registers to be read, output on busX.
                RY : Select 1 among 8 registers to be read, output on busY.
[Note]        1. 8 registers, $r0~$r7, $r0 = zero (constant zero, don't care any write operation).
              2. BusX and busY can be an arbitrary 8-bit vector during write operation.
              3. The data on busX will be written into a specified register synchronously on
                 positive edge of Clk.
              4. RW is the index of the register to be written.
              5. The register file behaves as a combinational logic block while reading. 
              6. Read the data in the register file asynchronously.
         
***************************************************************************************************/

module register_file( Clk, WEN, RW, busW, RX, RY, busX, busY);
    input            Clk, WEN;
    input      [2:0] RW, RX, RY;
    input      [7:0] busW;
    output reg [7:0] busX, busY;
    reg        [7:0] register [7:0]; // 8 registers to be written 

    initial begin
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
