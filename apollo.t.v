`include "agc.v"
/*This will generate the waveform, where we can visually check that the CPU is acting as it should. */
module quicktestapollo();

reg clk;

// Generate clock (50MHz)
    initial clk=0;
	always #10 clk=!clk;

apolloGuidanceComputer ctrl_unit(clk);

initial begin
 $dumpfile("apollo.vcd");
 $dumpvars();


#50000 $finish;
//the registers are too nested to be able to reference them and check their contents with a dutpassed.
end

endmodule
