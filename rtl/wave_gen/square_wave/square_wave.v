`include "../../../rtl/wave_gen/phase_acc.v"

module square_wave #(
    parameter integer PHASE_WIDTH = 21,
    parameter integer DATA_WIDTH  = 16
    )
    (
    input  wire                   clk       ,
    input  wire                   resetn    ,
    input  wire            [31:0] dc        , // duty cycle
    input  wire [PHASE_WIDTH-1:0] phase_in  ,
    output wire                   valid_out ,
    output wire  [DATA_WIDTH-1:0] square_out
    );

    wire          [31:0] duty_percent  ;
    wire          [63:0] phase_modulus ;
    wire          [63:0] width_product ;
    wire [PHASE_WIDTH:0] duty_threshold;

    assign phase_modulus  = 64'd1 << PHASE_WIDTH;                                                // 2^PHASE_WIDTH
    assign duty_percent   = (dc > 32'd100) ? 32'd100 : dc;                                       // boundaries up to 100%
    assign width_product  = phase_modulus * duty_percent;                                        // larger product mid-way variable to avoid overflow
    assign duty_threshold = width_product / 64'd100;                                             // actual duty threshold in clock cycles

    assign square_out     = phase_in < duty_threshold ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
    assign valid_out      = 1'b1;
endmodule