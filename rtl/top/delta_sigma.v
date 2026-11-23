module delta_sigma #(
    parameter integer DATA_WIDTH = 16
    )
    (
    input  wire                  clk   ,
    input  wire                  resetn,
    input  wire [DATA_WIDTH-1:0] din   ,
    output reg                   dout
    );

    // TEMPORARY - this module is until the actual PMOD DACs arrive
    // TODO - also need some resistor and capacitor as low pass filter to smooth the output of the DAC (cap to PMOD GND, resistor in series with PMOD output)
    reg [DATA_WIDTH:0] accumulator; // 17 bit to avoid overflow

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            accumulator <= 0;
            dout        <= 0;
        end else begin
            accumulator <= accumulator + din - {dout, {DATA_WIDTH-1{1'b0}}}; // Subtract the output value (scaled)
            dout        <= accumulator[DATA_WIDTH]; // Output the MSB of the accumulator
        end
    end
endmodule