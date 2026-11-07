
`timescale 1ns/1ps

module cache_controller_tb;

    reg clk;
    reg reset;

    reg request_valid;
    reg [31:0] request_address;
    wire request_ready;

    wire response_valid;
    reg response_ready;
    wire [31:0] response_data;

    reg memory_write_enable;
    reg [31:0] memory_write_address;
    reg [31:0] memory_write_data;

    wire [2:0] controller_state;

    integer errors;

    // Instantiate complete cache system
    cache_top dut (
        .clk(clk),
        .reset(reset),

        .request_valid(request_valid),
        .request_address(request_address),
        .request_ready(request_ready),

        .response_valid(response_valid),
        .response_ready(response_ready),
        .response_data(response_data),

        .memory_write_enable(memory_write_enable),
        .memory_write_address(memory_write_address),
        .memory_write_data(memory_write_data),

        .controller_state(controller_state)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;


    // Initialize one main memory word
    task write_memory;
        input [31:0] address;
        input [31:0] data;
        begin
            @(negedge clk);
            memory_write_enable = 1;
            memory_write_address = address;
            memory_write_data = data;

            @(negedge clk);
            memory_write_enable = 0;
        end
    endtask


    // Send one CPU request and check its response
    task check_request;
        input [31:0] address;
        input [31:0] expected_data;
        input [255:0] test_name;

        integer cycles;

        begin

            // Wait until controller can accept request
            while (request_ready !== 1'b1)
                @(negedge clk);

            @(negedge clk);

            request_address = address;
            request_valid = 1;

            @(posedge clk);
            #1;
            request_valid = 0;

            // Wait for response with timeout
            cycles = 0;

            while (response_valid !== 1'b1 && cycles < 30) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
            end

            if (response_valid !== 1'b1) begin
                $display("FAIL: %0s - Timeout", test_name);
                errors = errors + 1;
            end

            else if (response_data !== expected_data) begin
                $display(
                    "FAIL: %0s - Expected %h, Got %h",
                    test_name,
                    expected_data,
                    response_data
                );
                errors = errors + 1;
            end

            else begin
                $display(
                    "PASS: %0s - Address=%h Data=%h",
                    test_name,
                    address,
                    response_data
                );
            end

            // Accept CPU response
            @(negedge clk);
            response_ready = 1;

            @(posedge clk);
            #1;
            response_ready = 0;

        end

    endtask


    initial begin

        // Waveform generation
        $dumpfile("cache_controller.vcd");
        $dumpvars(0, cache_controller_tb);

        clk = 0;
        reset = 1;

        request_valid = 0;
        request_address = 0;
        response_ready = 0;

        memory_write_enable = 0;
        memory_write_address = 0;
        memory_write_data = 0;

        errors = 0;

        $display("------------------------------------");
        $display("CACHE CONTROLLER FSM TEST");
        $display("------------------------------------");

        // Reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Initialize first memory block
        write_memory(32'h00000020, 32'hAAAAAAAA);
        write_memory(32'h00000024, 32'hBBBBBBBB);
        write_memory(32'h00000028, 32'hCCCCCCCC);
        write_memory(32'h0000002C, 32'hDDDDDDDD);

        $display("Main memory initialized");


        // TEST 1: First access causes MISS and REFILL
        check_request(
            32'h00000024,
            32'hBBBBBBBB,
            "First request: MISS and REFILL"
        );


        // TEST 2: Repeated request causes HIT
        check_request(
            32'h00000024,
            32'hBBBBBBBB,
            "Repeated request: CACHE HIT"
        );


        // TEST 3: Different word in same block
        check_request(
            32'h00000028,
            32'hCCCCCCCC,
            "Different word: CACHE HIT"
        );


        // TEST 4: Fourth word in same block
        check_request(
            32'h0000002C,
            32'hDDDDDDDD,
            "Fourth word: CACHE HIT"
        );


        $display("------------------------------------");

        if (errors == 0)
            $display("ALL CACHE CONTROLLER TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $display("------------------------------------");

        $finish;

    end

endmodule
