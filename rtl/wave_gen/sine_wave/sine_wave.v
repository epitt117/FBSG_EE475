`include "../../../rtl/wave_gen/phase_acc.v"

module sine_wave #(
    parameter integer PHASE_WIDTH = 21,
    parameter integer DATA_WIDTH  = 16
    )
    (
    input  wire                   clk        ,
    input  wire                   resetn     ,
    input  wire                   sample_tick,
    input  wire [PHASE_WIDTH-1:0] phase_in   ,
    output reg                    valid_out  ,
    output reg   [DATA_WIDTH-1:0] sine_out
    );

    //pad 21 bit phase to 24 bits for sine lookup
    wire [23:0] s_axis_phase_tdata = {3'b000, phase_in};

    // pad 12 bit sine output to 16 bits for AXI4-Stream interface
    wire [15:0] m_axis_dout_tdata ;
    wire        m_axis_dout_tvalid;

    // instantiate CORDIC IP core for sine wave generation
    cordic_0 cordic_inst(
        .aclk                (clk               ),
        .s_axis_phase_tvalid (sample_tick       ),
        .s_axis_phase_tdata  (s_axis_phase_tdata),
        .m_axis_dout_tvalid  (m_axis_dout_tvalid),
        .m_axis_dout_tdata   (m_axis_dout_tdata )
        );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            sine_out  <= {DATA_WIDTH{1'b0}};
            valid_out <= 1'b0;
        end else if (m_axis_dout_tvalid) begin
            sine_out  <= {~m_axis_dout_tdata[15], m_axis_dout_tdata[14:4]}; // take 12 bits from 16 bit output, invert MSB for signed output
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule