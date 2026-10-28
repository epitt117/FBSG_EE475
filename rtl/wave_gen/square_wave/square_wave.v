module square_wave #(
    parameter integer PHASE_WIDTH = 21
    )
    (
    input  wire                   clk       ,
    input  wire                   resetn    ,
    input  wire            [31:0] dc        , // duty cycle
    input  wire [PHASE_WIDTH-1:0] phase_inc ,
    output wire                   square_out
    );

    wire [PHASE_WIDTH-1:0] phase         ;
    wire            [31:0] duty_percent  ;
    wire            [63:0] phase_modulus ;
    wire            [63:0] width_product ;
    wire   [PHASE_WIDTH:0] duty_threshold;

    assign phase_modulus  = 64'd1 << PHASE_WIDTH;          // 2^PHASE_WIDTH
    assign duty_percent   = (dc > 32'd100) ? 32'd100 : dc; // boundaries up to 100%
    assign width_product  = phase_modulus * duty_percent;  // larger product mid-way variable to avoid overflow
    assign duty_threshold = width_product / 64'd100;       // actual duty threshold in clock cycles

    phase_acc #(
        .PHASE_WIDTH (PHASE_WIDTH)
        )
        phase_acc_inst(
            .clk       (clk      ),
            .resetn    (resetn   ),
            .phase_inc (phase_inc),
            .phase_acc (phase    )
            );

    assign square_out = phase < duty_threshold;
    endmodule