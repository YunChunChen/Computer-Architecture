/**************************************************************************************************

[Author]      Yun-Chun (Johnny) Chen
[Affiliation] Department of Electrical Engineering, National Taiwan University
[Language]    Verilog
[Function]    Single Cycle MIPS
[Description] This is the module of a single cycle MIPS. The supported instructions are
              listed in below.
[Instruction] add, sub, and, or, slt
              lw, sw
              beq
              j, jal, jr
[Port]        clk: clock input.
              D: data inputs.
              A: address.
              CEN: chip enable, 0 when you read/write data.
              WEN: write enable, 0 when you write data into SRAM, 1 when you read data from SRAM.
              OEN: output enable, always 0 in this case,
              Q: data outputs.
[Note]        clock: Positive edge triggered.
              reset: Active low asynchronous reset.
              memory: The data memory is isolated and defined in other file.
              register file: 1. All registers are reset to 0 when reset occurs.
                             2. Register $0 must always be 0.

***************************************************************************************************/


// Single Cycle MIPS
//===============================================================
// Input/Output Signals:
// positive-edge triggered         clk
// active low asynchronous reset   rst_n
// instruction memory interface    IR_addr, IR
// output for testing purposes     RF_writedata  
//===============================================================
// Wire/Reg Specifications:
// control signals             MemToReg, MemRead, MemWrite, 
//                             RegDST, RegWrite, Branch, 
//                             Jump, ALUSrc, ALUOp
// ALU control signals         ALUctrl
// ALU input signals           ALUin1, ALUin2
// ALU output signals          ALUresult, ALUzero
// instruction specifications  r, j, jal, jr, lw, sw, beq
// sign-extended signal        SignExtend
// MUX output signals          MUX_RegDST, MUX_MemToReg, 
//                             MUX_Src, MUX_Branch, MUX_Jump
// registers input signals     Reg_R1, Reg_R2, Reg_W, WriteData 
// registers                   Register
// registers output signals    ReadData1, ReadData2
// data memory contral signals CEN, OEN, WEN
// data memory output signals  ReadDataMem
// program counter/address     PCin, PCnext, JumpAddr, BranchAddr
//===============================================================

