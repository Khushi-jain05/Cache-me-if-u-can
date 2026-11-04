
module address_decoder (

    // Input: 32-bit memory address
    input wire [31:0] address,

    // Outputs: decoded address fields
    output wire [21:0] tag,
    output wire [5:0] index,
    output wire [3:0] offset,
    output wire [1:0] word_index

);

    // Extract the tag (bits 31 to 10)
    assign tag = address[31:10];

    // Extract the cache line index (bits 9 to 4)
    assign index = address[9:4];

    // Extract the block offset (bits 3 to 0)
    assign offset = address[3:0];

    // Extract the word index (bits 3 to 2)
    assign word_index = address[3:2];

endmodule;