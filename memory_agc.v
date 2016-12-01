// Module to access and modify data memory

module Data_memory
(
  input regWE, tp, //timing pulse
  input[11:0] Addr,
  input[14:0] DataIn,
  output[14:0]  DataOut
);

  reg [14:0] mem[0:2046]; // Generate array to store data from file
  //timing pulse is when we want to write to memory if we're addressing the erasable and are enabled by control unit
  always @(posedge tp) begin // Update array on posedge clock
    if ((regWE) && (Addr[11:10] == 2'b00)) begin // Check for write enable
      mem[Addr] <= DataIn;
    end
    else if (regWE) begin
        $display("You are trying to write to fixed memory. Error.");
    end
  end

  initial begin
      $readmemb("fullMem.dat", mem); // Initially read file
  end

      assign DataOut = mem[Addr]; // Ouput data at address Addr
endmodule
