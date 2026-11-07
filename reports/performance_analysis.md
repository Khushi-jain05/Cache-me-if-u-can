# Cache Performance Analysis

## 1. Objective

The objective of this experiment is to verify the integrated
direct-mapped cache and evaluate its performance using four
different memory-access patterns.

## 2. Cache Configuration

- Address width: 32 bits
- Number of cache lines: 64
- Block size: 16 bytes
- Words per block: 4
- Mapping technique: Direct mapped
- Tag: 22 bits
- Index: 6 bits
- Block offset: 4 bits

## 3. Simulation Results

| Access Pattern | Accesses | Hits | Misses | Errors |
|---|---:|---:|---:|---:|
| Sequential | 12 | 9 | 3 | 0 |
| Repeated | 9 | 8 | 1 | 0 |
| Random | 12 | 2 | 10 | 0 |
| Conflict | 9 | 0 | 9 | 0 |
| Total | 42 | 19 | 23 | 0 |

## 4. Performance Calculations

Total accesses = 42

Total hits = 19

Total misses = 23

Hit rate = Hits / Total accesses

Hit rate = 19 / 42 = 45.24%

Miss rate = Misses / Total accesses

Miss rate = 23 / 42 = 54.76%

Average hit latency = 1 cycle

Average miss latency = 8 cycles

Miss penalty = 8 - 1 = 7 cycles

AMAT = Hit time + (Miss rate x Miss penalty)

AMAT = 1 + (23 / 42 x 7)

AMAT = 4.83 cycles

## 5. Analysis of Access Patterns

### Sequential Access

Sequential accesses benefit from spatial locality.
Fetching a 16-byte block brings four consecutive words
into the cache. This reduces subsequent misses.

### Repeated Access

Repeated accesses benefit from temporal locality.
After the initial miss, subsequent accesses to the same
cache block are served as hits.

### Random Access

Random accesses use a varied, fixed address sequence.
The limited reuse of cache blocks results in more misses.

### Conflict Access

Addresses 0x020, 0x420 and 0x820 map to the same cache
index but have different tags.

They continuously replace one another, resulting in
conflict misses.

## 6. Verification Conclusion

The integrated cache successfully processed all 42
memory accesses.

All returned data values matched the expected main
memory values. No data verification errors were reported.

All four simulation traces completed successfully.

## 7. Overall Performance Summary

- Total accesses: 42
- Total hits: 19
- Total misses: 23
- Hit rate: 45.24%
- Miss rate: 54.76%
- Average hit latency: 1 cycle
- Average miss latency: 8 cycles
- Measured AMAT: 4.83 cycles

