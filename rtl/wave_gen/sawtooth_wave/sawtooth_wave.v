`include "../../../rtl/wave_gen/phase_acc.v"

module sawtooth_wave #(
    parameter integer PHASE_WIDTH = 21,
    parameter integer DATA_WIDTH  = 16
    )
    (
    input  wire                   clk         ,
    input  wire                   resetn      ,
    input  wire [PHASE_WIDTH-1:0] phase_in    ,
    output reg                    valid_out   ,
    output reg   [DATA_WIDTH-1:0] sawtooth_out
    );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sawtooth_out <= {DATA_WIDTH{1'b0}};
            valid_out    <= 1'b0;
        end else begin
            sawtooth_out <= phase_in[PHASE_WIDTH-1: PHASE_WIDTH-DATA_WIDTH]; // take the top bits of the phase accumulator as the output
            valid_out    <= 1'b1;
        end
    end
endmodule