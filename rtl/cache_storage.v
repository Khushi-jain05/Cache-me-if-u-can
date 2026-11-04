
module cache_storage (
    input wire clk,
    input wire reset,

    // CPU lookup inputs
    input wire lookup_valid,
    input wire [21:0] lookup_tag,
    input wire [5:0] lookup_index,
    input wire [1:0] word_index,

    // Lookup outputs
    output wire hit,
    output wire miss,
    output reg [31:0] read_data,

    // Block refill inputs from memory interface
    input wire fill_valid,
    input wire [21:0] fill_tag,
    input wire [5:0] fill_index,
    input wire [127:0] fill_block
);

    // 64 cache lines, each containing 128 bits of data
    reg [127:0] data_array [0:63];

    // Store 22-bit tag for each cache line
    reg [21:0] tag_array [0:63];

    // Store valid bit for each cache line
    reg valid_array [0:63];

    // Temporary signal for tag comparison
    wire tag_match;

    // Compare requested tag with stored tag
    assign tag_match =
        (tag_array[lookup_index] == lookup_tag);

    // Cache hit: line is valid AND tags match
    assign hit =
        lookup_valid &&
        valid_array[lookup_index] &&
        tag_match;

    // Cache miss: valid lookup but no hit
    assign miss = lookup_valid && !hit;

    // Select requested 32-bit word
    always @(*) begin

        read_data = 32'b0;

        if (hit) begin
            case (word_index)

                2'b00:
                    read_data = data_array[lookup_index][31:0];

                2'b01:
                    read_data = data_array[lookup_index][63:32];

                2'b10:
                    read_data = data_array[lookup_index][95:64];

                2'b11:
                    read_data = data_array[lookup_index][127:96];

                default:
                    read_data = 32'b0;

            endcase
        end

    end

    // Reset valid bits and write incoming cache blocks
    integer i;

    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 64; i = i + 1) begin
                valid_array[i] <= 1'b0;
            end

        end

        else if (fill_valid) begin

            data_array[fill_index] <= fill_block;
            tag_array[fill_index] <= fill_tag;
            valid_array[fill_index] <= 1'b1;

        end

    end

endmodule
