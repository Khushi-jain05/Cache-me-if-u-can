
module memory_interface (
    input wire clk,
    input wire reset,

    // Cache miss request
    input wire cache_miss,
    input wire [31:0] request_address,

    // Cache refill outputs
    output wire fill_valid,
    output reg [21:0] fill_tag,
    output reg [5:0] fill_index,
    output reg [127:0] fill_block,

    // Main memory write interface (for initialization/testing)
    input wire memory_write_enable,
    input wire [31:0] memory_write_address,
    input wire [31:0] memory_write_data
);

    // State definitions
    localparam IDLE  = 3'b000;
    localparam READ0 = 3'b001;
    localparam READ1 = 3'b010;
    localparam READ2 = 3'b011;
    localparam READ3 = 3'b100;
    localparam FILL  = 3'b101;

    reg [2:0] state;

    // Store aligned block address
    reg [31:0] block_base;

    // Store four fetched words
    reg [31:0] word0;
    reg [31:0] word1;
    reg [31:0] word2;
    reg [31:0] word3;

    // Main memory connections
    reg [31:0] memory_read_address;
    wire [31:0] memory_read_data;

    // Instantiate main memory
    main_memory memory_unit (
        .clk(clk),

        .read_address(memory_read_address),
        .read_data(memory_read_data),

        .write_enable(memory_write_enable),
        .write_address(memory_write_address),
        .write_data(memory_write_data)
    );

    // Refill is valid during FILL state
    assign fill_valid = (state == FILL);

    // Select memory address according to current state
    always @(*) begin

        memory_read_address = block_base;

        case (state)

            READ0:
                memory_read_address = block_base;

            READ1:
                memory_read_address = block_base + 32'd4;

            READ2:
                memory_read_address = block_base + 32'd8;

            READ3:
                memory_read_address = block_base + 32'd12;

            default:
                memory_read_address = block_base;

        endcase

    end

    // State machine and data collection
    always @(posedge clk) begin

        if (reset) begin

            state <= IDLE;

            block_base <= 32'b0;

            word0 <= 32'b0;
            word1 <= 32'b0;
            word2 <= 32'b0;
            word3 <= 32'b0;

            fill_tag <= 22'b0;
            fill_index <= 6'b0;
            fill_block <= 128'b0;

        end

        else begin

            case (state)

                IDLE: begin

                    if (cache_miss) begin

                        // Align address to 16-byte block
                        block_base <= {
                            request_address[31:4],
                            4'b0000
                        };

                        // Save tag and cache index
                        fill_tag <= request_address[31:10];
                        fill_index <= request_address[9:4];

                        state <= READ0;

                    end

                end

                READ0: begin

                    word0 <= memory_read_data;
                    state <= READ1;

                end

                READ1: begin

                    word1 <= memory_read_data;
                    state <= READ2;

                end

                READ2: begin

                    word2 <= memory_read_data;
                    state <= READ3;

                end

                READ3: begin

                    word3 <= memory_read_data;

                    // Pack four words into one 128-bit block
                    fill_block <= {
                        memory_read_data,
                        word2,
                        word1,
                        word0
                    };

                    state <= FILL;

                end

                FILL: begin

                    // Cache captures the block on this clock edge
                    state <= IDLE;

                end

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule
