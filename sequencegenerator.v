//sequence generator
//5 pulses
module sequence_generator
(
    input clk,
    output reg tp1,
    output reg tp2,
    output reg tp3,
    output reg tp4,
    output reg tp5,
    output reg tp6,
    output reg tp7
    );
    reg [3:0] counter=0;

    always @(posedge clk) begin
        counter <= (counter +1 )%7 ;
        if (counter == 0)begin
            tp1 <= 1;
            tp2 <= 0;
            tp3 <= 0;
            tp4 <= 0;
            tp5 <= 0;
            tp6 <= 0;
            tp7 <= 0;
        end
        if (counter == 1)begin
            tp1 <= 0;
            tp2 <= 1;
            tp3 <= 0;
            tp4 <= 0;
            tp5 <= 0;
            tp6 <= 0;
            tp7 <= 0;
        end
        if (counter == 2)begin
            tp1 <= 0;
            tp2 <= 0;
            tp3 <= 1;
            tp4 <= 0;
            tp5 <= 0;
            tp6 <= 0;
            tp7 <= 0;
        end
        if (counter == 3)begin
            tp1 <= 0;
            tp2 <= 0;
            tp3 <= 0;
            tp4 <= 1;
            tp5 <= 0;
            tp6 <= 0;
            tp7 <= 0;
        end
        if (counter == 4)begin
            tp1 <= 0;
            tp2 <= 0;
            tp3 <= 0;
            tp4 <= 0;
            tp5 <= 1;
            tp6 <= 0;
            tp7 <= 0;
        end
        if (counter == 5)begin
            tp1 <= 0;
            tp2 <= 0;
            tp3 <= 0;
            tp4 <= 0;
            tp5 <= 0;
            tp6 <= 1;
            tp7 <= 0;
        end
        if (counter == 6)begin
            tp1 <= 0;
            tp2 <= 0;
            tp3 <= 0;
            tp4 <= 0;
            tp5 <= 0;
            tp6 <= 0;
            tp7 <= 1;
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

initial clk= 0;
always #10 clk= !(clk);

sequence_generator seq(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7);

initial begin

$dumpfile("seq.vcd");
$dumpvars();
#500
$display("Check GTKWAVE for passing. Should see cascade of 1's from tp1 to tp7"); 
$finish;

end

endmodule