module SingleCycle_MIPS( clk, rst_n, IR_addr, IR, RF_writedata, ReadDataMem, CEN, WEN, A, ReadData2, OEN);

    //==== in/out declaration =================================
    //-------- processor ----------------------------------
    input             clk, rst_n;
    input      [31:0] IR;
    output reg [31:0] IR_addr, RF_writedata;
    
    //-------- data memory --------------------------------
    input      [31:0] ReadDataMem;  // read_data from memory
    output reg        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output reg        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output reg  [6:0] A;  // address
    output reg [31:0] ReadData2;  // write_data to memory
    output reg        OEN;  // output_enable, 0

    //==== reg/reg declaration ===============================

    // register declaration
    reg        [31:0] register [0:31]; // 32 registers with 32 bits each
   
    // control ports declaration
    reg               RegDst, Jump, Branch, MemRead, MemtoReg, ALUOp0, ALUOp1, MemWrite, ALUSrc, RegWrite; // control signal, output ports
    reg         [5:0] ControlInput; // control input, input ports
   
    // sign extend ports declaration
    reg        [15:0] SignExtendInput;  // sign extend input port
    reg        [31:0] SignExtendOutput; // sign extend output port

    // mux signal declaration
    reg               jal, jr; // Mux signal

    // ALU ports declaration
    reg         [3:0] ALUCtrl; // ALU control signal
    reg        [31:0] ALUInput1, ALUInput2, ALUResult; // ALU I/O ports
    reg               ALUZero; // ALU I/O port

    // register ports declaration
    reg         [4:0] ReadRegister1, ReadRegister2, WriteRegister; // register input ports
    reg         [4:0] WriteRegister0, WriteRegister1; // input ports of mux in front of write register
    reg        [31:0] WriteData; // register write data input port
    reg        [31:0] ReadData1; // register output ports

    // program counter variables declaration
    reg        [31:0] ProgramCounter4, ProgramCounterNext, JumpAddress, BranchAddress;

    // instruction decoding variables declaration
    reg         [5:0] opcode; // the first 6 bits of instruction
    reg         [5:0] funct;  // the last 6 bits of instruction

    integer           i; // for loop index 

    //==== combinational part =================================
    always @(*) begin
        opcode          = IR[31:26];
        ReadRegister1   = IR[25:21];
        ReadRegister2   = IR[20:16];
        WriteRegister0  = IR[20:16];
        WriteRegister1  = IR[15:11];
        SignExtendInput = IR[15:0];
        funct           = IR[5:0];
        RegDst          = 1'b0;
        ALUSrc          = 1'b0;
        MemtoReg        = 1'b0;
        RegWrite        = 1'b0;
        MemRead         = 1'b0;
        MemWrite        = 1'b0;
        Branch          = 1'b0;
        ALUOp1          = 1'b0;
        ALUOp0          = 1'b0;
        Jump            = 1'b0;
        jal             = 1'b0;
        jr              = 1'b0;

        // Control signal setting part
        // R-format, jump return (jr)
        if (opcode == 6'b000000) begin
            RegDst   = 1'b1;
            ALUSrc   = 1'b0;
            MemtoReg = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            Branch   = 1'b0;
            ALUOp1   = 1'b1;
            ALUOp0   = 1'b0;
            Jump     = 1'b0;
            jal      = 1'b0;
        
            // if is jump return (jr)
            if (funct == 6'b001000) begin 
                RegWrite = 1'b0;
                jr       = 1'b1;
            end
            else begin
                RegWrite = 1'b1;
                jr       = 1'b0;
            end
        end

        // load word (lw)
        else if (opcode == 6'b100011) begin
            RegDst   = 1'b0;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b1;
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            MemWrite = 1'b0;
            Branch   = 1'b0;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b0;
            Jump     = 1'b0;
            jal      = 1'b0;
        end

        // store word (sw)
        else if (opcode == 6'b101011) begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b1;
            Branch   = 1'b0;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b0;
            Jump     = 1'b0;
            jal      = 1'b0;
        end

        // branch equal (beq)
        else if (opcode == 6'b000100) begin
            ALUSrc   = 1'b0;
            RegWrite = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            Branch   = 1'b1;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b1;
            Jump     = 1'b0;
            jal      = 1'b0;
        end

        // jump (j)
        else if (opcode == 6'b000010) begin
            RegDst   = 1'b0;
            ALUSrc   = 1'b0;
            MemtoReg = 1'b0;
            RegWrite = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            Branch   = 1'b0;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b0;
            Jump     = 1'b1; 
            jal      = 1'b0; 
        end

        // jump and link (jal)
        else if (opcode == 6'b000011) begin
            RegDst   = 1'b0;
            ALUSrc   = 1'b0;
            MemtoReg = 1'b0;
            RegWrite = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            Branch   = 1'b0;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b0;
            Jump     = 1'b1; // jal needs to set Jump to 1 
            jal      = 1'b1; 
        end

        // if opcode not found, set all the values to 0
        else begin
            RegDst   = 1'b0;
            ALUSrc   = 1'b0;
            MemtoReg = 1'b0;
            RegWrite = 1'b0;
            MemRead  = 1'b0;
            MemWrite = 1'b0;
            Branch   = 1'b0;
            ALUOp1   = 1'b0;
            ALUOp0   = 1'b0;
            Jump     = 1'b0; 
            jal      = 1'b0; 
        end
    
        // ALUCtrl part
        // load word (lw), store word (sw), add
        if (ALUOp1 == 1'b0 && ALUOp0 == 1'b0)
            ALUCtrl = 4'b0010;

        // branch equal (beq), sub
        else if (ALUOp1 == 1'b0 && ALUOp0 == 1'b1)
            ALUCtrl = 4'b0110;

        else if (ALUOp1 == 1'b1 && ALUOp0 == 1'b0) begin
                 if (funct == 6'b100000)  ALUCtrl = 4'b0010; // add
            else if (funct == 6'b100010)  ALUCtrl = 4'b0110; // sub
            else if (funct == 6'b100100)  ALUCtrl = 4'b0000; // and
            else if (funct == 6'b100101)  ALUCtrl = 4'b0001; // or
            else if (funct == 6'b101010)  ALUCtrl = 4'b0111; // slt
        end

        // mux in front of write register part
        if (RegDst == 1'b0)  WriteRegister = WriteRegister0;
        else                 WriteRegister = WriteRegister1;

        // load data part
        ReadData1 = register[ReadRegister1];
        ReadData2 = register[ReadRegister2]; 

        // sign extension part
        SignExtendOutput = SignExtendInput;

        // ALUInput1
        ALUInput1 = ReadData1;

        // mux in front of ALU part
        if (ALUSrc == 1'b0)  ALUInput2 = ReadData2;
        else                 ALUInput2 = SignExtendOutput;

        // ALU part
        // add
        if (ALUCtrl == 4'b0010) begin
            ALUResult = ALUInput1 + ALUInput2; 
            ALUZero   = 1'b0;
        end

        // sub 
        else if (ALUCtrl == 4'b0110) begin
            ALUResult = ALUInput1 - ALUInput2; 
            if (ALUInput1 == ALUInput2) ALUZero = 1'b1;
            else                        ALUZero = 1'b0; // sub part
        end

        // and
        else if (ALUCtrl == 4'b0000) begin
            ALUResult = ALUInput1 & ALUInput2; 
            ALUZero   = 1'b0;
        end

        // or
        else if (ALUCtrl == 4'b0001) begin
            ALUResult = ALUInput1 | ALUInput2; 
            ALUZero   = 1'b0;
        end

        // set on less than (slt)
        else if (ALUCtrl == 4'b0111) begin
            if (ALUInput1 < ALUInput2) ALUResult = 1'b1;
            else                       ALUResult = 1'b0;
            ALUZero = 1'b0;
        end

        // get the address from ALUResult, discard the last 2 bits
        A = ALUResult[8:2];

        if (MemWrite == 1'b1) begin
            CEN = 1'b0;
            WEN = 1'b0;
            OEN = 1'b0;
        end
    
        else if (MemRead == 1'b1) begin
            CEN = 1'b0;
            WEN = 1'b1;
            OEN = 1'b0;
        end
    
        if (MemtoReg == 1'b1) WriteData = ReadDataMem;
        else                  WriteData = ALUResult;

        RF_writedata = WriteData;
    
        ProgramCounter4 = IR_addr + 4;

        // Program counter part
        BranchAddress = ProgramCounter4 + {SignExtendOutput[29:0], 2'b00}; // output of the ALU for program counter 
        JumpAddress   = {ProgramCounter4[31:28], IR[25:0], 2'b0}; // input of the mux for program counter
    
        if (jr == 1'b1) ProgramCounterNext = register[31]; // $ra is stored in register[31]
        else if (Jump == 1'b1) ProgramCounterNext = JumpAddress;
        else if (ALUZero == 1'b1 && Branch == 1'b1) ProgramCounterNext = BranchAddress;
        else                                        ProgramCounterNext = ProgramCounter4;
    end


    //==== sequential part ====================================
    always @(posedge clk) begin
        
        if (rst_n == 1'b0) begin
            for (i = 0 ; i < 32 ; i = i + 1)
                register[i] <= 32'b0;
            IR_addr <= 32'b0;
        end
        
        else begin 
        
            // get the instruction address
            IR_addr <= ProgramCounterNext;
        
            // write into register
            if (RegWrite == 1'b1) begin
                if (WriteRegister != 1'b0) // register[0] should always be 0
                    register[WriteRegister] <= WriteData;
            end
        
            // store the program counter of next instruction into register[31] $ra
            if (jal == 1'b1) register[31] <= ProgramCounter4;
        end
    end
endmodule
