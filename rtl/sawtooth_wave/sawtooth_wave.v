module sawtooth_wave(
    input  wire        clk         ,
    input  wire        resetn      ,
    input  reg  [11:0] step        , // step size per clock cycle
    output reg  [11:0] sawtooth_out
    );

    reg [11:0] counter;
    wire [12:0] counter_plus_step = {1'b0, counter} + {1'b0, step};

    // reset when the counter reaches 13th bit (overflow), otherwise increment by step size
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counter      <= 12'd0;
            sawtooth_out <= 12'd0;
        end else begin
            if (counter_plus_step[12] == 1'b1) begin
                counter      <= 12'd0;
                sawtooth_out <= 12'd0;
            end else begin
                counter      <= counter_plus_step[11:0];
                sawtooth_out <= counter_plus_step[11:0];
            end
        end
    end
endmodule