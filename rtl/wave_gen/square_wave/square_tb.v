module test;

    reg        resetn = 1'b0  ;
    reg        clk    = 1'b0  ;
    reg [31:0] dc     = 32'd50;
    reg [31:0] period = 32'd20;

    wire square_out;
    square_wave square_inst(
        .clk        (clk       ),
        .resetn     (resetn    ),
        .dc         (dc        ),
        .period     (period    ),
        .square_out (square_out)
        );

    initial begin
        $dumpfile("square_tb.vcd");
        $dumpvars(0, test);
        #10;
        resetn = 1'b1;
        #10;
        resetn = 1'b0;
        #10;
        resetn = 1'b1;

        #10;
        dc     = 32'd25; // 25% duty cycle
        period = 32'd20; // 20 clock cycles per period
        #400;

        dc     = 32'd75; // 75% duty cycle
        period = 32'd40; // 40 clock cycles per period
        #800;

        dc     = 32'd100; // 100% duty cycle
        period = 32'd30; // 30 clock cycles per period
        #600;

        dc     = 32'd0; // 0% duty cycle
        period = 32'd50; // 50 clock cycles per period
        #1000;

        $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("time=%0t, resetn=%b, clk=%b, dc=%d, period=%d, square_out=%b", $time, resetn, clk, dc, period, square_out);
    end

    initial
    $monitor("time=%0t, resetn=%b, clk=%b, dc=%d, period=%d, square_out=%b", $time, resetn, clk, dc, period, square_out);

endmodule