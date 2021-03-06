//control unit
`timescale 1 ns / 1 ps
`include "sequencegenerator.v"
`include "memory_agc.v"
`include "instrFetch.v"

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
wire tp10;
wire tp11;
reg memWE; //set with ctrl
reg [11:0] MemAddr; //set with ctrl
reg [14:0] DataIn; //set with ctrl
wire [14:0]  DataOut;
wire memtp;
reg [29:0] temp_computation;
reg [29:0] temp2_computation;
reg [29:0] temp3_computation;
reg [14:0] A_A_rod;

reg extracode_flag;
reg [14:0] PC; //program counter
wire [2:0] OpCode;
wire [1:0] QC;
wire Peripheral_C; //PERIPHERAL CODE
wire [11:0] Addr12;
wire [9:0] Addr10;
reg [14:0] instr;
reg overflow_flag;
reg [14:0] G_reg;
reg S2 = 0; //the copy of the most sig bit for overflow checks
reg [14:0] hiddenreg; //for index
reg index_flag; //to know the next instruction needs + the hidden reg
reg clk_flag =0; // Temp, I hope hope hope

// Encodings for Operations
localparam tc = 3'b000;
localparam ccsanddv = 3'b001;
localparam  ddoubleandtcf = 3'b010;
localparam  double = 3'b011;
localparam cs = 3'b100;
localparam indexandxchandts = 3'b101;
//localparam xch = 3'b101;
//localparam ts = 3'b101;
localparam adandsu = 3'b110;
localparam maskandmp = 3'b111;

localparam  aAddr = 12'b000000000000;
localparam  qAddr = 12'b000000000001;
localparam  zAddr = 12'b000000000010;
localparam  lAddr = 12'b000000000011;

//create timing pulses
sequence_generator sequencegen(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8, tp9, tp10, tp11);
//have tp1 and tp2 together for when memory should run
and andgate1(memtp, tp1, tp2, tp5, tp6,tp7, tp8, tp9); // and together all timing pulses where mem should run
//memory
Data_memory memory(memWE, clk, MemAddr, DataIn, DataOut);
//decode the instruction just read from memory
InstrFetchUnit instrFetch(clk, tp5, instr, OpCode, QC, Peripheral_C, Addr12, Addr10);

