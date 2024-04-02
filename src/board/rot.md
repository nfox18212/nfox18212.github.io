# Rotation

Rotation is implemented by taking the face matrix from memory and doing one or more transposes into row-reflections, which will rotate it by 90 degrees.  This was used to build the [adjacency list](../data/alist.md).  The player's orientation is stored in memory as a value from 0-3, representing the number of 90 degree counter clockwise turns the character has taken relative to the absolute North of Face 1.

Two lookup tables will be used to store rotation information.  The Face-Rotation table will take the current Face Number and tells you how the player's orientation will change when they move to a different face.  For example, moving East from Face 6 to Face 2 will cause the Player's orientation value to become 2.  This means compared to Absolute North of Face 1, we need to rotate the matrix containing Face 2 by 180 degrees.  This is achieved by composing two consecutive 90 degree rotations, or transpose -> row reflection -> transpose -> row reflection.  

The other lookup table will translate the player's input of wasd into cardinal directions, again based on the player's orientation.  For example, if the player has a orientation value of 1 and moves up, that is a movement East.

The full table can be found [here](https://docs.google.com/spreadsheets/d/1lIbhq9RJiK44gera0EY-gOZbGEYBQ-LJChw7v7JewIk/edit?usp=sharing).