module InstrFetchUnit
(
input [14:0] instr,
output reg [2:0] OpCode,
output reg [1:0] QC,
output reg PC,
output reg [11:0] Addr12,
output reg [9:0] Addr10
);

always @(instr) begin
	assign OpCode = instr[14:12];
	assign QC = instr[11:10];
	assign PC = instr[9];
	assign Addr12 = instr[11:0];
	assign Addr10 = instr[9:0];
end
endmodule

module quicktest();
reg [14:0] instr;
wire [2:0] OpCode;
wire [1:0] QC;
wire PC;
wire [11:0] Addr12;
wire [9:0] Addr10;

reg dutpassed;

InstrFetchUnit instrFetchie(instr, OpCode, QC, PC, Addr12, Addr10);

initial begin

instr = 15'b110101100010001;
//110 101 100 010 001
#10
if ((OpCode!=3'b110) || (QC!=2'b10) || (PC!=1'b1) || (Addr12!=12'b101100010001) || (Addr10!=10'b1100010001)) begin
	dutpassed = 0;
end
else begin
	dutpassed = 1;
end

$display("dut passed: %b", dutpassed);


end
endmodule
