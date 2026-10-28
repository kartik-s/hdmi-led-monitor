module rgb2spi #(
  parameter NUM_PIXELS=269,
  parameter WORD_WIDTH=32,
  parameter DISPLAY_WIDTH=18,
  parameter DISPLAY_HEIGHT=15
) (
  input pixel_clk,
  input [23:0] rgb,
  input rgb_valid,
  input vsync,

  input spi_clk_in,
  output reg spi_dout,
  output spi_clk
);

localparam HEADER_WORD = {32{1'b0}};
localparam TRAILER_WORD = {32{1'b1}};

reg [WORD_WIDTH-1:0] framebuffers [1:0][NUM_PIXELS+1:0];  // two extra words for header and trailer

initial framebuffers[0][0] = HEADER_WORD;
initial framebuffers[1][0] = HEADER_WORD;
initial framebuffers[0][NUM_PIXELS+1] = TRAILER_WORD;
initial framebuffers[1][NUM_PIXELS+1] = TRAILER_WORD;

// writer
reg write_framebuffer_i;
reg [$clog2(NUM_PIXELS+2):0] write_word_i;
reg [$clog2(NUM_PIXELS+2):0] pixel_i;
reg [$clog2(DISPLAY_HEIGHT):0] row_i;
reg [$clog2(DISPLAY_WIDTH):0] col_i;
reg is_reversed_row;
reg vsync_prev;

initial write_framebuffer_i = 0;
initial write_word_i = DISPLAY_WIDTH;
initial pixel_i = 0;
initial row_i = 0;
initial col_i = 0;
initial is_reversed_row = 1;
initial vsync_prev = 0;

wire is_last_col;

assign is_last_col = col_i == (DISPLAY_WIDTH - 1);

always @(posedge pixel_clk) begin
  vsync_prev <= vsync;
  if (rgb_valid & (pixel_i < NUM_PIXELS)) begin
    framebuffers[write_framebuffer_i][write_word_i] <= {{8{1'b1}}, rgb[7:0] >> 1, rgb[15:8] >> 1, rgb[23:16] >> 1};
    write_framebuffer_i <= write_framebuffer_i;
    write_word_i <= is_last_col ? (((write_word_i + DISPLAY_WIDTH) < NUM_PIXELS) ? (write_word_i + DISPLAY_WIDTH) : (write_word_i + DISPLAY_WIDTH) - 1) : (is_reversed_row ? (write_word_i - 1) : (write_word_i + 1));
    pixel_i <= pixel_i + 1;
    row_i <= is_last_col ? (row_i + 1) : row_i;
    col_i <= is_last_col ? 0 : (col_i + 1);
    is_reversed_row <= is_last_col ? ~is_reversed_row : is_reversed_row;
  end else if (vsync & ~vsync_prev) begin
    write_framebuffer_i <= ~write_framebuffer_i;
    write_word_i <= DISPLAY_WIDTH;
    pixel_i <= 0;
    row_i <= 0;
    col_i <= 0;
    is_reversed_row <= 1;
  end else begin
    write_framebuffer_i <= write_framebuffer_i;
    write_word_i <= write_word_i;
    pixel_i <= pixel_i;
    row_i <= row_i;
    col_i <= col_i;
    is_reversed_row <= is_reversed_row;
  end
end

// reader
reg idle;
reg vsync_reader_prev;
reg read_framebuffer_i;
reg [$clog2(NUM_PIXELS+2)-1:0] read_word_i;
reg [$clog2(WORD_WIDTH)-1:0] bit_i;

wire vsync_reader;
wire swap_framebuffers;
wire is_last_bit;
wire is_last_word;

synchronizer sync (.clk(spi_clk), .async_sig(vsync), .sync_sig(vsync_reader));

initial idle = 1;
initial vsync_reader_prev = 0;
initial read_framebuffer_i = 1;
initial read_word_i = 0;
initial bit_i = WORD_WIDTH - 1;

assign spi_clk = spi_clk_in;
assign swap_framebuffers = vsync_reader & ~vsync_reader_prev;
assign is_last_bit = bit_i == 0;
assign is_last_word = read_word_i == (NUM_PIXELS + 1);

always @(posedge spi_clk) begin
    vsync_reader_prev <= vsync_reader;
    if (idle) begin
        idle <= swap_framebuffers ? 1'b0 : 1'b1;
        read_framebuffer_i <= swap_framebuffers ? ~read_framebuffer_i : read_framebuffer_i;
        read_word_i <= 0;
        bit_i <= WORD_WIDTH - 1;
        spi_dout <= 1'b0;
    end else begin
        idle <= is_last_word;
        read_framebuffer_i <= read_framebuffer_i;
        read_word_i <= is_last_bit ? (read_word_i + 1) : read_word_i;
        bit_i <= is_last_bit ? (WORD_WIDTH - 1) : (bit_i - 1);
        spi_dout <= framebuffers[read_framebuffer_i][read_word_i][bit_i];
    end
end

endmodule
