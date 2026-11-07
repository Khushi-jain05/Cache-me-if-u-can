
module main_memory #(
    parameter WORDS = 1024
)(
    input wire clk,

    input wire [31:0] read_address,
    output reg [31:0] read_data,

    input wire write_enable,
    input wire [31:0] write_address,
    input wire [31:0] write_data
);

    reg [31:0] memory [0:WORDS-1];

    localparam ADDR_WIDTH = $clog2(WORDS);

    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Combinational memory read
    always @(*) begin
        read_data = memory[read_address[ADDR_WIDTH+1:2]];
    end

    // Clocked memory write
    always @(posedge clk) begin
        if (write_enable) begin
            memory[write_address[ADDR_WIDTH+1:2]] <= write_data;
        end
    end

endmodule
