
`timescale 1ns/1ps

module address_decoder_tb;

    reg [31:0] address;

    wire [21:0] tag;
    wire [5:0] index;
    wire [3:0] offset;
    wire [1:0] word_index;

    // Connect the decoder module
    address_decoder dut (
        .address(address),
        .tag(tag),
        .index(index),
        .offset(offset),
        .word_index(word_index)
    );

    initial begin

        $display("Starting Address Decoder Tests");

        // Test 1
        address = 32'h00000024;
        #10;
        if (tag == 0 && index == 2 &&
            offset == 4 && word_index == 1)
            $display("TEST 1 PASSED");
        else
            $fatal(1, "TEST 1 FAILED");

        // Test 2
        address = 32'h00000040;
        #10;
        if (tag == 0 && index == 4 &&
            offset == 0 && word_index == 0)
            $display("TEST 2 PASSED");
        else
            $fatal(1, "TEST 2 FAILED");

        // Test 3
        address = 32'h00000400;
        #10;
        if (tag == 1 && index == 0 &&
            offset == 0 && word_index == 0)
            $display("TEST 3 PASSED");
        else
            $fatal(1, "TEST 3 FAILED");

        // Test 4
        address = 32'h0000003C;
        #10;
        if (tag == 0 && index == 3 &&
            offset == 12 && word_index == 3)
            $display("TEST 4 PASSED");
        else
            $fatal(1, "TEST 4 FAILED");

        $display("ALL TESTS COMPLETED SUCCESSFULLY");

        $finish;

    end

endmodule;