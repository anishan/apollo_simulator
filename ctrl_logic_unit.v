//control unit
`timescale 1 ns / 1 ps

module ctrl_unit
(
input [2:0] Op,
input [1:0] QC,
input PC,
input [11:0] Addr12,
input [9:0] Addr10,
input extracode
);

// Encodings for Operations
localparam tc = 3'b000;
localparam ccsanddv = 3'b001;
localparam index = 3'b;
localparam xch = 3'b101;
localparam cs = 3'b100;
localparam ts = 3'b101;
localparam adandsu = 3'b110;
localparam maskandmp = 3'b111;

always @(posedge clk) begin
    case (Op)
	   tc: begin
           // transfer control
       end
       ccsanddv: begin
            //count, compare and skip or dv
            //check extracode
            if (extracode) begin
                //then DV
            end
            else begin
                //then CCS
            end
       end
       index: begin
            //extra should be high.
       end
       xch: begin
            //exchange
       end
       cs: begin
        //clear and subtract
       end
       ts: begin
            // transfer to storage
       end
       adandsu: begin
            if (extracode) begin
           //then subtract
            end
                else begin
           //then add
            end
       end
       maskandmp: begin
            if (extracode) begin
            //then multiply
            end
            else begin
            //then mask
            end
       end
    endcase
end


endmodule
