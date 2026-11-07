
module cache_controller (
    input wire clk,
    input wire reset,

    // CPU request interface
    input wire request_valid,
    input wire [31:0] request_address,
    output wire request_ready,

    // CPU response interface
    output wire response_valid,
    input wire response_ready,
    output reg [31:0] response_data,

    // Cache lookup interface
    output wire lookup_valid,
    output reg [31:0] lookup_address,
    input wire cache_hit,
    input wire cache_miss,
    input wire [31:0] cache_read_data,

    // Memory refill interface
    output wire memory_request,
    output wire [31:0] memory_address,
    input wire fill_valid,

    // Debug: current FSM state
    output wire [2:0] current_state
);

    // FSM state definitions
    localparam IDLE     = 3'b000;
    localparam LOOKUP   = 3'b001;
    localparam MISS     = 3'b010;
    localparam REFILL   = 3'b011;
    localparam RESPONSE = 3'b100;

    reg [2:0] state;

    // Saved request address
    reg [31:0] saved_address;

    // State output for simulation
    assign current_state = state;

    // Request accepted only in IDLE
    assign request_ready = (state == IDLE);

    // Cache lookup is enabled only in LOOKUP
    assign lookup_valid = (state == LOOKUP);

    // Memory request is a one-cycle pulse in MISS
    assign memory_request = (state == MISS);

    // Use the saved address for both cache and memory
    assign memory_address = saved_address;

    // Response remains valid until CPU accepts it
    assign response_valid = (state == RESPONSE);

    // Sequential FSM
    always @(posedge clk) begin

        if (reset) begin

            state <= IDLE;
            saved_address <= 32'b0;
            lookup_address <= 32'b0;
            response_data <= 32'b0;

        end

        else begin

            case (state)

                // Wait for CPU request
                IDLE: begin

                    if (request_valid) begin

                        saved_address <= request_address;
                        lookup_address <= request_address;

                        state <= LOOKUP;

                    end

                end

                // Check cache
                LOOKUP: begin

                    if (cache_hit) begin

                        // Save data before leaving LOOKUP
                        response_data <= cache_read_data;

                        state <= RESPONSE;

                    end

                    else if (cache_miss) begin

                        state <= MISS;

                    end

                end

                // Trigger memory refill
                MISS: begin

                    // memory_request is high during this state
                    state <= REFILL;

                end

                // Wait until memory interface completes refill
                REFILL: begin

                    if (fill_valid) begin

                        // Cache captures the refill block
                        // on this same clock edge
                        state <= LOOKUP;

                    end

                end

                // Hold response until CPU accepts it
                RESPONSE: begin

                    if (response_ready) begin

                        state <= IDLE;

                    end

                end

                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule
