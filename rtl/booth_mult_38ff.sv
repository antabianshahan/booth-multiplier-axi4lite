`timescale 1 ns / 1 ps

// 16x16 radix-4 Booth multiplier, exactly 38 registers.
//
// Register budget:
//   prod    33 FFs   33-bit accumulator (partial product added at bit 16,
//                    no factor-of-2 residue in the result)
//   state    4 FFs   FSM that doubles as iteration counter
//                      0       = IDLE
//                      1..8    = compute iterations 0..7
//                      9       = DONE, hold irq high until ack
//   start_d  1 FF    one-cycle delay of start for rising-edge detection
//   ----   ------
//   TOTAL   38 FFs
//
// busy and irq are combinational functions of state (zero extra FFs).
// data_b is scanned (Booth window cut directly from data_b's bits);
// data_a is added/subtracted as the multiplicand.

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

    // ---- registers (exactly 38 FFs) ----------------------------------
    logic [32:0] prod;
    logic [3:0]  state;
    logic        start_d;

    // ---- combinational: sign-extended multiplicand -------------------
    wire signed [16:0] M = {data_a[15], data_a};

    // ---- combinational: Booth 3-bit window from data_b ---------------
    // state=1: {data_b[1], data_b[0], 1'b0}   (virtual m_{-1} = 0)
    // state=k (2..8): data_b[2k-1 : 2k-3]
    logic [2:0] booth_bits;
    always_comb begin
        case (state)
            4'd1:    booth_bits = {data_b[1], data_b[0], 1'b0};
            4'd2:    booth_bits = data_b[3:1];
            4'd3:    booth_bits = data_b[5:3];
            4'd4:    booth_bits = data_b[7:5];
            4'd5:    booth_bits = data_b[9:7];
            4'd6:    booth_bits = data_b[11:9];
            4'd7:    booth_bits = data_b[13:11];
            4'd8:    booth_bits = data_b[15:13];
            default: booth_bits = 3'b000;
        endcase
    end

    // ---- combinational: Booth encoder --------------------------------
    // 2A is built with concatenation (NOT M <<< 1) so the -32768 corner
    // case doesn't drop the MSB.
    logic signed [17:0] booth_out;
    always_comb begin
        case (booth_bits)
            3'b000, 3'b111: booth_out = 18'sd0;
            3'b001, 3'b010: booth_out =  {M[16], M};    //  +A  (sign-ext 17 -> 18)
            3'b011:         booth_out =  {M, 1'b0};     //  +2A
            3'b100:         booth_out = -{M, 1'b0};     //  -2A
            3'b101, 3'b110: booth_out = -{M[16], M};    //  -A
            default:        booth_out = 18'sd0;
        endcase
    end

    // ---- combinational: 18-bit adder ---------------------------------
    // upper = sign_extend(prod[32:16], 18) + booth_out
    logic signed [17:0] upper;
    always_comb upper = $signed({prod[32], prod[32:16]}) + booth_out;

    // ---- sequential: FSM + datapath ----------------------------------
    always_ff @(posedge clk) begin
        if (!resetn) begin
            prod    <= '0;
            state   <= 4'd0;
            start_d <= 1'b0;
        end
        else begin
            start_d <= start;

            case (state)
                4'd0: begin
                    if (start && !start_d) begin       // rising edge of start
                        prod  <= '0;
                        state <= 4'd1;
                    end
                end

                4'd1, 4'd2, 4'd3, 4'd4,
                4'd5, 4'd6, 4'd7, 4'd8: begin
                    // add at bit 16, then arithmetic shift right by 2
                    // (encoded as one assignment: load upper at bits 31:14,
                    // duplicate sign bit at bit 32, keep prod[15:2] in low 14 bits)
                    prod  <= {upper[17], upper, prod[15:2]};
                    state <= (state == 4'd8) ? 4'd9 : (state + 4'd1);
                end

                4'd9: begin                            // DONE -- wait for ack
                    if (ack) state <= 4'd0;
                end

                default: state <= 4'd0;
            endcase
        end
    end

    // ---- combinational outputs (no extra FFs) ------------------------
    assign busy   = (state != 4'd0);
    assign irq    = (state == 4'd9);
    assign result = prod[31:0];

endmodule
