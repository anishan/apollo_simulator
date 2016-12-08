// Module to access and modify data memory
`timescale 1 ns / 1 ps

module Data_memory
(
  input regWE, clk, //timing pulse
  input[11:0] Addr,
  input[14:0] DataIn,
  output reg [14:0]  DataOut
);

  reg [14:0] mem[0:2046]; // Generate array to store data from file

  //timing pulse is when we want to write to memory if we're addressing the erasable and are enabled by control unit
  always @(posedge clk) begin // Update array on posedge timing pulse
    if ((regWE) && (Addr[11:10] == 2'b00)) begin // Check for write enable
        if (Addr != 12'b000000000111) begin //cannot be writing to zero reg
            mem[Addr] = DataIn;
            $writememb("fullMem.dat", mem); // Write to file
        end
    end
    else if (regWE) begin
        $display("You are trying to write to fixed memory. Error.");
    end
	
	DataOut = mem[Addr]; // Ouput data at address Addr
	
  end



  initial begin
      $readmemb("fullMem.dat", mem); // Initially read file
  end

      //assign DataOut = mem[Addr]; // Ouput data at address Addr
endmodule
