module sample_timer #(
    parameter integer CLK_FREQ    = 50_000_000, // clock frequency in Hz
    parameter integer SAMPLE_FREQ = 150_000     // sample frequency in Hz
    )
    (
    input  wire clk        ,
    input  wire resetn     ,
    output reg  sample_tick
    );

    localparam MAX_COUNT = (CLK_FREQ / SAMPLE_FREQ) - 1; // max count value for the counter

    reg [$clog2(MAX_COUNT+1)-1:0] counter; // counter to track clock cycles

    // clock divider to generate sample tick at SAMPLE_FREQ
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counter     <= 0;
            sample_tick <= 1'b0;
        end else begin
            if (counter == MAX_COUNT) begin
                counter     <= 0;
                sample_tick <= 1'b1; // generate a sample tick, for one clock cycle
            end else begin
                counter     <= counter + 1;
                sample_tick <= 1'b0; // no sample tick, hold low for rest of interval
            end
        end
    end

endmodule;