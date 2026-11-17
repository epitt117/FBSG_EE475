module pmod_da3_ctrl(
    // 16 bit DAC
    input  wire        clk        ,
    input  wire        resetn     ,
    input  wire        sample_tick,
    input  wire [15:0] data_in    ,
    output reg         sync       , // active low chip select
    output reg         sclk       ,
    output reg         din
    );

    localparam [1:0]
        IDLE  = 2'b00,
        SHIFT = 2'b01,
        LATCH = 2'b10;

    reg  [1:0] state    ;
    reg  [4:0] bit_count; // 16 bits to shift out
    reg [15:0] shift_reg;
    reg  [2:0] clk_div  ; // clock divider for generating sclk

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state     <= IDLE;
            sync      <= 1'b1;
            sclk      <= 1'b0;
            din       <= 1'b0;
            bit_count <= 5'd0;
            shift_reg <= 16'd0;
            clk_div   <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    sync    <= 1'b1;
                    sclk    <= 1'b0;
                    din     <= 1'b0;
                    clk_div <= 3'd0;

                    if (sample_tick) begin
                        shift_reg <= data_in;
                        bit_count <= 5'd16; // prepare to shift out 16 bits
                        sync      <= 1'b0;
                        din       <= data_in[15]; // MSB first
                        state     <= SHIFT;
                    end
                end

                SHIFT: begin
                    clk_div <= clk_div + 3'd1;

                    if (clk_div == 3'd3) begin //halfway through spi period -> rising edge of sclk
                        sclk <= 1'b1;
                    end else if (clk_div == 3'd7) begin //end of spi period -> falling edge of sclk
                        sclk <= 1'b0;

                        if (bit_count > 0) begin
                            bit_count <= bit_count - 5'd1;
                            shift_reg <= {shift_reg[14:0], 1'b0}; // shift left
                            din       <= shift_reg[14]; // next bit to send
                        end else begin // all bits sent so latch
                            state <= LATCH;
                        end
                    end
                end

                LATCH: begin
                    clk_div <= clk_div + 3'd1;
                    if (clk_div == 3'd3) begin
                        sync  <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule