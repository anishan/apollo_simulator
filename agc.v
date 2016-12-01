//control unit
`timescale 1 ns / 1 ps
`include "sequencegenerator.v"
`include "pc.v"
`include "memory_agc.v"

module ctrl_unit
(
input clk
);

wire tp1;
wire tp2;
wire tp3;
wire tp4;
wire tp5;
wire tp6;
wire tp7;
wire memWE; //set with ctrl
wire [11:0] MemAddr; //set with ctrl
wire [14:0] DataIn; //set with ctrl
wire [14:0]  DataOut;
wire memtp;

reg extracode;
reg [15:0] PC; //program counter
reg [2:0] OpCode;
reg [1:0] QC;
reg Peripheral_C; //PERIPHERAL CODE
reg [11:0] Addr12;
reg [9:0] Addr10;
reg [14:0] instr;

// Encodings for Operations
localparam tc = 3'b000;
localparam ccsanddv = 3'b001;
localparam index = 3'b;
localparam xch = 3'b101;
localparam cs = 3'b100;
localparam ts = 3'b101;
localparam adandsu = 3'b110;
localparam maskandmp = 3'b111;
localparam  aAddr = 12'b000000000000;
localparam  qAddr = 12'b000000000001;
localparam  zAddr = 12'b000000000010;

//create timing pulses
sequence_generator sequencegen(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7);
//have tp1 and tp2 together for when memory should run
and andgate1(memtp, tp1, tp2); // and together all timing pulses where mem should run
//memory
Data_memory memory(memWE, memtp, MemAddr, DataIn, DataOut);
//decode the instruction just read from memory
InstrFetchUnit instrFetch(tp4, instr, OpCode, QC, PC, Addr12, Addr10);

//timing pulses
//tp 1: fetch pc from z reg
//tp 2: write incremented pc to z reg
//tp 3: instruction fetch from memory
//tp 4: instruction decode
//tp 5: 1st opportunity to save to a reg
//tp 6: 2nd save to reg
//tp 7: tbd

always @(posedge clk) begin
    if (tp1 == 1)begin //read what PC is from Z reg
        memWE <=0;
        MemAddr <= zAddr;
        PC <= DataOut;
    end
    if (tp2 == 1) begin//write PC + 1 into Z's reg
        PC <= PC+1;
        memWE <= 1;
        MemAddr <= zAddr;
        DataIn <= PC;
    end
    if (tp3 == 1) begin  //set address to the PC
        MemAddr <= PC;
        memWE <= 0;
        instr <= DataOut;
    end

    if (tp4 == 1) begin
        memWE <= 0;
        //tp 4 is directly wired to instruction fetch unit (decoding)
    end


    case (Op)
	   tc: begin
           // transfer control
           //have it write the jump address to Z on second tp while Q is set to Z
           if (tp5 == 1) begin
                //save Z to Q
                memWE <=1;
                MemAddr <= qAddr;
                DataIn <= PC;
           end

           if (tp6 == 1) begin
                //write the jump address to reg Z
                memWE <=1;
                MemAddr <= zAddr;
                DataIn <= Addr12;
           end
       end

       ccsanddv: begin
            //count, compare and skip or dv
            //check extracode
            if (extracode) begin
                //then DV
            end
            else begin
                //then CCS
            end
       end
       index: begin
            //extra should be high.
       end
       xch: begin
            //exchange
       end
       cs: begin
        //clear and subtract
       end
       ts: begin
            // transfer to storage
       end
       adandsu: begin
            if (extracode) begin
           //then subtract
            end
                else begin
           //then add
            end
       end
       maskandmp: begin
            if (extracode) begin
            //then multiply
            end
            else begin
            //then mask
            end
       end
    endcase
end


endmodule
