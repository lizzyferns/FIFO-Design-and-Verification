`timescale 1ns / 1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 8;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] data_in;

    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    integer i;
    integer errors;

    // Instantiate FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // 100 MHz Clock
    always #5 clk = ~clk;


    initial begin

        clk     = 0;
        rst     = 1;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 0;
        errors  = 0;

        // RESET TEST
        #20;
        rst = 0;

        #10;

        if (empty)
            $display("PASS: FIFO empty after reset");
        else begin
            $display("FAIL: FIFO should be empty after reset");
            errors = errors + 1;
        end

        // WRITE TEST
        $display("\nWriting 8 values...");

        for (i = 1; i <= 8; i = i + 1) begin

            @(negedge clk);

            wr_en   = 1;
            data_in = i;

            @(posedge clk);

            #1;

            $display("WRITE: data = %0d", data_in);

        end

        @(negedge clk);

        wr_en = 0;

        // FULL FLAG TEST
        #1;

        if (full)
            $display("PASS: FIFO Full flag asserted");
        else begin
            $display("FAIL: FIFO should be full");
            errors = errors + 1;
        end

        // OVERFLOW TEST
        @(negedge clk);

        wr_en   = 1;
        data_in = 8'hAA;

        @(posedge clk);

        #1;

        @(negedge clk);

        wr_en = 0;

        $display("Overflow write attempted");

        // READ TEST
        $display("\nReading FIFO...");

        for (i = 1; i <= 8; i = i + 1) begin

            @(negedge clk);

            rd_en = 1;

            @(posedge clk);

            #1;

            if (data_out == i)
                $display("PASS: Expected %0d, Received %0d",
                         i, data_out);
            else begin
                $display("FAIL: Expected %0d, Received %0d",
                         i, data_out);

                errors = errors + 1;
            end

        end

        @(negedge clk);

        rd_en = 0;


        // EMPTY FLAG TEST
        #1;

        if (empty)
            $display("PASS: FIFO Empty flag asserted");
        else begin
            $display("FAIL: FIFO should be empty");
            errors = errors + 1;
        end

        // UNDERFLOW TEST
        @(negedge clk);

        rd_en = 1;

        @(posedge clk);

        #1;

        @(negedge clk);

        rd_en = 0;

        $display("Underflow read attempted");


        // FINAL RESULT
        #20;

        if (errors == 0)
            $display("\n============================");
        if (errors == 0)
            $display(" ALL FIFO TESTS PASSED ");
        if (errors == 0)
            $display("============================\n");

        if (errors != 0)
            $display("\nTEST FAILED WITH %0d ERRORS\n",
                     errors);


        $finish;

    end

endmodule