always @(posedge clk) begin
	if ((OpCode == 3'b111) && (Addr12 == 12'b111111111111)) begin
		$display("Finished before the end of time");
		$finish;
	end
    if (tp1 == 1)begin //read what PC is from Z reg
		if (!clk_flag) begin
		    memWE <=0;
		    MemAddr <= zAddr;
			clk_flag <= 1;
		end
		else begin
        	PC <= DataOut;
			clk_flag <= 0;
		end
    end
    if (tp2 == 1) begin//write PC + 1 into Z's reg
		PC <= DataOut;
        //PC <= PC+1;
        memWE <= 0;
        MemAddr <= zAddr;
        //DataIn = PC;
    end
    if (tp3 == 1) begin  //set address to the PC
		if (!clk_flag) begin
			memWE <= 1;
			PC <= PC+1;
			DataIn <= PC + 1;
		    MemAddr <= zAddr;
		    instr <= DataOut;
			clk_flag <= 1;
		end
		else begin
			memWE <= 0;
			clk_flag <= 0;
		end
    end

    if (tp4 == 1) begin
		MemAddr <= PC-1;
		instr <= DataOut;
        memWE <= 0;
        //tp 4 is directly wired to instruction fetch unit (decoding)
    end

    if (tp5 == 1) begin
        if (index_flag) begin
            instr <= instr + hiddenreg;
            index_flag <=0;
        end
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    case (OpCode)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--TC--//
	   tc: begin
           // transfer control
           //have it write the jump address to Z on second tp while Q is set to Z
           if ((Addr12 != 6) && (tp6 == 1)) begin
                //save Z to Q
                memWE <=1;
                MemAddr <= qAddr;
                DataIn <= PC;
           end
           if ((Addr12 != 6) && (tp7 == 1)) begin
                //write the jump address to reg Z
                memWE <=1;
                MemAddr <= zAddr;
                DataIn <= Addr12;
           end
		   if (Addr12 == 6) begin // address 6 is a special case
	            extracode_flag <= 1;
		   end
       end

       ccsanddv: begin
            //count, compare and skip or dv
            //check extracode_flag
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--DV--//
            if (extracode_flag) begin
                //then DV
                if (tp6) begin
                // load G with the thing to divide by
                    memWE <= 0;
                    MemAddr <= Addr12;
                    G_reg <= DataOut;
                end
                if (tp7) begin // load A into temp computation
                    memWE <= 0;
                    MemAddr <= aAddr;
                    A_A_rod <= DataOut;
                    temp_computation <= {DataOut, 15'b000000000000000};
                end
                if (tp8) begin // load L into temp computation
                    memWE <= 0;
                    MemAddr <= lAddr;
                    temp_computation[14:0] <= DataOut;
                end
                if (tp9) begin
                    // temp2_computation <= temp_computation/G_reg;
                    //separating quotient from remainder
                    //have to overflow correct, quotient goes in A and remainder goes in L
					temp3_computation = temp_computation/G_reg; // quotient
					temp2_computation[29:15] = temp3_computation[29:15];
					temp3_computation = temp_computation%G_reg; // remainder
					temp2_computation[14:0] = temp3_computation[14:0];
					memWE <= 1;
					MemAddr <= aAddr;
					DataIn <= temp2_computation[29:15];
                    A_A_rod <= DataIn;
					S2 <= temp2_computation[29];
                end
				if (tp10) begin
                    // temp2_computation <= temp_computation/G_reg;
                    //separating quotient from remainder
                    //have to overflow correct, quotient goes in A and remainder goes in L
					memWE <= 1;
					MemAddr <= lAddr;
					DataIn <= temp2_computation[14:0];
					//at the end, clear extracode_flag
		            extracode_flag <= 0;
		            overflow_flag <=0;
                end
            end
            else begin
                //then CCS
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-CCS--//
                extracode_flag <= 0;
                if (tp6 ) begin // read from mem
                    memWE <= 0;
                    MemAddr <= {2'b00, Addr10};
					G_reg <= DataOut;
                end
                if (tp7) begin // find DABS, store in temp_computation[14:0]
					if (G_reg[14] == 0) begin // positive
						if (G_reg == 15'b000000000000000) begin // zero
							temp_computation[14:0] = 15'b000000000000000;
						end
						else begin // not zero
							temp_computation[14:0] = G_reg - 1;
						end
					end
					else begin // negative
						if (G_reg == 15'b111111111111111) begin // minus zero
							temp_computation[14:0] = 15'b000000000000000;
						end
						else begin // not zero
							temp_computation[14:0] = (~G_reg) - 1;
						end
					end
					memWE <= 1;
					MemAddr <= aAddr;
					DataIn <= temp_computation[14:0];
                    A_A_rod <= DataIn;
					S2 <= G_reg[14];
                end
                if (tp8) begin
					// jump PC depending on original value
					// if greater than zero or positive overflow, add 0, so do nothing
					if (!clk_flag) begin
					if (G_reg == 15'b000000000000000) begin // if equals +0
						PC <= PC + 1;
					end
					if ((G_reg[14] == 1 &&  G_reg[14:0] != 15'b111111111111111) || (S2 == 0 && G_reg[14] == 1)) begin // less than zero or negative overflow
						PC <= PC + 2;
					end
					if (G_reg == 15'b111111111111111) begin // if equals -0
						PC <= PC + 3;
					end
					clk_flag <= 1;
					end
					else begin
					clk_flag <= 0;
					end
                end
				if (tp9) begin
					// write PC to Z reg
					memWE <= 1;
					MemAddr <= zAddr;
					DataIn <= PC;
                end
                //need to set overflow
            end
       end

       indexandxchandts: begin
		  // index
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-INDEX-//
		  if (QC == 2'b00) begin
            //extra should be high.
            //add the data retrieved at address specified to the next instruction -- see tp == 4 (not case)
            if (tp6 == 1) begin
                //save index's address to a hidden reg.
                MemAddr <= Addr12;
                hiddenreg<= DataOut;
                index_flag <=1;
            end
       	  end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--EXH-//
       	  if (QC == 2'b11) begin
            //exchange
            if (tp6 == 1) begin
                memWE <=0;
                MemAddr <= {2'b00, Addr10};  //always EXCHANGE with erasable memory
                G_reg <= DataOut;
            end
            if (tp7 == 1)begin
                memWE <=0;
                MemAddr <= aAddr;
                A_A_rod<= DataOut;
				temp_computation[13:0] <= DataOut[13:0];
				temp_computation[14] <= S2;
            end
			if (tp8 == 1)begin
                memWE <=1;
                MemAddr <= aAddr;
                DataIn <= G_reg;
				S2 <= G_reg[14];
                A_A_rod <= DataIn;
            end
			if (tp9 == 1)begin
                memWE <=1;
                MemAddr <= {2'b00, Addr10};
                DataIn <= temp_computation[14:0];
				extracode_flag <= 0;
            end
       	  end
		  if (QC == 2'b10) begin
            // transfer to storage TS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--TS--//
			if (tp6) begin
				memWE <= 0;
				MemAddr <= aAddr;
                A_A_rod <= DataOut;
				G_reg[13:0] <= DataOut[13:0];
				G_reg[14] <= S2;
			end
			if (tp7) begin
				// if (!clk_flag) begin
				//
				// end
				// else if ()begin
				// 	memWE <= 1;
				// end
				memWE <= 1;
				MemAddr <= {2'b00, Addr10};
				DataIn <= G_reg;
			end
            //look at overflow, save into reg A if there is some, then clear overflow
			if (tp8) begin
				if (overflow_flag) begin
					memWE <= 1;
					MemAddr <= aAddr;
					if (S2 == 0) begin //positive
						DataIn <= 15'b000000000000001;
                        A_A_rod <= DataIn;
					end
					if (S2 == 1) begin //positive
						DataIn <= 15'b111111111111110;
                        A_A_rod <= DataIn;
					end
				end
			end
			if (tp9) begin
				if (overflow_flag) begin
					memWE <= 1;
					MemAddr <= zAddr;
					DataIn <= PC + 1;
				end
			end
		  end
       end
       cs: begin
        //clear and subtract
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--CS--//
        //load reg A with @ a mem
            if (tp6 == 1) begin
                memWE <=0;
				if (MemAddr != aAddr) begin
                	S2 <= 0;
				end
                extracode_flag <= 0;
                MemAddr <= Addr12;
                G_reg <= ~DataOut;
            end
            if (tp7) begin
            //save NOT version of data @mem into register A.
                MemAddr <= aAddr;
                memWE <= 1;
                DataIn <= G_reg;
				S2 <= G_reg[14];
                A_A_rod <= DataIn;
            end

       end

       adandsu: begin
            if (extracode_flag) begin
           //then subtract
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--SU--//
			if (tp6 == 1) begin
                //save mem[addr] given to reg G
                memWE <=0;
                MemAddr <= Addr12;
                G_reg <= DataOut;
            end

            if (tp7 == 1) begin
                //read what is in reg A
				//G_reg = DataOut;
                memWE <= 0;
                MemAddr <= aAddr;
                A_A_rod <= DataOut;
                S2 <= DataOut[14]; //keep a duplicate of most sig for overflow

            end

           if (tp8 == 1) begin
				if (!clk_flag) begin
					G_reg <= DataOut - G_reg; //reg G's contents + reg A's contents
					if (S2 != G_reg[14]) begin // there has been overflow
					  overflow_flag <= 1;
				   end
				   else begin
					  overflow_flag <= 0;
				   end
					clk_flag <=1;
				end
                //save to reg A.
				else begin
		            memWE <=1;
		            MemAddr <= aAddr;
					clk_flag <=0;
				end
           end

			if (tp9) begin
				DataIn <= G_reg;
                A_A_rod <= G_reg;
                extracode_flag <= 0;
			end
			if (tp10) begin
				memWE <= 0;
			end
        end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--AD--//
			else begin
            if (tp6 == 1) begin
                //save mem[addr] given to reg G
                memWE <=0;
                MemAddr <= Addr12;
                G_reg <= DataOut;
            end

            if (tp7 == 1) begin
                //read what is in reg A
				//G_reg = DataOut;
                memWE <= 0;
                MemAddr <= aAddr;
				if (DataOut[14] == 0) begin // normal case
                	A_A_rod <= DataOut;
				end
				else begin // A has a negative number
					A_A_rod <= ~DataOut; // because ones complement negative number
				end
                S2 <= A_A_rod[14]; //keep a duplicate of most sig for overflow
				
            end

           if (tp8 == 1) begin
				if (!clk_flag) begin
					if (G_reg[14] == A_A_rod[14]) begin
					G_reg <= G_reg + A_A_rod; //reg G's contents + reg A's contents
					end
					else begin
					G_reg <= G_reg + A_A_rod; //ones complement vs. two's complement
					end

					if (S2 != G_reg[14]) begin // there has been overflow
					  overflow_flag <= 1;
				   end
				   else begin
					  overflow_flag <= 0;
				   end
					clk_flag <=1;
				end
                //save to reg A.
				else begin
		            memWE <=1;
		            MemAddr <= aAddr;
					clk_flag <=0;
				end
           end

			if (tp9) begin
				DataIn <= G_reg;
                A_A_rod <= G_reg;
                extracode_flag <= 0;
			end
			if (tp10) begin
				memWE <= 0;
			end
        end
       end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--DB--//
	   double: begin
	   //double what's in A and save to A.
	   		if (tp6) begin //read A
				MemAddr <= aAddr;
				memWE <= 0;
				G_reg <= DataOut;
				A_A_rod <= G_reg;
			end
	   		if (tp7) begin
				if (!clk_flag) begin
					G_reg <= G_reg * 2;
					A_A_rod <= G_reg;
					clk_flag <= 1;
				end
				else begin
					clk_flag <= 0;
				end
			end
			if (tp8) begin //save to A
				memWE <= 1;
				MemAddr <= aAddr;
				DataIn <= G_reg;
				A_A_rod <= G_reg;
			end
	   end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-DDB--//
	   ddoubleandtcf: begin
	   	if (Addr10 <= 10'b0000000001) begin
	   		if (tp6) begin //read A
				MemAddr <= aAddr;
				memWE <= 0;
				temp_computation[29:15] <= DataOut;
				A_A_rod <= DataOut;
			end
			if (tp7) begin //read L
				MemAddr <= lAddr;
				memWE <= 0;
				temp_computation[14:0] <= DataOut;
			end
			if (tp8) begin //double (AL)
				if (!clk_flag) begin
					temp_computation <= 2* temp_computation;
					A_A_rod <= temp_computation[29:15];
					clk_flag <=1;
				end
				else begin
					clk_flag <=0;
				end
			end
			if (tp9) begin //save to A
				MemAddr <= aAddr;
				DataIn <= temp_computation[29:15];
				A_A_rod <= DataIn;
				memWE <= 1;
			end
			if (tp10) begin //save to L
				MemAddr <= lAddr;
				DataIn <= temp_computation[14:0];
				memWE <= 1;
			end
		end

		else begin
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-TCF--//
			// then tcf
			if (Addr12[11:10] != 2'b00) begin //can't jump into erasable
				if (tp6) begin
				// see what in the address. do not save Z to Q like in TC!
				//write the jump address to reg Z
				memWE <=1;
				MemAddr <= zAddr;
				DataIn <= Addr12;
				end
			end
	   end
   end
       maskandmp: begin
            if (extracode_flag) begin
            //then multiply
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--MU--//
            //two single precision => double precision
                if (tp6) begin
                    memWE <=0;
                    MemAddr <= Addr12;
					if (DataOut[14] == 1) begin
						temp2_computation <= {15'b111111111111111, 1'b0, DataOut[13:0]}; // get rid of sign bit here
					end
					else begin
						temp2_computation <= {15'b000000000000000, DataOut};
					end

                end
                if (tp7) begin // this needs both clock cycles
	                MemAddr <= aAddr;
	                memWE <=0;
					if (DataOut[14] == 1) begin
						temp3_computation = {15'b111111111111111, 1'b1, DataOut[13:0]}; // get rid of sign bit here
					end
					else begin
						temp3_computation = {15'b000000000000000, DataOut};
					end
	                A_A_rod<= DataOut;
	                //overflow correction
	                if (DataOut[14] == temp2_computation[29]) begin //checking the sign of both operands
	                    S2 <= 0; //sign of result is positive (pos*pos = pos, neg*neg = pos)
	                end
	                else begin
	                    S2 <= 1; //sign of result is negative (pos*neg = neg, and vice versa)
	                end
					if (temp2_computation[29] != temp3_computation[29]) begin
	                	temp_computation <= (temp2_computation * temp3_computation) + 1;
					end
					else begin
						temp_computation <= (temp2_computation * temp3_computation);
					end

                end
                if (tp8) begin
					if (clk_flag == 0) begin
						temp_computation <= {S2, temp_computation[27:0], 1'b0}; // add in signbit and bit shift
						clk_flag = 1;
					end
					else begin
		                memWE <=1;
		                MemAddr <= aAddr;
		                DataIn <= temp_computation[29:15]; //save higher bits in A with overflow correction
						DataIn[14] <= temp_computation[29];   //it was not taking the 29th bit without some force.
		                A_A_rod <= DataIn;
						clk_flag = 0;
					end

                end
                if (tp9) begin
                    memWE <=1;
                    MemAddr <= lAddr;
                    DataIn <= temp_computation[14:0]; //save lower bits in L
                    extracode_flag <= 0;
					if (S2 != temp2_computation[29]) begin // there has been overflow
					  overflow_flag <= 1;
				   end
				   else begin
					  overflow_flag <= 0;
				   end
                end
            end
            else begin
            //then mask
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-MASK-//
            if (tp6 == 1) begin
                //save mem[addr] given to reg G
                memWE <=0;
                MemAddr <= Addr12;
                G_reg <= DataOut;
            end
            if (tp7 == 1) begin
                //read what is in reg A
                memWE <= 0;
                MemAddr <= aAddr;
                A_A_rod <= DataOut;
                G_reg <= (G_reg & DataOut); //reg G's contents AND reg A's contents
				if (S2 != G_reg[14]) begin // there has been overflow
				  overflow_flag <= 1;
			   end
			   else begin
				  overflow_flag <= 0;
			   end
            end
            if (tp8 == 1) begin
                 //save to reg A.
                 memWE <=1;
                 MemAddr <= aAddr;
                 DataIn <= G_reg;
                 A_A_rod <= DataIn;
                 extracode_flag <= 0;
            end
            end
       end
    endcase
end
endmodule
