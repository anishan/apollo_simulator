`include "sequencegenerator.v"
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
wire tp10;

initial clk= 0;
always #10 clk= !(clk);

sequence_generator seq(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8, tp9, tp10);

initial begin

// $dumpfile("seq.vcd");
// $dumpvars();
#500
$display("Check GTKWAVE for passing. Should see cascade of 1's from tp1 to tp10");
$finish;

end

endmodule
