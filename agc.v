// Apollo guidance computer main module
`include "sequencegenerator.v"
`include "pc.v"
`include "memory_agc.v"

module AGC
(
  input clk,
);

wire tp1;
wire tp2;
wire tp3;
wire tp4;
wire tp5;
wire tp6;
wire tp7;

sequence_generator sequencegen(clk, tp1, tp2, tp3, tp4, tp5, tp6, tp7);

//reg [11:0] PCaddr;
//pc pcmodule(tc1, clk, PCaddr);

wire memWE; //set with ctrl
wire [11:0] Addr; //set with ctrl
wire [14:0] DataIn; //set with ctrl
wire [14:0]  DataOut;
wire memtp;
and andgate1(memtp, tp1, tp2); // and together all timing pulses where mem should run

Data_memory mem(memWE, memtp, Addr, DataIn, DataOut);

reg [2:0] OpCode;
reg [1:0] QC;
reg PC;
reg [11:0] Addr12;
reg [9:0] Addr10;
InstrFetchUnit instrFetch(tp3, DataOut, OpCode, QC, PC, Addr12, Addr10);

// make control unit module

endmodule
