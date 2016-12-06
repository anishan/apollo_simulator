`timescale 1 ns / 1 ps
module InstrFetchUnit
(
input tp,
input [14:0] instr,
output reg [2:0] OpCode,
output reg [1:0] QC,
output reg Peripheral_C,
output reg [11:0] Addr12,
output reg [9:0] Addr10
);

always @(posedge tp) begin
	assign OpCode = instr[14:12];
	assign QC = instr[11:10];
	assign Peripheral_C = instr[9];
	assign Addr12 = instr[11:0];
	assign Addr10 = instr[9:0];
end
endmodule
