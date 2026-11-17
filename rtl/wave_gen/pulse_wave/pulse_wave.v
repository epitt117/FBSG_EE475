module pulse_wave #(
    parameter DATA_WIDTH = 16
    )
    (
    input  wire                  clk        ,
    input  wire                  resetn     ,
    input  wire                  sample_tick,

    input  wire           [31:0] pulse_width,
    input  wire                  pulse_en   ,
    output reg  [DATA_WIDTH-1:0] pulse_out  ,
    output reg                   valid_out
    );

    reg [31:0] counter    ;
    reg [31:0] latch_width;
    reg        pulse_en_d ;
    reg        active     ;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            counter     <= 32'd0;
            pulse_out   <= {DATA_WIDTH{1'b0}};
            valid_out   <= 1'b0;
            latch_width <= 32'd0;
            pulse_en_d  <= 1'b0;
            active      <= 1'b0;
        end else begin
            valid_out  <= sample_tick;
            pulse_en_d <= pulse_en;

            if (!pulse_en_d && pulse_en && !active) begin
                latch_width <= pulse_width;
                counter     <= 32'd0;
                active      <= (pulse_width != 32'd0);
                pulse_out   <= (pulse_width != 32'd0) ? {DATA_WIDTH{1'b1}} : {DATA_WIDTH{1'b0}};
            end else if (!pulse_en && !active) begin
                counter   <= 32'd0;
                pulse_out <= {DATA_WIDTH{1'b0}};
                active    <= 1'b0;
            end

            if (active && sample_tick) begin // active takes priority over pulse_en, so that the pulse is not interrupted mid-way
                if (latch_width != 32'd0 && counter == latch_width - 32'd1) begin
                    counter   <= 32'd0;
                    pulse_out <= {DATA_WIDTH{1'b0}};
                    active    <= 1'b0;
                end else begin
                    counter   <= counter + 32'd1;
                    pulse_out <= {DATA_WIDTH{1'b1}};
                end
            end
        end
    end
endmodule