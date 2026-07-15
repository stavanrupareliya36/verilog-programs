`timescale 1ns/1ps
`default_nettype none

module fifo_tb;
  localparam int DATA_WIDTH = 16;
  localparam int DEPTH = 10; // deliberately non-power-of-two
  localparam int COUNT_WIDTH = $clog2(DEPTH + 1);
  localparam int RANDOM_CYCLES = 5000;

  logic clk = 0;
  logic rst_n = 0;
  logic wr_en, rd_en;
  logic [DATA_WIDTH-1:0] wr_data, rd_data;
  logic full, empty, almost_full, almost_empty, overflow, underflow;
  logic [COUNT_WIDTH-1:0] occupancy;

  logic [DATA_WIDTH-1:0] model [0:DEPTH-1];
  int model_head, model_tail, model_count;
  int checks, errors, writes, reads, simultaneous_ops;
  int full_hits, empty_hits, overflow_hits, underflow_hits, wrap_hits;
  int unsigned seed = 32'h5EED_C0DE;

  sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (.*);
  always #5 clk = ~clk;

  task automatic drive(input bit do_write, input bit do_read,
                       input logic [DATA_WIDTH-1:0] data);
    bit expected_push, expected_pop;
    logic [DATA_WIDTH-1:0] expected_data;
    int count_before;
    begin
      @(negedge clk);
      wr_en = do_write;
      rd_en = do_read;
      wr_data = data;
      count_before = model_count;
      expected_pop  = do_read && (count_before != 0);
      expected_push = do_write && ((count_before != DEPTH) || expected_pop);
      if (expected_pop) expected_data = model[model_head];

      @(posedge clk); #1;
      checks += 5;
      if (expected_pop && rd_data !== expected_data) begin
        $error("scoreboard mismatch expected=%h actual=%h", expected_data, rd_data);
        errors++;
      end
      if (overflow !== (do_write && count_before == DEPTH && !expected_pop)) begin
        $error("overflow contract violation"); errors++;
      end
      if (underflow !== (do_read && count_before == 0)) begin
        $error("underflow contract violation"); errors++;
      end

      if (expected_pop) begin
        model_head = (model_head + 1) % DEPTH;
        model_count--; reads++;
      end
      if (expected_push) begin
        model[model_tail] = data;
        model_tail = (model_tail + 1) % DEPTH;
        model_count++; writes++;
        if (model_tail == 0) wrap_hits++;
      end
      if (expected_push && expected_pop) simultaneous_ops++;
      if (full) full_hits++;
      if (empty) empty_hits++;
      if (overflow) overflow_hits++;
      if (underflow) underflow_hits++;

      if (occupancy !== model_count) begin
        $error("occupancy mismatch expected=%0d actual=%0d", model_count, occupancy); errors++;
      end
      if (full !== (model_count == DEPTH)) begin
        $error("full flag mismatch"); errors++;
      end
      if (empty !== (model_count == 0)) begin
        $error("empty flag mismatch"); errors++;
      end
    end
  endtask

  initial begin
    $dumpfile("build/fifo.vcd");
    $dumpvars(0, fifo_tb);
    wr_en = 0; rd_en = 0; wr_data = '0;
    model_head = 0; model_tail = 0; model_count = 0;
    checks = 0; errors = 0; writes = 0; reads = 0; simultaneous_ops = 0;
    full_hits = 0; empty_hits = 0; overflow_hits = 0; underflow_hits = 0; wrap_hits = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    @(posedge clk); #1;
    if (!empty || occupancy != 0) begin $error("reset state invalid"); errors++; end

    // Directed boundary, ordering, illegal-access and simultaneous-operation tests.
    for (int i = 0; i < DEPTH; i++) drive(1, 0, 16'h1000 + i);
    drive(1, 0, 16'hDEAD);                 // overflow
    drive(1, 1, 16'hBEEF);                 // full: pop and accepted push
    while (model_count != 0) drive(0, 1, '0);
    drive(0, 1, '0);                       // underflow
    drive(1, 1, 16'hCAFE);                 // empty: push only, no fall-through
    drive(0, 1, '0);

    // Reproducible constrained-random stress with bursts and pointer wraparound.
    for (int cycle = 0; cycle < RANDOM_CYCLES; cycle++) begin
      drive($urandom(seed) % 100 < 62,
            $urandom(seed) % 100 < 58,
            $urandom(seed));
    end
    while (model_count != 0) drive(0, 1, '0);

    $display("\n--- VERIFICATION SUMMARY ---");
    $display("seed=0x%08h cycles=%0d checks=%0d", seed, RANDOM_CYCLES, checks);
    $display("writes=%0d reads=%0d simultaneous=%0d wraps=%0d", writes, reads, simultaneous_ops, wrap_hits);
    $display("full_hits=%0d empty_hits=%0d overflow_hits=%0d underflow_hits=%0d", full_hits, empty_hits, overflow_hits, underflow_hits);
    if (!full_hits || !empty_hits || !overflow_hits || !underflow_hits || !wrap_hits || !simultaneous_ops) begin
      $error("coverage goal not met"); errors++;
    end
    if (errors == 0) begin
      $display("RESULT: PASS");
      $finish;
    end
    $fatal(1, "RESULT: FAIL (%0d errors)", errors);
  end

  // Immediate invariants execute on every sampled clock and complement the scoreboard.
  always @(posedge clk) if (rst_n) begin
    assert (occupancy <= DEPTH) else $fatal(1, "occupancy out of range");
    assert (!(full && empty)) else $fatal(1, "full and empty both asserted");
  end
endmodule

`default_nettype wire
