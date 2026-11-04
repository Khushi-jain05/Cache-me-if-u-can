# Direct-Mapped Cache Architecture

## 1. Cache Configuration

- Cache Size: 1 KB (1024 bytes)
- Block Size: 16 bytes
- Number of Cache Lines: 64
- Address Width: 32 bits
- Word Size: 32 bits
- Words per Block: 4

## 2. Address Format

The 32-bit memory address is divided into three main fields:

- Tag: 22 bits (Address[31:10])
- Index: 6 bits (Address[9:4])
- Offset: 4 bits (Address[3:0])

The word index is extracted from Address[3:2].

## 3. Address Decoder

The address decoder extracts the tag, index, offset, and word index from the input address.

It uses combinational logic and does not require a clock signal.

## 4. Cache Mapping

The index selects one of the 64 cache lines. The tag identifies which memory block is stored in that line. The offset selects the location within the 16-byte block.

## 5. Address Decoder Verification

The decoder was tested using four test cases:

- Address 0x24
- Address 0x40
- Address 0x400
- Address 0x3C

All four test cases passed successfully.