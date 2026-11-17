module pmod_da2_ctrl(
    // 12 bit DAC
    input  wire        clk        ,
    input  wire        resetn     ,
    input  wire        sample_tick,
    input  wire [11:0] data_chA   ,
    input  wire [11:0] data_chB   ,

    output reg         sync       ,
    output reg         sclk       ,
    output reg         din_a      ,
    output reg         din_b
    );

    //shift regs for control (4 bits) + data (12 bits)
    reg [15:0] shift_reg_a ;
    reg [15:0] shift_reg_b ;

    //counters
    reg  [1:0] sclk_divider; // divide 50 MHz clock to 12.5 MHz SCLK
    reg  [4:0] bit_counter ; // count bits being transferred

    //state machine
    localparam IDLE  = 2'b00;
    localparam SHIFT = 2'b01;
    localparam DONE  = 2'b10;
    reg [1:0] state;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sync         <= 1'b1;
            sclk         <= 1'b1;
            din_a        <= 1'b0;
            din_b        <= 1'b0;
            shift_reg_a  <= 16'b0;
            shift_reg_b  <= 16'b0;
            sclk_divider <= 2'b0;
            bit_counter  <= 5'b0;
            state        <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    sync         <= 1'b1;
                    sclk         <= 1'b1;
                    sclk_divider <= 2'b0;

                    if (sample_tick) begin
                        //latch data with 4'b0000 control header bits
                        shift_reg_a <= {4'b0000, data_chA};
                        shift_reg_b <= {4'b0000, data_chB};
                        bit_counter <= 5'd16; // 16 bits to shift out
                        state       <= SHIFT;
                    end
                end
                SHIFT: begin
                    sclk_divider <= sclk_divider + 1'b1;

                    //generate sclk falling edge out (shift data out)
                    if (sclk_divider == 2'b10) begin
                        sclk  <= 1'b0;
                        din_a <= shift_reg_a[15];
                        din_b <= shift_reg_b[15];
                    end

                    //generate sclk rising edge out (DAC samples)
                    if (sclk_divider == 2'b11) begin
                        sclk        <= 1'b1;
                        shift_reg_a <= shift_reg_a << 1;
                        shift_reg_b <= shift_reg_b << 1;

                        bit_counter <= bit_counter - 1'b1;
                        if (bit_counter == 5'b1) begin
                            state <= DONE;
                        end
                    end
                end
                DONE: begin
                    sclk_divider <= sclk_divider + 1'b1;

                    //wait half clock period before pulling SYNC high
                    if (sclk_divider == 2'b11) begin
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule;