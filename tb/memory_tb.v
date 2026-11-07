
`timescale 1ns/1ps

module memory_tb;

    reg clk;
    reg reset;

    // CPU request
    reg [31:0] cpu_address;
    reg lookup_valid;

    // Address decoder signals
    wire [21:0] tag;
    wire [5:0] index;
    wire [3:0] offset;
    wire [1:0] word_index;

    // Cache signals
    wire hit;
    wire miss;
    wire [31:0] read_data;

    // Memory interface signals
    wire fill_valid;
    wire [21:0] fill_tag;
    wire [5:0] fill_index;
    wire [127:0] fill_block;

    // Main memory initialization signals
    reg memory_write_enable;
    reg [31:0] memory_write_address;
    reg [31:0] memory_write_data;

    integer i;
    reg [31:0] expected_data;

    // Address decoder
    address_decoder decoder (
        .address(cpu_address),
        .tag(tag),
        .index(index),
        .offset(offset),
        .word_index(word_index)
    );

    // Cache storage
    cache_storage cache (
        .clk(clk),
        .reset(reset),

        .lookup_valid(lookup_valid),
        .lookup_tag(tag),
        .lookup_index(index),
        .word_index(word_index),

        .hit(hit),
        .miss(miss),
        .read_data(read_data),

        .fill_valid(fill_valid),
        .fill_tag(fill_tag),
        .fill_index(fill_index),
        .fill_block(fill_block)
    );

    // Memory interface
    memory_interface memory_interface_unit (
        .clk(clk),
        .reset(reset),

        .cache_miss(miss),
        .request_address(cpu_address),

        .fill_valid(fill_valid),
        .fill_tag(fill_tag),
        .fill_index(fill_index),
        .fill_block(fill_block),

        .memory_write_enable(memory_write_enable),
        .memory_write_address(memory_write_address),
        .memory_write_data(memory_write_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        cpu_address = 0;
        lookup_valid = 0;

        memory_write_enable = 0;
        memory_write_address = 0;
        memory_write_data = 0;

        $display("------------------------------------");
        $display("STARTING MAIN MEMORY TESTS");
        $display("------------------------------------");

        // Reset the cache and memory interface
        @(posedge clk);
        #1;
        reset = 0;

        // Initialize main memory

        @(negedge clk);
        memory_write_enable = 1;
        memory_write_address = 32'h00000020;
        memory_write_data = 32'hAAAAAAAA;

        @(negedge clk);
        memory_write_address = 32'h00000024;
        memory_write_data = 32'hBBBBBBBB;

        @(negedge clk);
        memory_write_address = 32'h00000028;
        memory_write_data = 32'hCCCCCCCC;

        @(negedge clk);
        memory_write_address = 32'h0000002C;
        memory_write_data = 32'hDDDDDDDD;

        @(negedge clk);
        memory_write_enable = 0;

        $display("Memory initialization completed");

        // TEST 1: Request address 0x24
        cpu_address = 32'h00000024;
        lookup_valid = 1;

        $display("Requesting address 0x24");

        // Wait for memory block refill
        repeat (10) @(posedge clk);

        #1;

        if (hit === 1'b1)
            $display("TEST 1 PASSED: Cache refill completed");
        else
            $fatal(1, "TEST 1 FAILED: Cache refill unsuccessful");

        // TEST 2-5: Read all four words

        for (i = 0; i < 4; i = i + 1) begin

            cpu_address = 32'h00000020 + (i * 4);

            case (i)

                0: expected_data = 32'hAAAAAAAA;
                1: expected_data = 32'hBBBBBBBB;
                2: expected_data = 32'hCCCCCCCC;
                3: expected_data = 32'hDDDDDDDD;

                default: expected_data = 32'b0;

            endcase

            #1;

            if (hit === 1'b1 && read_data === expected_data) begin

                $display(
                    "TEST %0d PASSED: Address = %h, Data = %h",
                    i + 2,
                    cpu_address,
                    read_data
                );

            end

            else begin

                $fatal(
                    1,
                    "TEST %0d FAILED: Expected = %h, Got = %h",
                    i + 2,
                    expected_data,
                    read_data
                );

            end

        end

        // TEST 6: Verify that repeated access is a cache hit

        cpu_address = 32'h00000024;
        #1;

        if (hit === 1'b1 && miss === 1'b0)
            $display("TEST 6 PASSED: Repeated access produces CACHE HIT");
        else
            $fatal(1, "TEST 6 FAILED");

        $display("------------------------------------");
        $display("ALL MAIN MEMORY TESTS PASSED");
        $display("------------------------------------");

        $finish;

    end

endmodule
