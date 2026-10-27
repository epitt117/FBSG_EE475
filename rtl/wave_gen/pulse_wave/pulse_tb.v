module test;

    reg resetn = 1'b0;
    reg en     = 1'b0;
    reg clk    = 1'b0;

    wire pulse_out;
    pulse_wave pulse_inst(
        .clk         (clk      ),
        .rstn        (resetn   ),
        .pulse_width (32'd10   ),
        .pulse_en    (en       ),
        .pulse_out   (pulse_out)
        );

    initial begin
        $dumpfile("pulse_tb.vcd");
        $dumpvars(0, test);
        #10;
        resetn = 1'b1;
        #10;
        resetn = 1'b0;
        #10;
        resetn = 1'b1;

        #10;
        en = 1'b1;
        #100;
        en = 1'b0;
        #100;
        en = 1'b1;
        #50;
        $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("time=%0t, resetn=%b, en=%b, clk=%b, pulse_out=%b", $time, resetn, en, clk, pulse_out);
    end

    initial
    $monitor("time=%0t, resetn=%b, en=%b, clk=%b, pulse_out=%b", $time, resetn, en, clk, pulse_out);
endmodule