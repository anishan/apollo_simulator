`include "instrFetch.v"

module quicktest();
reg [14:0] instr;
wire [2:0] OpCode;
wire [1:0] QC;
wire Peripheral_C;
wire [11:0] Addr12;
wire [9:0] Addr10;
reg tp4;

reg dutpassed;

InstrFetchUnit instrFetchie(tp4, instr, OpCode, QC, Peripheral_C, Addr12, Addr10);

initial begin
tp4 = 1;
instr = 15'b110101100010001;
//110 101 100 010 001
#10
if ((OpCode!=3'b110) || (QC!=2'b10) || (Peripheral_C!=1'b1) || (Addr12!=12'b101100010001) || (Addr10!=10'b1100010001)) begin
	dutpassed = 0;
end
else begin
	dutpassed = 1;
end

$display("IFETCH dut passed: %b", dutpassed);


end
endmodule
