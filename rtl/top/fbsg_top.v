//top level of RTL
module signal_generator(
    input  wire        clk     ,
    input  wire        resetn  ,
    input  wire [31:0] ctrl_in ,
    input  wire [31:0] param_in, // parameters as required for wave gens

    // DA2 ports
    output wire        da2_sync,
    output wire        da2_sclk,
    output wire        da2_dina,
    output wire        da2_dinb,

    // DA3 ports
    output wire        da3_sync,
    output wire        da3_sclk,
    output wire        da3_din
    ); //TODO - write xdc file to match these

    wire [20:0] phase_inc;
    wire  [1:0] wave_sel ;
    wire        enable   ;
    wire        dac_sel  ;
    wire safe = 1'b1; // for now, assume always safe, no fault detection implemented yet

    fbsg_ctrl u_ctrl(
        .clk           (clk      ),
        .resetn        (resetn   ),
        .ctrl_in       (ctrl_in  ),
        .phase_inc     (phase_inc),
        .safe_wave_sel (wave_sel ),
        .enable        (enable   ),
        .dac_sel       (dac_sel  ),
        .safe          (safe     )
        );

    wire        sample_tick;
    wire [20:0] phase_val  ;

    sample_timer #(
        .CLK_FREQ    (50_000_000),
        .SAMPLE_FREQ (150_000   )
        )
        u_sample_timer(
            .clk         (clk        ),
            .resetn      (resetn     ),
            .sample_tick (sample_tick)
            );

    phase_acc u_phase_acc(
        .clk       (clk      ),
        .resetn    (resetn   ),
        .enable    (enable   ),
        .phase_inc (phase_inc),
        .phase_acc (phase_val)
        );

    wire [15:0] wave_square, wave_pulse, wave_sawtooth, wave_sine    ;
    wire        valid_square, valid_pulse, valid_sawtooth, valid_sine;

    //wave mux is to collect data and output in 12 bits
    square_wave u_square_wave(
        .clk       (clk         ),
        .resetn    (resetn      ),
        .dc        (param_in    ),
        .phase_acc (phase_val   ),
        .wave_out  (wave_square ),
        .valid_out (valid_square)
        );

    pulse_wave u_pulse_wave(
        .clk         (clk        ),
        .resetn      (resetn     ),
        .sample_tick (sample_tick),
        .pulse_width (param_in   ),
        .pulse_en    (enable     ),
        .pulse_out   (wave_pulse ),
        .valid_out   (valid_pulse)
        );

    sawtooth_wave u_sawtooth_wave(
        .clk       (clk           ),
        .resetn    (resetn        ),
        .phase_acc (phase_val     ),
        .wave_out  (wave_sawtooth ),
        .valid_out (valid_sawtooth)
        );

    sine_wave u_sine_wave(
        .clk         (clk        ),
        .resetn      (resetn     ),
        .sample_tick (sample_tick),
        .phase_in    (phase_val  ),
        .sine_out    (wave_sine  ),
        .valid_out   (valid_sine )
        );

    wire [15:0] mux_out  ;
    wire        mux_valid;

    wave_mux u_wave_mux(
        .clk            (clk           ),
        .resetn         (resetn        ),
        .enable         (enable        ),
        .wave_sel       (wave_sel      ),
        .data_valid     (sample_tick   ),
        .wave_square    (wave_square   ),
        .square_valid   (valid_square  ),
        .wave_pulse     (wave_pulse    ),
        .pulse_valid    (valid_pulse   ),
        .wave_sawtooth  (wave_sawtooth ),
        .sawtooth_valid (valid_sawtooth),
        .wave_sine      (wave_sine     ),
        .sine_valid     (valid_sine    ),
        .mux_out        (mux_out       ),
        .mux_valid      (mux_valid     )
        );

    wire [15:0] da3_data          = mux_out                             ;
    wire [11:0] da2_data          = mux_out[15:4]                       ; // take the top 12 bits for DA2

    wire        da2_valid_trigger = (dac_sel == 1'b0) ? mux_valid : 1'b0; // only trigger DA2 when selected
    wire        da3_valid_trigger = (dac_sel == 1'b1) ? mux_valid : 1'b0; // only trigger DA3 when selected

    pmod_da2_ctrl u_pmod_da2_ctrl(
        .clk         (clk              ),
        .resetn      (resetn           ),
        .sample_tick (da2_valid_trigger),
        .sync        (da2_sync         ),
        .sclk        (da2_sclk         ),
        .data_chA    (da2_data         ),
        .data_chB    (da2_data         ),
        .din_a       (da2_dina         ),
        .din_b       (da2_dinb         )
        );

    pmod_da3_ctrl u_pmod_da3_ctrl(
        .clk         (clk              ),
        .resetn      (resetn           ),
        .sample_tick (da3_valid_trigger),
        .data_in     (da3_data         ),
        .sync        (da3_sync         ),
        .sclk        (da3_sclk         ),
        .din         (da3_din          )
        );
endmodule