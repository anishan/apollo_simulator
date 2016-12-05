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
