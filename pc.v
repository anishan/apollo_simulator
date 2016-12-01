module pc
(
	input enable,
    input clk,
	input jumpSelect, // set high if we want to jump
    input [11:0] jumpAddr,
    output reg [11:0] PCaddr = 12'b000000000000
);

always @(posedge clk) begin
	if (enable) begin
		if (jumpSelect) begin
            PCaddr <= jumpAddr;
		end
		else begin
			PCaddr <= PCaddr+1;
		end
	end
end
endmodule

module quicktest();

reg enable;
reg clk;
reg jumpSelect; // set high if we want to jump
reg [11:0] jumpAddr;
wire [11:0] PCaddr;

reg dutpassed;

pc pcie(enable, clk, jumpSelect, jumpAddr, PCaddr);

// Generate clock (50MHz)
initial clk=0;
always #10 clk=!clk;

initial begin

$dumpfile("pc.vcd");
$dumpvars();

dutpassed = 1;
enable = 1;
jumpAddr = 12'b101010101010;
jumpSelect = 0;

#20

if (PCaddr != 12'b000000000001) begin
	$display("pc: %b", PCaddr);
	dutpassed = 0;
end

#20

if (PCaddr != 12'b000000000010) begin
	dutpassed = 0;
end

jumpSelect = 1;
#20
if (PCaddr != jumpAddr) begin
	dutpassed = 0;
end


$display("dut passed: %b", dutpassed);
$finish;

end
endmodule
