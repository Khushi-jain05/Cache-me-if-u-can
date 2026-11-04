# Address Mapping

| Address | Tag | Index | Offset | Word Index |
|---|---:|---:|---:|---:|
| 0x24 | 0 | 2 | 4 | 1 |
| 0x40 | 0 | 4 | 0 | 0 |
| 0x400 | 1 | 0 | 0 | 0 |
| 0x3C | 0 | 3 | 12 | 3 |

## Explanation

- Tag identifies the memory block.
- Index selects one of the 64 cache lines.
- Offset identifies the byte position within a cache block.
- Word Index selects one of the four 32-bit words in a block.

The address decoder extracts these fields using bit slicing.