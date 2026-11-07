
`timescale 1ns/1ps

module cache_tb;

    // -----------------------------------------
    // 1. Signals connected to cache_top
    // -----------------------------------------

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

    // -----------------------------------------
    // 2. Expected main memory model
    // -----------------------------------------

    reg [31:0] expected_memory [0:1023];

    integer i;

    // -----------------------------------------
    // 3. Counters and performance variables
    // -----------------------------------------

    integer total_accesses;
    integer total_hits;
    integer total_misses;
    integer total_errors;

    integer trace_hits;
    integer trace_misses;
    integer trace_accesses;
    integer trace_errors;

    integer hit_latency_total;
    integer miss_latency_total;

    integer hit_latency_count;
    integer miss_latency_count;

    real hit_rate;
    real miss_rate;
    real average_hit_latency;
    real average_miss_latency;
    real amat;

    // -----------------------------------------
    // 4. Instantiate complete cache system
    // -----------------------------------------

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

    // Clock period = 10 ns
    always #5 clk = ~clk;

    // -----------------------------------------
    // 5. Write one word into main memory
    // -----------------------------------------

    task write_memory;
        input [31:0] address;
        input [31:0] data;

        begin
            @(negedge clk);

            memory_write_enable = 1'b1;
            memory_write_address = address;
            memory_write_data = data;

            @(negedge clk);

            memory_write_enable = 1'b0;
        end
    endtask

    // -----------------------------------------
    // 6. Reset the cache before each experiment
    // -----------------------------------------

    task reset_cache;
        begin
            @(negedge clk);
            reset = 1'b1;

            request_valid = 1'b0;
            response_ready = 1'b0;

            repeat (2) @(posedge clk);

            @(negedge clk);
            reset = 1'b0;
        end
    endtask

    // -----------------------------------------
    // 7. Send one request and verify its response
    // -----------------------------------------

    task check_access;
        input [31:0] address;

        reg [31:0] expected_data;
        reg was_hit;

        integer cycles;

        begin

            expected_data = expected_memory[address[11:2]];
            was_hit = 1'b0;

            // Wait until cache controller is ready
            while (request_ready !== 1'b1)
                @(negedge clk);

            // Send CPU request
            @(negedge clk);

            request_address = address;
            request_valid = 1'b1;

            @(posedge clk);
            #1;

            request_valid = 1'b0;

            // Count only the FIRST lookup for this request.
            // A miss causes another lookup after refill.
            if (controller_state == 3'b001) begin

                if (dut.cache_hit === 1'b1) begin
                    was_hit = 1'b1;

                    total_hits = total_hits + 1;
                    trace_hits = trace_hits + 1;

                end

                else if (dut.cache_miss === 1'b1) begin
                    was_hit = 1'b0;

                    total_misses = total_misses + 1;
                    trace_misses = trace_misses + 1;

                end

                else begin
                    $display(
                        "ERROR: No valid hit/miss for address %h",
                        address
                    );

                    total_errors = total_errors + 1;
                    trace_errors = trace_errors + 1;
                end

            end

            else begin
                $display(
                    "ERROR: Controller did not enter LOOKUP for %h",
                    address
                );

                total_errors = total_errors + 1;
                trace_errors = trace_errors + 1;
            end

            // Wait for CPU response
            cycles = 0;

            while ((response_valid !== 1'b1) && (cycles < 100)) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
            end

            if (response_valid !== 1'b1) begin

                $display(
                    "FAIL: Timeout at address %h",
                    address
                );

                total_errors = total_errors + 1;
                trace_errors = trace_errors + 1;

            end

            else begin

                // Compare returned data with expected data
                if (response_data !== expected_data) begin

                    $display(
                        "FAIL: Address=%h Expected=%h Got=%h",
                        address,
                        expected_data,
                        response_data
                    );

                    total_errors = total_errors + 1;
                    trace_errors = trace_errors + 1;

                end

                else begin

                    $display(
                        "PASS: Address=%h Data=%h %s",
                        address,
                        response_data,
                        was_hit ? "HIT" : "MISS"
                    );

                end

                // Record latency in clock cycles
                if (was_hit) begin
                    hit_latency_total =
                        hit_latency_total + cycles;

                    hit_latency_count =
                        hit_latency_count + 1;
                end

                else begin
                    miss_latency_total =
                        miss_latency_total + cycles;

                    miss_latency_count =
                        miss_latency_count + 1;
                end

                // Accept the response
                @(negedge clk);
                response_ready = 1'b1;

                @(posedge clk);
                #1;

                response_ready = 1'b0;

            end

            total_accesses = total_accesses + 1;
            trace_accesses = trace_accesses + 1;

        end
    endtask

    // -----------------------------------------
    // 8. Read and execute a trace file
    // -----------------------------------------

    task run_trace;
        input [8*40:1] trace_name;

        integer file_handle;
        integer scan_result;

        reg [31:0] trace_address;

        begin

            $display("");
            $display("======================================");
            $display("RUNNING TRACE: %0s", trace_name);
            $display("======================================");

            // Start with an empty cache
            reset_cache;

            trace_hits = 0;
            trace_misses = 0;
            trace_accesses = 0;
            trace_errors = 0;

            file_handle = $fopen(trace_name, "r");

            if (file_handle == 0) begin

                $display("ERROR: Cannot open %0s", trace_name);

                total_errors = total_errors + 1;

            end

            else begin

                scan_result = $fscanf(
                    file_handle,
                    "%h",
                    trace_address
                );

                while (scan_result == 1) begin

                    check_access(trace_address);

                    scan_result = $fscanf(
                        file_handle,
                        "%h",
                        trace_address
                    );

                end

                $fclose(file_handle);

                $display("--------------------------------------");
                $display("Trace: %0s", trace_name);
                $display("Accesses : %0d", trace_accesses);
                $display("Hits     : %0d", trace_hits);
                $display("Misses   : %0d", trace_misses);
                $display("Errors   : %0d", trace_errors);
                $display("--------------------------------------");

            end

        end
    endtask

    // -----------------------------------------
    // 9. Main simulation
    // -----------------------------------------

    initial begin

        $dumpfile("cache_tb.vcd");
        $dumpvars(0, cache_tb);

        clk = 0;
        reset = 1;

        request_valid = 0;
        request_address = 0;
        response_ready = 0;

        memory_write_enable = 0;
        memory_write_address = 0;
        memory_write_data = 0;

        total_accesses = 0;
        total_hits = 0;
        total_misses = 0;
        total_errors = 0;

        hit_latency_total = 0;
        miss_latency_total = 0;

        hit_latency_count = 0;
        miss_latency_count = 0;

        trace_hits = 0;
        trace_misses = 0;
        trace_accesses = 0;
        trace_errors = 0;

        $display("");
        $display("**************************************");
        $display("       INTEGRATED CACHE TEST          ");
        $display("**************************************");

        // Initial reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Initialize all 1024 memory words.
        // The same values are stored in expected_memory
        // so the testbench can verify returned data.

        $display("");
        $display("Initializing main memory...");

        for (i = 0; i < 1024; i = i + 1) begin

            expected_memory[i] =
                32'h12340000 ^ (i * 32'h00000101);

            write_memory(
                i * 4,
                expected_memory[i]
            );

        end

        $display("Main memory initialization complete.");

        // -------------------------------------
        // Execute all four experiments
        // -------------------------------------

        run_trace("traces/sequential.txt");

        run_trace("traces/repeated.txt");

        run_trace("traces/random.txt");

        run_trace("traces/conflict.txt");

        // -------------------------------------
        // 10. Final performance calculations
        // -------------------------------------

        $display("");
        $display("**************************************");
        $display("       FINAL CACHE RESULTS            ");
        $display("**************************************");

        $display("Total accesses : %0d", total_accesses);
        $display("Total hits     : %0d", total_hits);
        $display("Total misses   : %0d", total_misses);
        $display("Total errors   : %0d", total_errors);

        if (total_accesses > 0) begin

            hit_rate =
                (100.0 * total_hits) / total_accesses;

            miss_rate =
                (100.0 * total_misses) / total_accesses;

            $display("Hit rate       : %0.2f%%", hit_rate);
            $display("Miss rate      : %0.2f%%", miss_rate);

        end

        if (hit_latency_count > 0)
            average_hit_latency =
                (1.0 * hit_latency_total) /
                hit_latency_count;
        else
            average_hit_latency = 0.0;

        if (miss_latency_count > 0)
            average_miss_latency =
                (1.0 * miss_latency_total) /
                miss_latency_count;
        else
            average_miss_latency = 0.0;

        $display(
            "Average hit latency  : %0.2f cycles",
            average_hit_latency
        );

        $display(
            "Average miss latency : %0.2f cycles",
            average_miss_latency
        );

        // AMAT = hit time + miss rate * miss penalty.
        // Here, miss penalty = miss latency - hit latency.
        if (total_accesses > 0) begin

            amat =
                average_hit_latency +
                (1.0 * total_misses / total_accesses) *
                (average_miss_latency - average_hit_latency);

            $display("Measured AMAT        : %0.2f cycles", amat);

        end

        $display("--------------------------------------");

        if (total_errors == 0)
            $display("ALL INTEGRATED CACHE TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", total_errors);

        $display("**************************************");

        $finish;

    end

endmodule
