module fbsg_ctrl(
    input  wire        clk          ,
    input  wire        resetn       ,
    input  wire [31:0] ctrl_in      ,
    input  wire        safe         , // 1 = safe, 0 = tripped
    output wire [20:0] phase_inc    ,
    output reg   [1:0] safe_wave_sel,
    output reg         enable       ,
    output reg         dac_sel
    );

    // local states for control
    localparam [1:0] IDLE = 2'b00,
                            ACTIVE  = 2'b01,
                            FAULT = 2'b10;

    reg [1:0] current_state, next_state;

    wire req_enable   = ctrl_in[0]  ; // request enable from control input
    wire req_wave_sel = ctrl_in[2:1]; // requested wave selection from control input
    wire req_dac_sel  = ctrl_in[30] ; // requested DAC selection from control input
    wire clear_fault  = ctrl_in[31] ; // clear fault request from control input

    // ctrl_in structure:
    // [31] - fault clear (1 = clear, 0 = no action)
    // [30] - DAC selection (0 = DA2, 1 = DA3)
    // [29:24] - reserved
    // [23:3] - phase_inc (21 bits)
    // [2:1] - wave_sel (square, pulse, sawtooth, sine)
    // [0] - enable (pause/play)

    assign phase_inc = ctrl_in[23:3];

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state; // default to holding state

        if (!safe) begin
            next_state = FAULT; // if tripped, go to fault state
        end else begin
            case (current_state)
                IDLE: begin
                    if (req_enable) begin
                        next_state = ACTIVE; // if enable requested, go to active state
                    end
                end
                ACTIVE: begin
                    if (!req_enable) begin
                        next_state = IDLE; // if enable not requested, go to idle state
                    end
                end
                FAULT: begin
                    if (clear_fault && safe) begin
                        next_state = IDLE; // if fault is cleared and safe, go to idle state
                    end
                end

                default: next_state = IDLE; // default to idle state
            endcase
        end
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            safe_wave_sel <= 2'b00; // default to square wave
            enable        <= 1'b0;
            dac_sel       <= 1'b0; // default to DA2
        end else begin
            case (next_state)
                FAULT: begin
                    enable <= 1'b0;
                end
                IDLE: begin
                    enable        <= 1'b0;
                    safe_wave_sel <= req_wave_sel; // latch the requested wave selection for next time
                    dac_sel       <= req_dac_sel;  // latch the requested DAC selection for next time
                end
                ACTIVE: begin
                    enable <= 1'b1;
                end

                default: begin
                    enable  <= 1'b0;
                    dac_sel <= 1'b0; // default to DA2 if unknown state
                end
            endcase
        end
    end
endmodule;