module sawtooth_wave #(
    parameter integer PHASE_WIDTH = 21
    )
    (
    input  wire        clk         ,
    input  wire        resetn      ,
    input  reg  [11:0] step        , // step size per clock cycle
    output reg  [11:0] sawtooth_out
    );

    reg [PHASE_WIDTH-1:0] phase;
    phase_acc #(
        .PHASE_WIDTH (PHASE_WIDTH)
        )
        phase_acc_inst(
            .clk       (clk   ),
            .resetn    (resetn),
            .phase_inc (step  ),
            .phase_acc (phase )
            );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sawtooth_out <= 12'd0;
        end else begin
            sawtooth_out <= phase[PHASE_WIDTH-1 -: 12]; // take the top 12 bits of the phase accumulator as the output
        end
    end
endmodule