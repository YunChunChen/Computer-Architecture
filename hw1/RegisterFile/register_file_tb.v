/***************************************************************************************************

[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    This is the test bench of the register_file.v module.
[Description] 1. This test bench will automatically generate random test patterns to verify
                 the implementation of the register file. 
              2. The test bench will toggle every bit in the register bank. 
              3. The test bench will verify the functionality of the register file automatically.
              
*****************************************************************************************************/

`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg        Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
	
    parameter  nPattern = 10;

    reg		   rst_n;
    reg	 [7:0] patterns[0:nPattern];
    
    integer    i, error_num, counter;   

    // instantiate the design-under-test
    register_file rf( Clk, WEN, RW, busW, RX, RY, busX, busY);

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars;
    end
   
    always begin
	    #(`HCYCLE) Clk = ~Clk;	//generaing clk
    end

    initial begin 		// Stimulus patterns
        Clk = 1;
	    rst_n = 1;
	    error_num = 0;

	    for( i = 0; i < nPattern ; i = i + 1 ) begin
		    patterns[i] = {$random}%256;
        end
	
	    #( `CYCLE * 0.5 ) rst_n = 0;
	    #( `CYCLE ) rst_n = 1;
	    #( 30 * `CYCLE ) 
	
        if(!error_num)
		    $display("\nCongratulations!! Your Verilog Code is correct!!\n");
	    else
		    $display("\nYour Verilog Code has %d errors. \n",error_num);
	    $finish;
    end

    always@(posedge Clk or negedge rst_n) begin
	    if( !rst_n ) begin
		    counter = 0;
			error_num = 0;
	    end
	    else begin
		    if (counter != 8 && counter != 16) begin
			    if (counter<8) begin
				    RX  <= 0;
				    RY  <= 0;
				    RW  <= counter[2:0];
				    WEN <= 1;
				    busW <= patterns[counter];
			    end
			    else if (counter<16) begin
				    RX  <= counter[2:0];
				    RY  <= 0;
				    RW  <= counter[2:0];
				    WEN <= 0;
				    busW<= 0;
				
				if (counter==9 && busX!==8'd0) begin
					error_num = error_num + 1;
					$display("error1 QQ!!! %b , %d\n",busX,counter);
				end	
				else if (counter!=9 && busX!==patterns[counter-9]) begin
					error_num = error_num + 1;
					$display("error2 QQ!!! %b , %d\n",busX,counter);
				end
			end
			else if (counter<24) begin
				RX  <= 0;
				RY  <= counter[2:0];
				RW  <= counter[2:0];
				WEN <= 0;
				busW<= 0;
				
				if (counter==17 && busY!==8'd0) begin
					error_num = error_num + 1;
					$display("error3 QQ!!! %b , %d\n",busY,counter);
				end
				else if (counter!=17 && busY!==patterns[counter-17]) begin
					error_num = error_num + 1;
					$display("error4 QQ!!! %b , %d\n",busY,counter);
				end
			end		
		end
		counter = counter+1;
	end
endmodule
