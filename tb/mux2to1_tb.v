`timescale 1ns/1ps

module mux2to1_tb;

reg a;
reg b;
reg sel;
wire y;

mux2to1 dut (
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);

initial begin
    $display("Time\t sel a b | y");
    $monitor("%0t\t %b   %b %b | %b", $time, sel, a, b, y);

    a = 0; b = 0; sel = 0; #10;
    a = 1; b = 0; sel = 0; #10;
    a = 0; b = 1; sel = 1; #10;
    a = 1; b = 0; sel = 1; #10;

    $display("2-to-1 mux simulation completed.");
    $finish;
end

endmodule
