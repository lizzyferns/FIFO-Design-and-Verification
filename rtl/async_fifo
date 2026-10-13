module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input wire wr_clk,
    input wire rd_clk,
    input wire wr_rst_n,
    input wire rd_rst_n,

    input wire wr_en,
    input wire [DATA_WIDTH-1:0] wr_data,
    output reg full,

    input wire rd_en,
    output reg [DATA_WIDTH-1:0] rd_data,
    output reg empty
);

    // FIFO depth = 2^ADDR_WIDTH
    localparam DEPTH = (1 << ADDR_WIDTH);

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Binary and Gray-code pointers
    // Extra MSB distinguishes full and empty conditions
    reg [ADDR_WIDTH:0] wbin, wgray;
    reg [ADDR_WIDTH:0] rbin, rgray;

    // Two-stage synchronizers
    reg [ADDR_WIDTH:0] rgray_wr_sync1;
    reg [ADDR_WIDTH:0] rgray_wr_sync2;

    reg [ADDR_WIDTH:0] wgray_rd_sync1;
    reg [ADDR_WIDTH:0] wgray_rd_sync2;

    // Only perform valid writes and reads
    wire wr_fire = wr_en && !full;
    wire rd_fire = rd_en && !empty;

    // Calculate next binary pointers
    wire [ADDR_WIDTH:0] wbin_next;
    wire [ADDR_WIDTH:0] rbin_next;

    assign wbin_next = wbin + wr_fire;
    assign rbin_next = rbin + rd_fire;

    // Binary-to-Gray conversion
    wire [ADDR_WIDTH:0] wgray_next;
    wire [ADDR_WIDTH:0] rgray_next;

    assign wgray_next = (wbin_next >> 1) ^ wbin_next;
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;

    // Full detection requires inversion of the
    // two most significant Gray-code bits
    localparam [ADDR_WIDTH:0] FULL_MASK =
        (3 << (ADDR_WIDTH-1));

    wire wfull_next;
    wire rempty_next;

    assign wfull_next =
        (wgray_next == (rgray_wr_sync2 ^ FULL_MASK));

    assign rempty_next =
        (rgray_next == wgray_rd_sync2);

    // WRITE CLOCK DOMAIN
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wbin  <= 0;
            wgray <= 0;
            full  <= 1'b0;
        end
        else begin
            if (wr_fire)
                mem[wbin[ADDR_WIDTH-1:0]] <= wr_data;

            wbin  <= wbin_next;
            wgray <= wgray_next;
            full  <= wfull_next;
        end
    end

    // READ CLOCK DOMAIN
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rbin    <= 0;
            rgray   <= 0;
            rd_data <= 0;
            empty   <= 1'b1;
        end
        else begin
            if (rd_fire)
                rd_data <= mem[rbin[ADDR_WIDTH-1:0]];

            rbin  <= rbin_next;
            rgray <= rgray_next;
            empty <= rempty_next;
        end
    end

    // Synchronize read pointer into write domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rgray_wr_sync1 <= 0;
            rgray_wr_sync2 <= 0;
        end
        else begin
            rgray_wr_sync1 <= rgray;
            rgray_wr_sync2 <= rgray_wr_sync1;
        end
    end

    // Synchronize write pointer into read domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wgray_rd_sync1 <= 0;
            wgray_rd_sync2 <= 0;
        end
        else begin
            wgray_rd_sync1 <= wgray;
            wgray_rd_sync2 <= wgray_rd_sync1;
        end
    end

endmodule
