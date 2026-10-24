# Closed-book verification: RapidWright row-overhead frames

**Do not use the network, GitHub, or any external fetch.** RapidWright's
`bitstream` package is closed-source; the open-source repo does not contain
`ConfigArray.java` or `Block.java`. All the evidence you need is in this
directory. Answer from the included javadoc excerpts and the recorded API
outputs, and label anything that is inference.

## Observed facts

485T bitstream: **50,176 frames**.

Block-only traversal:

```java
ConfigArray ca = new ConfigArray(Device.getDevice("xc7vx485t"));
for (ConfigRow row : ca.getConfigRows())
  for (Block block : row.getBlocks())
    for (Frame frame : block.getFrames())
      count++;
```

Recorded output:

```text
rows=14 blocks=1183 block_frames=50148
overhead_per_row=2
with_overhead=50176
word_size=5067776
```

Every row: 15 blocks, 1,920 block frames.

Insertion test (`OverheadSeq.java`), adding
`ConfigArray.FRAME_OVERHEAD_COUNT_PER_ROW` after each row:

```text
rows=14 total_with_overhead=50176
idx380=31716 idx3a0=31748 idx314=-1
```

The target block is `CLBLM_R_X7Y10`, block address `0x420380`; its frame 32 is
`0x4203A0`. The M3 bitstream anchor is frame 31748.

## Official javadoc excerpts

`ConfigArray` — <http://www.rapidwright.io/javadoc/com/xilinx/rapidwright/bitstream/ConfigArray.html>:

- `public static final int FRAME_OVERHEAD_COUNT_PER_ROW`
  - "The number of extra frames at the end of a configuration row"
  - Since 2021.2.2.
- `getConfigRows()`: "Gets the rows in the config array (in config order)".
- `getConfigBlock(Tile)`: "Get the configuration block that corresponds to the
  provided tile. The block type is assumed to be CLB."
- `getConfigBlock(Tile, BlockType)`: "Valid block types are CLB and
  BRAM_CONTENT".
- `getFrame(FAR)`: "Gets the frame in SLR0 (or monolithic devices) by default at
  the frame address register specified."
- `getWordSize()`: "Gets the total number of words in the config array."
- `getPackets()`: "Creates the list of packets that correspond to the current
  state of this configuration array."

`Block` — <http://www.rapidwright.io/javadoc/com/xilinx/rapidwright/bitstream/Block.html>:

- `getFrames()`: "Gets the array of frames corresponding to this block."
- `getFrameCount()`: "Gets the number of frames in this configuration block."
- `getFrame(int index)`: "Gets the frame within the block at the specified
  offset."
- The javadoc repeatedly says `getFrames()`/`getFrameCount()` **requires that
  the subtype of the block be set on the block beforehand**.

## Questions

1. Is `50,176 - 50,148 = 28` exactly `rows (14) * FRAME_OVERHEAD_COUNT_PER_ROW
   (2)`? Does the javadoc description support that reading?
2. Are the 28 overhead frames attached to any `Block` or `ConfigRow` in the
   public API? If not, can `Block.getFrames()` ever return them?
3. Does the insertion test prove the rule "after all blocks of a row, before
   the next row"? Does `idx3a0=31748` match the M3 anchor?
4. Which rows are before the target block? Does 6 rows * 2 overhead = 12
   explain the earlier +12 shift from 31,736 to 31,748?
5. What can and cannot be exported: overhead frame objects, overhead FAR, tile
   association, null/unconfigured frame contents, block types beyond
   CLB/BRAM_CONTENT?
6. Is `word_size=5,067,776` consistent with `50,176 * 101`? If yes, does that
   show `ConfigArray` accounts for overhead in total size but not as `Frame`
   objects?
7. What is the correct `frame_index -> FAR` construction for Phase A: insert
   two overhead frames per row and increment FAR by 1 for each, or is there a
   documented API that returns them? If the latter is not documented, say so.

End with exactly one of:

```text
VERDICT: CONFIRMED
VERDICT: PARTIAL
VERDICT: REJECTED
```
