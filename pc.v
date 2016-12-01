module pc
(
	input enable,
    input clk,
	input jumpSelect, // set high if we want to jump
    input [11:0] jumpAddr,
    output [11:0] PCaddr
);
	reg [11:0] pc = 12'b000000000000;
	wire [11:0] muxOut;
	mux12to1_1bit muxie(pc, jumpAddr, jumpSelect, muxOut);
	dff12 dffie(enable, clk, muxOut, PCaddr);
endmodule


module dff12 // might be 12 bits
(
	input enable,
    input       clk,
    input [11:0] d,
    output reg [11:0] q
);
    always @(posedge clk) begin
		if (enable) begin
            q = d;
		end
    end
endmodule

module mux12to1_1bit // We think its 12 bits for an address, but no clue
(
	input [11:0] input1,
    input [11:0] input2,
    input select,
    output reg [11:0] q
);

initial begin
	if (select) begin
    	assign q = input1;
    end
	else begin
		assign q = input2;
	end
end
endmodule
