
`timescale 1ns / 1ps

module tb_async_fifo;

    // PARAMETERS
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    parameter DEPTH = (1 << ADDR_WIDTH);

    // SIGNAL DECLARATIONS
    reg wr_clk;
    reg rd_clk;

    reg wr_rst_n;
    reg rd_rst_n;

    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] wr_data;

    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire empty;

    // DUT INSTANTIATION
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),

        .wr_rst_n(wr_rst_n),
        .rd_rst_n(rd_rst_n),

        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),

        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // CLOCK GENERATION
    // Write clock: 100 MHz
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    // Read clock: approximately 71.43 MHz
    initial begin
        rd_clk = 0;
        #3;
        forever #7 rd_clk = ~rd_clk;
    end

    // TEST CONTROL
    // mode = 0 : idle
    // mode = 1 : continuous writes
    // mode = 2 : continuous reads
    // mode = 3 : randomized read/write
    // mode = 4 : final drain

    integer mode;

    integer write_count;
    integer read_count;
    integer error_count;

    integer blocked_writes;
    integer blocked_reads;

    integer put_idx;
    integer get_idx;

    integer seed_w;
    integer seed_r;

    // Reference memory for the scoreboard
    reg [DATA_WIDTH-1:0] scoreboard [0:4095];

    reg [DATA_WIDTH-1:0] expected_data;

    // WRITE STIMULUS
    always @(negedge wr_clk) begin

        if (!wr_rst_n) begin
            wr_en = 0;
            wr_data = 0;
        end
        else begin

            case (mode)

                1: wr_en = 1;

                3: wr_en = (($random(seed_w) & 3) != 0);

                default: wr_en = 0;

            endcase

            // Generate changing input data
            wr_data = wr_data + 8'h3D;

        end
    end

    // READ STIMULUS
    always @(negedge rd_clk) begin

        if (!rd_rst_n) begin
            rd_en = 0;
        end
        else begin

            case (mode)

                2: rd_en = 1;

                3: rd_en = (($random(seed_r) & 3) != 0);

                4: rd_en = 1;

                default: rd_en = 0;

            endcase

        end
    end


    // WRITE MONITOR
    always @(posedge wr_clk) begin

        if (wr_rst_n && wr_en) begin

            if (!full) begin

                if (put_idx >= 4096) begin
                    $display("FAIL: Scoreboard overflow");
                    $finish;
                end

                scoreboard[put_idx] = wr_data;

                put_idx = put_idx + 1;
                write_count = write_count + 1;

                $display(
                    "[WRITE] Time=%0t Data=%h Total=%0d",
                    $time, wr_data, write_count
                );

            end
            else begin

                blocked_writes = blocked_writes + 1;

            end

        end
    end

    // READ MONITOR AND SCOREBOARD
    always @(posedge rd_clk) begin

        if (rd_rst_n && rd_en) begin

            if (!empty) begin

                if (get_idx >= put_idx) begin

                    $display(
                        "[ERROR] Unexpected read at %0t",
                        $time
                    );

                    error_count = error_count + 1;

                end
                else begin

                    expected_data = scoreboard[get_idx];

                    get_idx = get_idx + 1;
                    read_count = read_count + 1;

                    // Wait for nonblocking assignment
                    // updating registered rd_data
                    #1;

                    if (rd_data !== expected_data) begin

                        $display(
                            "[ERROR] Time=%0t Expected=%h Got=%h",
                            $time, expected_data, rd_data
                        );

                        error_count = error_count + 1;

                    end
                    else begin

                        $display(
                            "[READ PASS] Time=%0t Data=%h",
                            $time, rd_data
                        );

                    end

                end

            end
            else begin

                blocked_reads = blocked_reads + 1;

            end
        end
    end

    // MAIN TEST SEQUENCE
    initial begin

        wr_rst_n = 0;
        rd_rst_n = 0;

        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        mode = 0;

        write_count = 0;
        read_count = 0;
        error_count = 0;

        blocked_writes = 0;
        blocked_reads = 0;

        put_idx = 0;
        get_idx = 0;

        seed_w = 32'h12345678;
        seed_r = 32'h23456789;

        expected_data = 0;

        $display("================================");
        $display(" ASYNCHRONOUS FIFO VERIFICATION");
        $display("================================");

        // --------------------------------------
        // TEST 1: RESET
        // --------------------------------------
        $display("TEST 1: RESET");

        #31;

        wr_rst_n = 1;
        rd_rst_n = 1;

        #50;

        if (empty !== 1'b1 || full !== 1'b0) begin
            $display("ERROR: Incorrect reset flags");
            error_count = error_count + 1;
        end

        // TEST 2: FILL FIFO
        $display("TEST 2: FILL FIFO");

        mode = 1;
        #250;

        mode = 0;
        #30;

        if (full !== 1'b1) begin
            $display("ERROR: Full flag not asserted");
            error_count = error_count + 1;
        end

        // TEST 3: DRAIN FIFO
        $display("TEST 3: DRAIN FIFO");

        mode = 2;
        #350;

        mode = 0;
        #30;

        if (empty !== 1'b1) begin
            $display("ERROR: Empty flag not asserted");
            error_count = error_count + 1;
        end

        // TEST 4: RANDOM OPERATIONS
        $display("TEST 4: RANDOM READ/WRITE");

        mode = 3;
        #4000;

        // TEST 5: FINAL DRAIN
        $display("TEST 5: FINAL DRAIN");

        mode = 4;
        #600;

        mode = 0;
        #50;

        // FINAL RESULTS
        $display("");
        $display("================================");
        $display(" FINAL VERIFICATION RESULTS");
        $display("================================");

        $display("Total Writes   = %0d", write_count);
        $display("Total Reads    = %0d", read_count);
        $display("Blocked Writes = %0d", blocked_writes);
        $display("Blocked Reads  = %0d", blocked_reads);
        $display("Total Errors   = %0d", error_count);

        if (
            error_count == 0 &&
            write_count == read_count &&
            write_count > DEPTH &&
            blocked_writes > 0 &&
            blocked_reads > 0 &&
            empty === 1'b1 &&
            full === 1'b0
        ) begin

            $display("================================");
            $display(" PASS: ALL FIFO TESTS PASSED");
            $display("================================");

        end
        else begin

            $display("================================");
            $display(" FAIL: FIFO VERIFICATION FAILED");
            $display("================================");

        end

        $finish;

    end

    // SIMULATION TIMEOUT
    initial begin
        #10000;
        $display("FAIL: SIMULATION TIMEOUT");
        $finish;
    end

endmodule
