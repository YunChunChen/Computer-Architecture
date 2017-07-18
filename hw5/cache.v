module cache( clk, proc_reset, proc_read, proc_write, proc_addr, proc_wdata, proc_stall, proc_rdata, mem_read, mem_write, mem_addr, mem_rdata, mem_wdata, mem_ready);
    
//==== input/output definition ============================
    input              clk;
    // processor interface
    input              proc_reset;
    input              proc_read, proc_write;
    input       [29:0] proc_addr;
    input       [31:0] proc_wdata;
    output reg         proc_stall;
    output reg  [31:0] proc_rdata;
    // memory interface
    input      [127:0] mem_rdata;
    input              mem_ready;
    output reg         mem_read, mem_write;
    output reg  [27:0] mem_addr;
    output reg [127:0] mem_wdata;
    
//==== wire/reg definition ================================
    
    // valid bit: [154], dirty bit: [153], tag: [152:128]
    // data_0: [127:96], data_1: [95:64], data_2: [63:32], data_3: [31:0]
    reg    [154:0] cache [7:0]; // 8 caches, each width is 155
    reg    [154:0] array; // for temporary storage use

    integer i; // for loop index
    
//==== combinational circuit ==============================
    always@ (*) begin
        // initialization of ports regarding processor
        proc_stall = 1;
        proc_rdata = 32'b0;

        // initialization of ports regarding memory
        mem_read = 0;
        mem_write = 0;
        mem_addr = 28'b0;
        mem_wdata = 128'b0;

        // initialization of array, the initial value depends on the 
        // address indicates in proc_addr[4:2]
        array = cache[proc_addr[4:2]];

        // read case
        if (proc_read) begin
            // check valid bit
            if (array[154]) begin // valid bit is 1
                // read hit
                if (array[152:128] == proc_addr[29:5]) begin // same tag
                    if (proc_addr[1:0] == 2'b00)      proc_rdata = array[127:96];
                    else if (proc_addr[1:0] == 2'b01) proc_rdata = array[95:64];
                    else if (proc_addr[1:0] == 2'b10) proc_rdata = array[63:32];
                    else                              proc_rdata = array[31:0];
	            proc_stall = 0;
                end
                // read miss
                else begin
                    // check dirty bit
                    if (array[153]) begin // dirty bit == 1
	                if (mem_ready)
			    array[153] = 0; // set dirty bit to 0 indicating that the array can be written
                        else begin // write data into memory
                            mem_write = 1; // write data into memory
                            mem_wdata = {array[31:0], array[63:32], array[95:64], array[127:96]}; // write data
                            mem_addr = {array[152:128], proc_addr[4:2]};
                        end
                    end
                    else begin // dirty bit == 0
                        if (mem_ready) begin
                            array[127:0]   = {mem_rdata[31:0], mem_rdata[63:32], mem_rdata[95:64], mem_rdata[127:96]}; // read data from memory and write into array
                            array[152:128] = proc_addr[29:5]; // update tag
                        end 
                        else begin
                            mem_read = 1;
                            mem_addr = proc_addr[29:2];
                        end 
                    end
                end
            end
            else begin // valid bit is 0
                if (mem_ready) begin
                    array[127:0]   = {mem_rdata[31:0], mem_rdata[63:32], mem_rdata[95:64], mem_rdata[127:96]}; // read data from memory
                    array[152:128] = proc_addr[29:5]; // update tag
                    array[153] = 0; // set dirty bit to 0
                    array[154] = 1; // set valid bit to 1
                end
	        else begin 
		    mem_read = 1;
                    mem_addr = proc_addr[29:2];
		end
            end
        end

        // write case
        else if (proc_write) begin
            // check valid bit
            if (array[154]) begin // valid bit is 1
                if (array[152:128] == proc_addr[29:5]) begin // same tag
                    if (proc_addr[1:0] == 2'b00)      array[127:96] = proc_wdata;
                    else if (proc_addr[1:0] == 2'b01) array[95:64]  = proc_wdata;
                    else if (proc_addr[1:0] == 2'b10) array[63:32]  = proc_wdata;
                    else                              array[31:0]   = proc_wdata;
                    array[153] = 1; // set dirty bit to 1
		    proc_stall = 0;
                end
                else begin // different tags
                    // check dirty bit
                    if (array[153]) begin // dirty bit == 1
			if (mem_ready)
                            array[153] = 0;
                        else begin // write data into memory
                            mem_write = 1; // write data into memory
                            mem_wdata = {array[31:0], array[63:32], array[95:64], array[127:96]}; // write data
                            mem_addr = {array[152:128], proc_addr[4:2]}; // mem_addr = tag + block_num
                        end
                    end
                    else begin // dirty bit == 0
                        if (mem_ready) begin
                            array[127:0]   = {mem_rdata[31:0], mem_rdata[63:32], mem_rdata[95:64], mem_rdata[127:96]}; // read data from memory
                            array[152:128] = proc_addr[29:5]; // update tag
                            array[154] = 1; // set valid bit to 1
                        end 
                        else begin
                            mem_read = 1;
                            mem_addr = proc_addr[29:2];
                        end 
                    end
                end
            end
            else begin // valid bit is 0
                if (mem_ready) begin
                    array          = {mem_rdata[31:0], mem_rdata[63:32], mem_rdata[95:64], mem_rdata[127:96]}; // read data from memory
                    array[152:128] = proc_addr[29:5]; // update tag
                    array[153] = 0; // set dirty bit to 0
                    array[154] = 1; // set valid bit to 1
                end 
                else begin
                    mem_read = 1;
                    mem_addr = proc_addr[29:2];
                end 
            end
        end
    end
//==== sequential circuit =================================
    always@( posedge clk or posedge proc_reset ) begin
       if( proc_reset )
           for ( i = 0 ; i < 8 ; i = i+1 )
              cache[i] <= 155'b0; // reset the cache to 0 
       else cache[proc_addr[4:2]] <= array; // write data into cache
    end
endmodule
