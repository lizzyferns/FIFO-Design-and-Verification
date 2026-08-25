`timescale 1ns / 1ps
module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
    )
    (
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire full, 
    output wire empty
    );
    
    localparam PTR_WIDTH = $clog2(DEPTH);
    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] write_ptr;
    reg [PTR_WIDTH-1:0] read_ptr;

    reg [$clog2(DEPTH+1)-1:0] count;

    wire write_valid;
    wire read_valid;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    assign write_valid = wr_en && !full;
    assign read_valid  = rd_en && !empty;


    always @(posedge clk) begin

        if (rst) begin

            write_ptr <= 0;
            read_ptr  <= 0;
            count     <= 0;
            data_out  <= 0;

        end

        else begin

            // WRITE OPERATION
            if (write_valid) begin
                memory[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1'b1;
            end

            // READ OPERATION
            if (read_valid) begin
                data_out <= memory[read_ptr];
                read_ptr <= read_ptr + 1'b1;
            end

            // FIFO COUNT CONTROL
            case ({write_valid, read_valid})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                2'b11:
                    count <= count;

                default:
                    count <= count;

            endcase

        end

    end
endmodule
