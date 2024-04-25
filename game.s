	.cdecls C,NOLIST,"debug.h"


	.data

winstr:		.string 	"Congratulations!  You have filled all six sides of the cube and have won!  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0
losestr:	.string 	"Unfortunate!  You ran out of time before you filled all six sides of the cube.  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0

	.text
	.global end_game
	.global read_string

end_game:

	; put dancing LEDs logic here and determine cause of ending the game
