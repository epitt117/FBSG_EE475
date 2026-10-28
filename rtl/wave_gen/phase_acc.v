module phase_acc #(
    parameter PHASE_WIDTH = 21  // default phase width to 21 as that gives ~0.1Hz resolution with a 150kHz clock
    )
    (
    input  wire                   clk      ,
    input  wire                   resetn   ,
    input  wire [PHASE_WIDTH-1:0] phase_inc,
    output reg  [PHASE_WIDTH-1:0] phase_acc
    );

    // output frequency = phase_inc * clk_freq / 2^PHASE_WIDTH

    // using dds
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            phase_acc <= {PHASE_WIDTH{1'b0}};
        end else begin
            phase_acc <= phase_acc + phase_inc;
        end
    end
endmodule