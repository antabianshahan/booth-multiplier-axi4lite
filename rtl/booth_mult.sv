`timescale 1 ns / 1 ps

module booth_mult (
    input  logic               clk,
    input  logic               resetn,
    input  logic               start,
    output logic               busy,
    output logic               irq,
    input  logic               ack,
    input  logic signed [15:0] data_a,
    input  logic signed [15:0] data_b,
    output logic signed [31:0] result
);

    // 3 states needed so that irq can be HELD between completion and ack.
    typedef enum logic [1:0] {IDLE = 2'b00, RUN = 2'b01, DONE = 2'b10} state_t;
    state_t state;

    logic signed [33:0] prod;
    logic        [2:0]  count;
    logic               start_d;   // for rising-edge detection on start

    // Sign-extended multiplicand (combinational)
    wire signed [16:0] M = {data_a[15], data_a};

    // Booth encoder.
    // NOTE: 2A is built with concatenation, NOT `M <<< 1`, otherwise the
    // 17-bit shift drops the MSB when data_a = -32768 and 2A becomes 0.
    logic signed [17:0] booth_out;
    logic signed [17:0] upper;

    always_comb begin
        case (prod[2:0])
            3'b000, 3'b111: booth_out = 18'sd0;
            3'b001, 3'b010: booth_out =  {M[16], M};   //  +A  (sign-ext 17 -> 18)
            3'b011:         booth_out =  {M, 1'b0};    //  +2A
            3'b100:         booth_out = -{M, 1'b0};    //  -2A
            3'b101, 3'b110: booth_out = -{M[16], M};   //  -A
            default:        booth_out = 18'sd0;
        endcase

        // Signed sum of accumulator (top 17 bits) and partial product
        upper = $signed(prod[33:17]) + booth_out;
    end

    // Synchronous, active-low reset
    always_ff @(posedge clk) begin
        if (!resetn) begin
            prod    <= '0;
            count   <= '0;
            state   <= IDLE;
            irq     <= 1'b0;
            start_d <= 1'b0;
        end
        else begin
            start_d <= start;     // delay-line for edge detection

            case (state)

                // ---- IDLE: wait for rising edge on start ----
                IDLE: begin
                    if (start && !start_d) begin
                        prod  <= {17'b0, data_b, 1'b0};   // sign-bit not used; data_b drives encoder
                        count <= 3'd0;
                        state <= RUN;
                    end
                end

                // ---- RUN: 8 cycles of (add + arithmetic-shift-right-2) ----
                RUN: begin
                    // $signed(...) forces ARITHMETIC right shift; without it the
                    // unsigned concatenation would zero-fill and corrupt negatives.
                    prod  <= $signed({upper, prod[16:0]}) >>> 2;
                    count <= count + 3'd1;

                    if (count == 3'd7) begin
                        state <= DONE;
                        irq   <= 1'b1;        // assert irq...
                    end
                end

                // ---- DONE: hold irq HIGH until HPS acks ----
                DONE: begin
                    if (ack) begin
                        irq   <= 1'b0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // busy is high during both RUN and DONE (until the HPS acknowledges).
    assign busy   = (state != IDLE);
    assign result = prod[32:1];

endmodule

