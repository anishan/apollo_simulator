module centralreg
(
	input wrenable,
    input       clk,
    input [15:0] d,
    output reg [15:0] q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule

module reg16
(
	input wrenable,
    input       clk,
    input [15:0] d,
    output reg [15:0] q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule

module reg12
(
	input wrenable,
    input       clk,
    input [11:0] d,
    output reg [11:0] q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule

module reg4
(
	input wrenable,
    input       clk,
    input [3:0] d,
    output reg [3:0] q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule

module reg3
(
	input wrenable,
    input       clk,
    input [2:0] d,
    output reg [2:0] q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule

module reg1
(
	input wrenable,
    input       clk,
    input d,
    output reg q
);
    always @(posedge clk) begin
		if (wrenable) begin
            q = d;
		end
    end
endmodule


module quicktest();
reg [15:0] d16;
wire [15:0] q16;
reg [11:0] d12;
wire [11:0] q12;
reg [3:0] d4;
wire [3:0] q4;
reg [2:0] d3;
wire [2:0] q3;
reg d1;
wire q1;

reg enable;

reg dutpassed;
reg clk;

reg16 reggie16(enable, clk, d16, q16);
reg12 reggie12(enable, clk, d12, q12);
reg4 reggie4(enable, clk, d4, q4);
reg3 reggie3(enable, clk, d3, q3);
reg1 reggie1(enable, clk, d1, q1);

//initial clk=0;
//always #10 clk=!clk;

initial begin

d16 = 16'b0000000000000001;
d12 = 12'b000000000001;
d4 = 4'b0001;
d3 = 3'b001;
d1 = 1'b1;

clk = 0;
enable = 1;
#10
clk = 1;
#10
clk = 0;
#10
enable = 0;


if ((d16!=q16) || (d12!=q12) || (d4!=q4) || (d3!=q3) || (d1!=q1)) begin
	dutpassed = 0;
end
else begin
	dutpassed = 1;
end

$display("dut passed: %b", dutpassed);


end
endmodule
