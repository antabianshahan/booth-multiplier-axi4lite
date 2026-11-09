`timescale 1 ns / 1 ps

// Self-checking testbench for booth_mult (16x16 signed radix-4 Booth multiplier).
//
// Handshake checked on every operation:
//   start (rising edge) -> busy=1 -> irq=1 after 8 iterations, result valid
//   ack                 -> irq=0, busy=0 (back to IDLE)
//
// Directed sign/corner cases first, then N_RANDOM random operand pairs
// compared against the reference a*b.
//
// Icarus:    iverilog -g2012 -o sim rtl/booth_mult.sv tb/tb_booth_mult.sv && vvp sim
// QuestaSim: vlog -sv rtl/booth_mult.sv tb/tb_booth_mult.sv; vsim -c tb_booth_mult -do "run -all"

module tb_booth_mult;

    localparam int N_RANDOM = 20000;

    logic               clk;
    logic               resetn;
    logic               start;
    logic               busy;
    logic               irq;
    logic               ack;
    logic signed [15:0] data_a;
    logic signed [15:0] data_b;
    logic signed [31:0] result;

    int n_pass = 0;
    int n_fail = 0;

    booth_mult dut (
        .clk    (clk),
        .resetn (resetn),
        .start  (start),
        .busy   (busy),
        .irq    (irq),
        .ack    (ack),
        .data_a (data_a),
        .data_b (data_b),
        .result (result)
    );

    // 100 MHz clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic multiply_and_check(input logic signed [15:0] a,
                                      input logic signed [15:0] b,
                                      input bit verbose);
        logic signed [31:0] expected;
        int cycles;
        bit ok;

        expected = a * b;
        ok = 1'b1;

        @(negedge clk);
        data_a = a;
        data_b = b;
        start  = 1'b1;
        @(negedge clk);
        start  = 1'b0;

        // wait for irq (8 iterations + margin)
        cycles = 0;
        while (!irq && cycles < 16) begin
            @(negedge clk);
            cycles++;
        end

        if (!irq) begin
            $display("TIMEOUT : %6d x %6d (expected %0d)", a, b, expected);
            ok = 1'b0;
        end else if (result !== expected) begin
            $display("FAIL    : %6d x %6d = %11d (expected %11d)", a, b, result, expected);
            ok = 1'b0;
        end else if (!busy) begin
            $display("FAIL    : %6d x %6d busy dropped before ack", a, b);
            ok = 1'b0;
        end

        // acknowledge -> back to IDLE
        ack = 1'b1;
        @(negedge clk);
        ack = 1'b0;
        @(negedge clk);
        if (irq || busy) begin
            $display("FAIL    : %6d x %6d irq/busy still high after ack", a, b);
            ok = 1'b0;
        end

        if (ok) begin
            n_pass++;
            if (verbose) $display("PASS    : %6d x %6d = %11d", a, b, result);
        end else begin
            n_fail++;
        end
    endtask

    initial begin
        resetn = 1'b0;
        start  = 1'b0;
        ack    = 1'b0;
        data_a = '0;
        data_b = '0;
        repeat (3) @(negedge clk);
        resetn = 1'b1;
        @(negedge clk);

        $display("--- Radix-4 Booth multiplier: directed tests ---");
        // the four sign combinations
        multiply_and_check( 16'sd125,     16'sd5,     1);
        multiply_and_check( 16'sd100,    -16'sd7,     1);
        multiply_and_check(-16'sd50,      16'sd3,     1);
        multiply_and_check(-16'sd100,    -16'sd200,   1);
        // corners (incl. -32768, where a naive 2A = A<<<1 overflows)
        multiply_and_check( 16'sd0,       16'sd12345, 1);
        multiply_and_check( 16'sd1,       16'sd1,     1);
        multiply_and_check(-16'sd1,      -16'sd1,     1);
        multiply_and_check( 16'sd32767,   16'sd32767, 1);
        multiply_and_check(-16'sd32768,   16'sd1,     1);
        multiply_and_check(-16'sd32768,  -16'sd32768, 1);
        multiply_and_check(-16'sd32768,   16'sd32767, 1);
        multiply_and_check( 16'sd32767,  -16'sd32768, 1);

        $display("--- %0d random operand pairs ---", N_RANDOM);
        for (int i = 0; i < N_RANDOM; i++)
            multiply_and_check($random, $random, 0);

        $display("--- %0d passed, %0d failed ---", n_pass, n_fail);
        if (n_fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
