
module cache_top (
    input wire clk,
    input wire reset,

    // CPU request interface
    input wire request_valid,
    input wire [31:0] request_address,
    output wire request_ready,

    // CPU response interface
    output wire response_valid,
    input wire response_ready,
    output wire [31:0] response_data,

    // Main memory initialization/write interface
    input wire memory_write_enable,
    input wire [31:0] memory_write_address,
    input wire [31:0] memory_write_data,

    // Debug output for waveform
    output wire [2:0] controller_state
);

    // Controller signals
    wire lookup_valid;
    wire [31:0] lookup_address;

    wire memory_request;
    wire [31:0] memory_address;

    // Address decoder signals
    wire [21:0] tag;
    wire [5:0] index;
    wire [3:0] offset;
    wire [1:0] word_index;

    // Cache signals
    wire cache_hit;
    wire cache_miss;
    wire [31:0] cache_read_data;

    // Refill signals
    wire fill_valid;
    wire [21:0] fill_tag;
    wire [5:0] fill_index;
    wire [127:0] fill_block;


    // 1. Cache controller FSM
    cache_controller controller (
        .clk(clk),
        .reset(reset),

        .request_valid(request_valid),
        .request_address(request_address),
        .request_ready(request_ready),

        .response_valid(response_valid),
        .response_ready(response_ready),
        .response_data(response_data),

        .lookup_valid(lookup_valid),
        .lookup_address(lookup_address),

        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_read_data(cache_read_data),

        .memory_request(memory_request),
        .memory_address(memory_address),
        .fill_valid(fill_valid),

        .current_state(controller_state)
    );


    // 2. Address decoder
    address_decoder decoder (
        .address(lookup_address),
        .tag(tag),
        .index(index),
        .offset(offset),
        .word_index(word_index)
    );


    // 3. Cache storage
    cache_storage cache (
        .clk(clk),
        .reset(reset),

        .lookup_valid(lookup_valid),
        .lookup_tag(tag),
        .lookup_index(index),
        .word_index(word_index),

        .hit(cache_hit),
        .miss(cache_miss),
        .read_data(cache_read_data),

        .fill_valid(fill_valid),
        .fill_tag(fill_tag),
        .fill_index(fill_index),
        .fill_block(fill_block)
    );


    // 4. Memory interface and main memory
    memory_interface memory_unit (
        .clk(clk),
        .reset(reset),

        .cache_miss(memory_request),
        .request_address(memory_address),

        .fill_valid(fill_valid),
        .fill_tag(fill_tag),
        .fill_index(fill_index),
        .fill_block(fill_block),

        .memory_write_enable(memory_write_enable),
        .memory_write_address(memory_write_address),
        .memory_write_data(memory_write_data)
    );

endmodule
