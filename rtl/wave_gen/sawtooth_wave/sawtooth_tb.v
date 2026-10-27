module test;

    reg        resetn = 1'b0 ;
    reg        clk    = 1'b0 ;
    reg [11:0] step   = 12'd1;

    wire [11:0] sawtooth_out;

    sawtooth_wave sawtooth_inst(
        .clk          (clk         ),
        .resetn       (resetn      ),
        .step         (step        ),
        .sawtooth_out (sawtooth_out)
        );

    initial begin
        $dumpfile("sawtooth_tb.vcd");
        $dumpvars(0, test);

        #10;
        resetn = 1'b1;
        #10;
        resetn = 1'b0;
        #10;
        resetn = 1'b1;

        #500;

        step = 12'd2;
        #500;

        step = 12'd6;
        #500;
        $finish;
    end

    always #1 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("time=%0t, resetn=%b, clk=%b, sawtooth_out=%d", $time, resetn, clk, sawtooth_out);
    end

    initial
    $monitor("time=%0t, resetn=%b, clk=%b, sawtooth_out=%d", $time, resetn, clk, sawtooth_out);
endmodule