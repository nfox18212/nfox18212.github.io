# Random Number Generation

The random number generation is done by taking in an initial seed from Timer 1.  Timer 1 is initialized to a very, very large value instead of a very small value.  The timer must be initialized to a large value, like 0xFFFFFFFE, because it'll increment down every clock cycle.  Once the timer value hits zero, it'll repeat and rollover.  So if you have a small timer period, this will mean that the number of possible values it will take is significantly decreased.  Hence using a large number.

On the first UART interrupt, the UART handler will stop Timer 1, freezing its value.  With this value now being static, we can effectively use it as a seed value.  It is then stored in the label "seeddata" to make accessing it easier.

When filling the board, only the last 6 bits are used as an index.  After the bitmask to grab the last 6 bits, the seed is randomized using a simple Xorshift algorithm.  Xorshift was chosen due to its simplicitly to implement in assembly.  The one difference was that instead of setting the new seed to the time it takes for the randomized version to become the original, the seed is just xorshifted with 7, 13, 5, and 9.  This is because this process happens 1000 times, and getting the new seed with the original process would take an unreasonable amount of time.

# Filling the Board

To fill the board, a new data structure was created: the color list.  The color list is an array of 54 colors terminated with a 0xFF byte.  In its original form, the color list represents a "solved" version of the rubiks cube.  So the first face is all color 1 (red), the second is all color 2 (green), and so on.  The initial state of the board is pulled directly from iterating through this array and using the cells array to sequentially set each cell to its corresponding entry in the color array.

So naturally, the next question is "how do we randomize the color list?".  This is achieved using the initial seed in seeddata, and masking the for the last 6 bits.  They act as the first index.  The first index is then rotated 29 bits, and checked to see if they are greater than 54 or not using the subroutine **reduce** - we don't want to go out-of-bounds.  Now we have two indices to act as offsets into the color array.  The contents are then swapped.  The seed is randommized using the xorshift algorithm.  This proccess repeats 1000 times.

# Subroutines
**seed**: 
Seed does not take in any arguments.  It implements the algorithm described above and is called from the main subroutine.  After 1000 iterations, the subroutine will call **fill_alist**.  

**fill_alist**:
Fill adjacency list does not take in any arguments.  It iterates through the cells array with a post-indexed load to ensure it gets each cell.  It also loads each color from the color array with a post indexed load.  It then will call [**set_color**](data/alist.md) using the given cell and color to put it into the adjacency list, which acts as the entire board. 

To ensure every cell is filled with a color, two things were implemented data-wise:
- 0 does not represent a color, but the absence of color.  Having it represent a color would be extremely confusing.
- 0xFF is used as a terminating byte instead of 0x00

The iteration will only stop once the 0xFF byte has been read.


