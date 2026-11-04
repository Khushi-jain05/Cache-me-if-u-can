
`timescale 1ns/1ps

module cache_storage_tb;

    reg clk;
    reg reset;

    reg lookup_valid;
    reg [21:0] lookup_tag;
    reg [5:0] lookup_index;
    reg [1:0] word_index;

    wire hit;
    wire miss;
    wire [31:0] read_data;

    reg fill_valid;
    reg [21:0] fill_tag;
    reg [5:0] fill_index;
    reg [127:0] fill_block;

    // Instantiate cache storage
    cache_storage dut (
        .clk(clk),
        .reset(reset),

        .lookup_valid(lookup_valid),
        .lookup_tag(lookup_tag),
        .lookup_index(lookup_index),
        .word_index(word_index),

        .hit(hit),
        .miss(miss),
        .read_data(read_data),

        .fill_valid(fill_valid),
        .fill_tag(fill_tag),
        .fill_index(fill_index),
        .fill_block(fill_block)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        lookup_valid = 0;
        lookup_tag = 0;
        lookup_index = 0;
        word_index = 0;

        fill_valid = 0;
        fill_tag = 0;
        fill_index = 0;
        fill_block = 0;

        $display("--------------------------------");
        $display("STARTING CACHE STORAGE TESTS");
        $display("--------------------------------");

        // Reset cache
        @(posedge clk);
        #1;
        reset = 0;

        // TEST 1: Empty cache should produce MISS
        lookup_valid = 1;
        lookup_tag = 22'd0;
        lookup_index = 6'd2;
        word_index = 2'd0;

        #1;

        if (miss === 1'b1)
            $display("TEST 1 PASSED: Empty cache gives MISS");
        else
            $fatal(1, "TEST 1 FAILED");

        // TEST 2: Fill cache line 2
        @(negedge clk);

        fill_valid = 1;
        fill_tag = 22'd0;
        fill_index = 6'd2;

        // Word 0 = AAAAAAAA
        // Word 1 = BBBBBBBB
        // Word 2 = CCCCCCCC
        // Word 3 = DDDDDDDD
        fill_block = {
            32'hDDDDDDDD,
            32'hCCCCCCCC,
            32'hBBBBBBBB,
            32'hAAAAAAAA
        };

        @(posedge clk);
        #1;

        fill_valid = 0;

        $display("TEST 2 PASSED: Cache line refilled");

        // TEST 3: Same tag and index should produce HIT
        lookup_tag = 22'd0;
        lookup_index = 6'd2;
        word_index = 2'd0;

        #1;

        if (hit === 1'b1 && read_data === 32'hAAAAAAAA)
            $display("TEST 3 PASSED: Cache HIT detected");
        else
            $fatal(1, "TEST 3 FAILED");

        // TEST 4: Read word 1
        word_index = 2'd1;
        #1;

        if (read_data === 32'hBBBBBBBB)
            $display("TEST 4 PASSED: Correct word 1 returned");
        else
            $fatal(1, "TEST 4 FAILED: Wrong word 1");

        // TEST 5: Read word 2
        word_index = 2'd2;
        #1;

        if (read_data === 32'hCCCCCCCC)
            $display("TEST 5 PASSED: Correct word 2 returned");
        else
            $fatal(1, "TEST 5 FAILED: Wrong word 2");

        // TEST 6: Read word 3
        word_index = 2'd3;
        #1;

        if (read_data === 32'hDDDDDDDD)
            $display("TEST 6 PASSED: Correct word 3 returned");
        else
            $fatal(1, "TEST 6 FAILED: Wrong word 3");

        // TEST 7: Different tag, same index should MISS
        lookup_tag = 22'd1;
        word_index = 2'd0;

        #1;

        if (miss === 1'b1)
            $display("TEST 7 PASSED: Tag mismatch gives MISS");
        else
            $fatal(1, "TEST 7 FAILED");

        // TEST 8: Another empty cache line should MISS
        lookup_tag = 22'd0;
        lookup_index = 6'd5;

        #1;

        if (miss === 1'b1)
            $display("TEST 8 PASSED: Invalid line gives MISS");
        else
            $fatal(1, "TEST 8 FAILED");

        // TEST 9: Disable lookup
        lookup_valid = 0;
        #1;

        if (hit === 1'b0 && miss === 1'b0)
            $display("TEST 9 PASSED: No lookup, no hit or miss");
        else
            $fatal(1, "TEST 9 FAILED");

        $display("--------------------------------");
        $display("ALL CACHE STORAGE TESTS PASSED");
        $display("--------------------------------");

        $finish;

    end

endmodule
