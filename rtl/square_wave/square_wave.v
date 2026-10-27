`include "../pulse_wave/pulse_wave.v" // get the pulse_wave module to use as submodule

module square_wave(
    input  wire        clk       ,
    input  wire        resetn    ,
    input  wire [31:0] dc        , // duty cycle
    input  wire [31:0] period    , // num clock cycles per square-wave period (for the pulse)
    output wire        square_out
    );

    reg  [31:0] phase_counter; // position within each period of square wave (0 -> period-1)
    reg         pulse_en     ;
    wire [31:0] duty_percent ;
    wire [63:0] width_product;
    wire [31:0] pulse_width  ;

    assign duty_percent  = (dc > 32'd100) ? 32'd100 : dc;           // boundaries up to 100%
    assign width_product = {32'd0, period} * {32'd0, duty_percent}; // larger product mid-way variable to avoid overflow
    assign pulse_width   = width_product / 64'd100;                 // actual pulse width in clock cycles

    pulse_wave pulse_wave_u(
        .clk         (clk        ),
        .rstn        (resetn     ),
        .pulse_width (pulse_width),
        .pulse_en    (pulse_en   ),
        .pulse_out   (square_out )
        );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            phase_counter <= 32'd0;
            pulse_en      <= 1'b0;
        end else if (period == 32'd0) begin
            phase_counter <= 32'd0;
            pulse_en      <= 1'b0;
        end else begin
            // pulse_en is a one-clock trigger at the start of each period.
            pulse_en <= (phase_counter == 32'd0);

            if (phase_counter == period - 32'd1) begin
                phase_counter <= 32'd0;
            end else begin
                phase_counter <= phase_counter + 32'd1;
            end
        end
    end
endmodule