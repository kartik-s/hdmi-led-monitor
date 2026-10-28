`timescale 1ns / 1ps

module synchronizer #(
  parameter WIDTH=1
) (
  input clk,
  input [WIDTH-1:0] async_sig,

  output [WIDTH-1:0] sync_sig
);

reg [WIDTH-1:0] left;
reg [WIDTH-1:0] right;

assign sync_sig = right;

always @(posedge clk) begin
  left <= async_sig;
  right <= left;
end

endmodule
