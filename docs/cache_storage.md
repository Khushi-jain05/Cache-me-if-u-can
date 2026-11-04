# Cache Storage & Hit/Miss Detection

Module: `rtl/cache_storage.v`
Testbench: `tb/cache_storage_tb.v`

This module holds the cache contents and decides whether a requested address is in the cache. It detects misses but does not handle them: the controller (Member 4) decides what happens after a miss.

## 1. Cache Lines

The cache has 64 lines, numbered 0 to 63. Each line holds one 16-byte block, plus the tag and valid bit for that block.

| Field | Width | Purpose |
|---|---:|---|
| Tag | 22 bits | Identifies which memory block is in the line |
| Data | 128 bits | Four 32-bit words |
| Valid | 1 bit | 0 = empty, 1 = contains valid data |

## 2. Storage Arrays

```verilog
reg [127:0] data_array [0:63];
reg [21:0]  tag_array  [0:63];
reg         valid_array [0:63];
```

| Array | Total size |
|---|---:|
| `data_array` | 64 x 128 = 8192 bits |
| `tag_array` | 64 x 22 = 1408 bits |
| `valid_array` | 64 x 1 = 64 bits |

The same index selects the matching entry in all three arrays.

## 3. Tag Comparison

The index selects a line, and the tag stored in that line is compared with the requested tag:

```verilog
assign tag_match = (tag_array[lookup_index] == lookup_tag);
```

A matching tag alone is not enough. An empty line can hold a leftover or unknown tag, so the valid bit must also be 1.

## 4. Hit and Miss Conditions

```verilog
assign hit  = lookup_valid && valid_array[lookup_index] && tag_match;
assign miss = lookup_valid && !hit;
```

| `lookup_valid` | Line valid | Tag match | Result |
|:---:|:---:|:---:|---|
| 0 | any | any | No hit, no miss |
| 1 | 0 | any | Miss |
| 1 | 1 | 0 | Miss |
| 1 | 1 | 1 | Hit |

Example for address `0x24` (tag 0, index 2, word index 1): the module selects line 2, checks its valid bit, and compares its tag with 0. If both checks pass, it is a hit and word 1 of the line is returned.

## 5. Word Selection

On a hit, `word_index` selects one of the four words in the block. When there is no hit, `read_data` is 0.

| `word_index` | Word | Bits of the block |
|:---:|---|---|
| `00` | Word 0 | `[31:0]` |
| `01` | Word 1 | `[63:32]` |
| `10` | Word 2 | `[95:64]` |
| `11` | Word 3 | `[127:96]` |

## 6. Cache Refill

On a rising clock edge with `fill_valid` high, the module writes the block to line `fill_index`, stores `fill_tag`, and sets the valid bit:

```verilog
data_array[fill_index]  <= fill_block;
tag_array[fill_index]   <= fill_tag;
valid_array[fill_index] <= 1'b1;
```

Reset is synchronous and clears all 64 valid bits. It has priority over a refill. Data and tags are not cleared, because the valid bits already mark those lines as empty.

## 7. Interface With Other Modules

| Signal | Direction | Connected to |
|---|---|---|
| `lookup_tag`, `lookup_index`, `word_index` | Input | Member 1's address decoder |
| `lookup_valid` | Input | Member 4's controller |
| `hit`, `miss` | Output | Member 4's controller |
| `read_data` | Output | Member 4's response logic |
| `fill_block`, `fill_tag`, `fill_index` | Input | Member 3's memory interface |
| `fill_valid` | Input | Member 4's controller |

Integration rules:

- **Reset first.** Assert `reset` for at least one rising clock edge before the first lookup. Until then the valid bits are unknown, so `hit` and `miss` are not reliable.
- **Block packing.** `fill_block` must have word 0 in `[31:0]` through word 3 in `[127:96]`.
- **Timing.** Lookup is combinational and refill is clocked. Hold the lookup request stable until the refill completes, then check the cache again.
- **Read-only cache.** Write hits, dirty bits and write-back are not implemented.

## 8. Verification

Compile and run from the project root:

```
iverilog -g2012 -Wall -s cache_storage_tb -o cache_sim rtl/cache_storage.v tb/cache_storage_tb.v
vvp cache_sim
```

| Test | Scenario | Expected result |
|---:|---|---|
| 1 | Lookup in an empty cache | Miss |
| 2 | Refill line 2 | Block is written (confirmed by tests 3 to 6) |
| 3 | Same tag and index, word 0 | Hit, returns `AAAAAAAA` |
| 4 | Word 1 | Returns `BBBBBBBB` |
| 5 | Word 2 | Returns `CCCCCCCC` |
| 6 | Word 3 | Returns `DDDDDDDD` |
| 7 | Different tag, same index | Miss |
| 8 | Lookup in another empty line | Miss |
| 9 | `lookup_valid` low | No hit, no miss |

All nine tests passed with Icarus Verilog 13.0. The simulation output is in `reports/cache_storage_test.png`.
