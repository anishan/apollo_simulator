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
	output reg tp9,
    output reg tp10,
    output reg tp11
    );
    reg [3:0] counter=0;

    always @(negedge clk) begin
        counter <= (counter +1 )%10 ;
        if (counter == 0)begin
			tp11 <= 0;
            tp1 <= 1;
        end
        if (counter == 2)begin
            tp1 <= 0;
            tp2 <= 1;
        end
        if (counter == 4)begin
            tp2 <= 0;
            tp3 <= 1;
        end
        if (counter == 6)begin
            tp3 <= 0;
            tp4 <= 1;
        end
        if (counter == 8)begin
            tp4 <= 0;
            tp5 <= 1;
        end
        if (counter == 10)begin
            tp5 <= 0;
            tp6 <= 1;
        end
        if (counter == 12)begin
            tp6 <= 0;
            tp7 <= 1;
        end
		if (counter == 14)begin
            tp7 <= 0;
            tp8 <= 1;
        end
		if (counter == 16)begin
			tp8 <= 0;
			tp9 <= 1;
        end
        if (counter == 18)begin
            tp9 <= 0;
            tp10 <= 1;
        end
        if (counter == 20)begin
            tp10 <= 0;
            tp11 <= 1;
        end
    end

endmodule
