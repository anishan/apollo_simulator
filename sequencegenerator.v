//sequence generator
//5 pulses
`timescale 1 ns / 1 ps

module sequence_generator
(
    input clk,
    output reg tp1,
    output reg tp2,
    output reg tp3,
    output reg tp4,
    output reg tp5,
    output reg tp6,
    output reg tp7,
	output reg tp8,
	output reg tp9
    );
    reg [3:0] counter=0;

    always @(posedge clk) begin
        counter <= (counter +1 )%9 ;
        if (counter == 0)begin
			tp9 <= 0;
            tp1 <= 1;
        end
        if (counter == 1)begin
            tp1 <= 0;
            tp2 <= 1;
        end
        if (counter == 2)begin
            tp2 <= 0;
            tp3 <= 1;
        end
        if (counter == 3)begin
            tp3 <= 0;
            tp4 <= 1;
        end
        if (counter == 4)begin
            tp4 <= 0;
            tp5 <= 1;
        end
        if (counter == 5)begin
            tp5 <= 0;
            tp6 <= 1;
        end
        if (counter == 6)begin
            tp6 <= 0;
            tp7 <= 1;
        end
		if (counter == 7)begin
            tp7 <= 0;
            tp8 <= 1;
        end
		if (counter == 8)begin
			tp8 <= 0;
			tp9 <= 1;
        end
    end

endmodule


module quicksequencetest();

reg clk;
wire tp1;
wire tp2;
wire tp3;
wire tp4;
wire tp5;
wire tp6;
wire tp7;
wire tp8;
wire tp9;

initial clk= 0;
always #10 clk= !(clk);

sequence_generator seq(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8, tp9);

initial begin

$dumpfile("seq.vcd");
$dumpvars();
#500
$display("Check GTKWAVE for passing. Should see cascade of 1's from tp1 to tp9");
$finish;

end

endmodule
