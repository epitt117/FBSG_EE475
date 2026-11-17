module test;

    parameter integer PHASE_WIDTH  = 21;
    parameter integer OUTPUT_WIDTH = 12;

    // tb signals
    reg                   resetn    = 1'b0 ;
    reg                   clk       = 1'b0 ;

    // emulate shared phase accumulator
    reg [PHASE_WIDTH-1:0] phase_inc = 21'd0;
    reg [PHASE_WIDTH-1:0] phase_in  = 21'd0;

    // dut signals
    wire [OUTPUT_WIDTH-1:0] sawtooth_out;

    // instantiate dut
    sawtooth_wave #(
        .PHASE_WIDTH  (PHASE_WIDTH ),
        .OUTPUT_WIDTH (OUTPUT_WIDTH)
        )
        dut(
            .clk          (clk         ),
            .resetn       (resetn      ),
            .phase_in     (phase_in    ),
            .sawtooth_out (sawtooth_out)
            );

    // clock generation
    always #5 clk = ~clk;

    // emulate phase accumulator
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            phase_in <= {PHASE_WIDTH{1'b0}};
        end else begin
            phase_in <= phase_in + phase_inc;
        end
    end

    // test sequence
    initial begin
        $dumpfile("sawtooth_tb.vcd");
        $dumpvars(0, test);

        $display("Starting sim...");
        // reset
        #10 resetn = 1'b1;
        #10 resetn = 1'b0;
        #10 resetn = 1'b1;

        $display();
    end
endmodule