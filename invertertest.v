module quicktest();
reg [14:0] instr;
reg [14:0] instr2;


reg dutpassed;

initial begin

assign instr = 15'b111001011000010;
assign instr2 = ~instr;

$display("instr2: %b", instr2);


end
endmodule

module quicktestvalues();
reg [14:0] instr;
reg [14:0] value;
reg dutpassed;
reg [14:0] greater;

initial begin

assign instr = 15'b111001011000010 ;
assign value = 15'b000000000000001;
assign greater = instr > value;
$display("greater: %b, instr: %b, value: %b", greater, instr, value);


end
endmodule
