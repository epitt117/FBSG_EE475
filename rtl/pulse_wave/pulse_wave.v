module pulse_wave(
    input  wire        clk        ,
    input  wire        rstn       ,
    input  wire [31:0] pulse_width,
    input  wire        pulse_en   ,
    output reg         pulse_out
    );

    reg [31:0] counter    ;
    reg [31:0] latch_width;
    reg        pulse_en_d ;
    reg        active     ;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            counter     <= 32'd0;
            pulse_out   <= 1'b0;
            latch_width <= 32'd0;
            pulse_en_d  <= 1'b0;
            active      <= 1'b0;
        end else begin
            pulse_en_d <= pulse_en;

            if (!pulse_en) begin
                counter   <= 32'd0;
                pulse_out <= 1'b0;
                active    <= 1'b0;
            end else if (pulse_en && !pulse_en_d) begin //start of a new pulse
                latch_width <= pulse_width;
                counter     <= 32'd0;
                active      <= (pulse_width != 32'd0);
                pulse_out   <= (pulse_width != 32'd0);
            end else if (active) begin
                if (counter == latch_width - 32'd1) begin
                    counter   <= 32'd0;
                    pulse_out <= 1'b0;
                    active    <= 1'b0;
                end else begin
                    counter   <= counter + 32'd1;
                    pulse_out <= 1'b1;
                end
            end
        end
    end
endmodule