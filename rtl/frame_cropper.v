module frame_cropper #(
  parameter SRC_WIDTH=1280,
  parameter SRC_HEIGHT=720,
  parameter DST_WIDTH=18,
  parameter DST_HEIGHT=15
) (
  input clk,
  input [23:0] sink_pData,
  input sink_pVDE,
  input sink_pVSync,

  output [23:0] rgb,
  output rgb_valid
);

reg frame_valid;
reg [$clog2(SRC_HEIGHT):0] row_i;
reg [$clog2(SRC_WIDTH):0] col_i;

wire is_last_row;
wire is_last_col;

initial frame_valid = 1'b0;
assign rgb = {sink_pData[23:16], sink_pData[7:0], sink_pData[15:8]};  // sink outputs RBG
assign rgb_valid = sink_pVDE & frame_valid & (row_i < DST_HEIGHT) & (col_i < DST_WIDTH);
assign is_last_row = row_i == (SRC_HEIGHT - 1);
assign is_last_col = col_i == (SRC_WIDTH - 1);

always @(posedge clk) begin
  if (~frame_valid) begin
    frame_valid <= sink_pVSync;
  end else begin
    frame_valid <= 1'b1;
    if (sink_pVDE) begin
      row_i <= is_last_col ? (is_last_row ? 0 : (row_i + 1)) : row_i;
      col_i <= is_last_col ? 0 : (col_i + 1);
    end else begin
      row_i <= row_i;
      col_i <= col_i;
    end
  end
end

endmodule
