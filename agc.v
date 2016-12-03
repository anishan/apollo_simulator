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
wire tp8;
wire tp9;
wire memWE; //set with ctrl
wire [11:0] MemAddr; //set with ctrl
wire [14:0] DataIn; //set with ctrl
wire [14:0]  DataOut;
wire memtp;
wire [29:0] temp_computation;

reg extracode_flag
reg [15:0] PC; //program counter
reg [2:0] OpCode;
reg [1:0] QC;
reg Peripheral_C; //PERIPHERAL CODE
reg [11:0] Addr12;
reg [9:0] Addr10;
reg [14:0] instr;
reg overflow_flag;
reg [14:0] G_reg;
reg S2; //the copy of the most sig bit for overflow checks
reg hiddenreg; //for index
reg index_flag; //to know the next instruction needs + the hidden reg

// Encodings for Operations
localparam tc = 3'b000;
localparam ccsanddv = 3'b001;
localparam index = 3'b;
localparam xch = 3'b101;
localparam cs = 3'b100;
localparam ts = 3'b101;
localparam adandsu = 3'b110;
localparam maskandmp = 3'b111;
// the double instruction
localparam  aAddr = 12'b000000000000;
localparam  qAddr = 12'b000000000001;
localparam  zAddr = 12'b000000000010;
localparam  lAddr = 12'b000000000011;

//create timing pulses
sequence_generator sequencegen(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8, t[9]);
//have tp1 and tp2 together for when memory should run
and andgate1(memtp, tp1, tp2, tp5, tp6,tp7, tp8, tp9); // and together all timing pulses where mem should run
//memory
Data_memory memory(memWE, memtp, clk, MemAddr, DataIn, DataOut);
//decode the instruction just read from memory
InstrFetchUnit instrFetch(tp4, instr, OpCode, QC, PC, Addr12, Addr10);

