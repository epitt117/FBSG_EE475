module wave_mux #(
    parameter DATA_WIDTH = 16
    )
    (
    input  wire                  clk           ,
    input  wire                  resetn        ,

    // control signals
    input  wire                  enable        ,
    input  wire            [1:0] wave_sel      ,
    input  wire                  data_valid    ,

    //waveform data inputs
    input  wire [DATA_WIDTH-1:0] wave_square   ,
    input  wire                  square_valid  ,
    input  wire [DATA_WIDTH-1:0] wave_pulse    ,
    input  wire                  pulse_valid   ,
    input  wire [DATA_WIDTH-1:0] wave_sawtooth ,
    input  wire                  sawtooth_valid,
    input  wire [DATA_WIDTH-1:0] wave_sine     ,
    input  wire                  sine_valid    ,

    //multiplexed output
    output reg  [DATA_WIDTH-1:0] mux_out       ,
    output reg                   mux_valid
    );

    // take the output of the wave generators and select the appropriate one based on wave_sel and output to DAC controller

    wire [DATA_WIDTH-1:0] selected_data ;
    wire                  selected_valid;

    assign selected_data  = (wave_sel == 2'b00) ? wave_square   :
                            (wave_sel == 2'b01) ? wave_pulse    :
                            (wave_sel == 2'b10) ? wave_sawtooth :
                            (wave_sel == 2'b11) ? wave_sine     : {DATA_WIDTH{1'b0}};

    assign selected_valid = (wave_sel == 2'b00) ? square_valid   :
                            (wave_sel == 2'b01) ? pulse_valid    :
                            (wave_sel == 2'b10) ? sawtooth_valid :
                            (wave_sel == 2'b11) ? sine_valid     : 1'b0;

    // update when selected wave is enabled and valid, otherwise output 0
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            mux_out <= {DATA_WIDTH{1'b0}};
        end else begin
            mux_valid <= selected_valid;

            if (selected_valid) begin
                if (!enable) begin
                    mux_out <= {DATA_WIDTH{1'b0}};
                end else begin
                    mux_out <= selected_data;
                end
            end
        end
    end
endmodule