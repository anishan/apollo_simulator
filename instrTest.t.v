`include "memory_agc.v"

module memory_test();
    reg tp;
    reg enable;
    reg [11:0] addr;
    reg [14:0] dataIn;
    wire [14:0] dataOut;
    reg dutpassed = 1;

    Data_memory tester (enable, tp, addr, dataIn, dataOut);

    initial begin
        $dumpfile("refer.vcd");
        $dumpvars();
        dutpassed = 1;

        //testing writing while enable is low and then high.
        tp=0; enable=0; addr=12'b000000000100; dataIn=15'b000000000000110;
        #10 tp=1; #10 tp = 0;
        if (dataOut== 15'b000000000000110) begin
            dutpassed = 0;
            $display("You wrote while enable low");
        end
        tp=0; enable=1; addr=12'b000000000100; dataIn=15'b000000000000111;
        #10 tp=1; #10 tp = 0;
        if (dataOut != 15'b000000000000111) begin
            dutpassed = 0;
            $display("You didn't write while enable high");
        end

        // testing to see if we can write to fixed memory
        tp=0; enable=1; addr=12'b010000001000; dataIn=15'b000000000000010;
        #10 tp=1; #10 tp = 0;
        if (dataOut == 15'b000000000000010) begin
            dutpassed = 0;
            $display("You wrote to fixed memory");
        end

        $display("Memory DUTpassed? %b", dutpassed);
    end
endmodule