//timing pulses
//tp 1: fetch pc from z reg
//tp 2: write incremented pc to z reg
//tp 3: instruction fetch from memory
//tp 4: instruction decode
//tp 5: 1st opportunity to save to a reg
//tp 6: 2nd save to reg
//tp 7:
//tp 8:
//tp 9:

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

    if (tp5 == 1) begin
        if (index_flag) begin
            instr <= instr + hiddenreg;
            index_flag <=0;
        end
    end

    case (Op)
	   tc: begin
           // transfer control
           //have it write the jump address to Z on second tp while Q is set to Z
           if (tp6 == 1) begin
                //save Z to Q
                memWE <=1;
                MemAddr <= qAddr;
                DataIn <= PC;
           end
           if (tp7 == 1) begin
                //write the jump address to reg Z
                memWE <=1;
                MemAddr <= zAddr;
                DataIn <= Addr12;
           end
       end

       ccsanddv: begin
            //count, compare and skip or dv
            //check extracode_flag
            if (extracode_flag) begin
                //then DV
                if (tp6) begin
                // load G with the thing to divide by
                    memWE <= 0;
                    memAddr <= Addr12;
                    G_reg <= DataOut;
                end
                if (tp7) begin
                    memWE <= 0;
                    memAddr <= aAddr;
                    temp_computation <= {DataOut, 15'b000000000000000};
                end
                if (tp8) begin
                    memWE <= 0;
                    memAddr <= lAddr;
                    temp_computation[14:0] <= DataOut;
                end
                if (tp9) begin
                    // temp_computation<= temp_computation/G_reg;
                    //separating quotient from remainder
                    //have to overflow correct, quotient goes in A and remainder goes in L
                end

                //at the end, clear extracode_flag
                extracode_flag <= 0;
                overflow_flag <=0;
            end
            else begin
                //then CCS
                extracode_flag <= 0;
                if (tp6 ) begin
                    memWE <= 0;
                    memAddr <= {2'b00, Addr10}; 

                end
                if (tp7) begin

                end
                if (tp8) begin

                end
                //need to set overflow
            end
       end

       index: begin
            //extra should be high.
            //add the data retrieved at address specified to the next instruction -- see tp == 4 (not case)
            if (tp5 == 1) begin
                //save index's address to a hidden reg.
                memAddr <= Addr12;
                hiddenreg<= DataOut;
                index_flag <=1;
            end
       end
       xch: begin
            //exchange
            // if (tp5 == 1) begin
            //     memWE <=0;
            //     MemAddr <= {2'b00, Addr10};  //always EXCHANGE with erasable memory
            //     G_reg <= DataOut;
            // end
            // if (tp6 == 1)begin
            //     memWE <=1;
            //     MemAddr <= aAddr;
                    extracode_flag <= 0;
            // end

       end
       cs: begin
        //clear and subtract
        //load reg A with @ a mem
            if (tp6 == 1) begin
                memWE <=0;
                S2 <= 0;
                extracode_flag <= 0;
                memAddr <= Addr12;
                G_reg <= ~DataOut;
            end
            if (tp7) begin
            //save NOT version of data @mem into register A.
                MemAddr <= aAddr;
                memWE <= 1;
                DataIn <= G_reg;
            end

       end
       ts: begin
            // transfer to storage

            //look at overflow, save into reg A if there is some, then clear overflow
       end
       adandsu: begin
            if (extracode_flag) begin
           //then subtract

           if (tp6 == 1) begin
               //save mem[addr] given to reg G
               memWE <=0;
               MemAddr <= Addr12;
               G_reg <= DataOut;
           end

           if (tp7 = 1) begin
               //read what is in reg A
               memWE <= 1; //
               MemAddr <= aAddr;
               S2 <= DataOut[15]; //keep a duplicate of most sig for overflow
               G_reg <= DataOut - G_reg; //reg A's contents -reg G's contents
           end

          if (tp8 == 1) begin
               //save to reg A.
               memWE <=1;
               MemAddr <= aAddr;
               DataIn <= G_reg;
               extracode_flag <= 0;
          end

            end
            else begin
           //then add
            if (tp6 == 1) begin
                //save mem[addr] given to reg G
                memWE <=0;
                MemAddr <= Addr12;
                G_reg <= DataOut;
            end

            if (tp7 = 1) begin
                //read what is in reg A
                memWE <= 0;
                MemAddr <= aAddr;
                S2 <= DataOut[15]; //keep a duplicate of most sig for overflow
                G_reg <= G_reg + DataOut; //reg G's contents + reg A's contents
            end

           if (tp8 == 1) begin
                //save to reg A.
                memWE <=1;
                MemAddr <= aAddr;
                DataIn <= G_reg;
                extracode_flag <= 0;
           end
        end
       end

       maskandmp: begin
            if (extracode_flag) begin
            //then multiply
            //two single precision => double precision
                if (tp6) begin
                    memWE <=0;
                    memAddr <= Addr12;
                    G_reg <= DataOut;
                end
                if (tp7) begin
                    memAddr <= aAddr;
                    memWE <=0;
                    //overflow correction
                    if (DataOut[14] == G_reg[14]) begin //checking the sign of both operands
                        S2 <= 0; //sign of result is positive (pos*pos = pos, neg*neg = pos)
                    end
                    else begin
                        S2 <= 1; //sign of result is negative (pos*neg = neg, and vice versa)
                    end
                    temp_computation <= G_reg * DataOut;
                end
                if (tp8) begin
                    memWE <=1;
                    MemAddr <= aAddr;
                    DataIn <= {S2, temp_computation[28:16]}; //save higher bits in A with overflow correction
                end
                if (tp9) begin
                    memWE <=1;
                    MemAddr <= lAddr;
                    DataIn <= temp_computation[15:0]; //save lower bits in L
                    extracode_flag <= 0;
                    overflow_flag <= 0;
                end
            end
            else begin
            //then mask
            if (tp6 == 1) begin
                //save mem[addr] given to reg G
                memWE <=0;
                MemAddr <= Addr12;
                G_reg <= DataOut;
            end
            if (tp7 = 1) begin
                //read what is in reg A
                memWE <= 0;
                MemAddr <= aAddr;
                G_reg <= (G_reg & DataOut); //reg G's contents AND reg A's contents
            end
            if (tp8 == 1) begin
                 //save to reg A.
                 memWE <=1;
                 MemAddr <= aAddr;
                 DataIn <= G_reg;
                 extracode_flag <= 0;
            end
            end
       end
    endcase
end
endmodule
