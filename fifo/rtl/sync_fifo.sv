`default_nettype none

module sync_fifo #(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned DEPTH      = 16,
  parameter int unsigned ALMOST_FULL_LEVEL  = (DEPTH > 1) ? DEPTH - 1 : DEPTH,
  parameter int unsigned ALMOST_EMPTY_LEVEL = 1,
  localparam int unsigned PTR_WIDTH   = (DEPTH <= 1) ? 1 : $clog2(DEPTH),
  localparam int unsigned COUNT_WIDTH = $clog2(DEPTH + 1)
) (
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   wr_en,
  input  logic [DATA_WIDTH-1:0]  wr_data,
  output logic                   full,
  output logic                   almost_full,
  output logic                   overflow,
  input  logic                   rd_en,
  output logic [DATA_WIDTH-1:0]  rd_data,
  output logic                   empty,
  output logic                   almost_empty,
  output logic                   underflow,
  output logic [COUNT_WIDTH-1:0] occupancy
);

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
  logic push, pop;

  initial begin
    if (DEPTH < 2) $fatal(1, "DEPTH must be at least 2");
    if (ALMOST_FULL_LEVEL > DEPTH) $fatal(1, "ALMOST_FULL_LEVEL exceeds DEPTH");
    if (ALMOST_EMPTY_LEVEL > DEPTH) $fatal(1, "ALMOST_EMPTY_LEVEL exceeds DEPTH");
  end

  // A pop makes room for a simultaneous push when full; a push supplies no
  // fall-through data when empty. This contract is explicit and verified.
  always_comb begin
    pop  = rd_en && !empty;
    push = wr_en && (!full || pop);
  end

  assign full         = (occupancy == DEPTH);
  assign empty        = (occupancy == 0);
  assign almost_full  = (occupancy >= ALMOST_FULL_LEVEL);
  assign almost_empty = (occupancy <= ALMOST_EMPTY_LEVEL);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr    <= '0;
      rd_ptr    <= '0;
      occupancy <= '0;
      rd_data   <= '0;
      overflow  <= 1'b0;
      underflow <= 1'b0;
    end else begin
      overflow  <= wr_en && full && !pop;
      underflow <= rd_en && empty;

      if (push) begin
        mem[wr_ptr] <= wr_data;
        wr_ptr <= (wr_ptr == DEPTH-1) ? '0 : wr_ptr + 1'b1;
      end
      if (pop) begin
        rd_data <= mem[rd_ptr];
        rd_ptr <= (rd_ptr == DEPTH-1) ? '0 : rd_ptr + 1'b1;
      end

      unique case ({push, pop})
        2'b10: occupancy <= occupancy + 1'b1;
        2'b01: occupancy <= occupancy - 1'b1;
        default: occupancy <= occupancy;
      endcase
    end
  end

endmodule

`default_nettype wire
