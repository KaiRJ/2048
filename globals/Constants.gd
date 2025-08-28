extends Node


enum GameStates {WAIT_FOR_INPUT,
				 WAIT_ON_MOVING_SQUARES,
				 MERGE_SQUARES,
				 CHECK_FOR_WIN,
				 ADD_NEW_SQUARE,
			 	 WAIT_ON_NEW_SQUARE,
			 	 CHECK_IF_CAN_MOVE,
			 	 GAME_OVER}


const MoveMap = {
	"ui_right": [[3,2,1,0], [7,6,5,4], [11,10,9,8], [15,14,13,12]],
	"ui_left": [[0,1,2,3], [4,5,6,7], [8,9,10,11], [12,13,14,15]],
	"ui_up": [[0,4,8,12], [1,5,9,13], [2,6,10,14], [3,7,11,15]],
	"ui_down": [[12,8,4,0], [13,9,5,1], [14,10,6,2], [15,11,7,3]]
}

# Each array is the [square colour, font colour, font size]
const grey := Color(0.459, 0.392, 0.322)
const white := Color(1,1,1)
const black := Color(0,0,0)
const SquareColours = {
	"2"    : [Color(0.933, 0.894, 0.855), grey, 70],
	"4"    : [Color(0.922, 0.847, 0.714), grey, 70],
	"8"    : [Color(1, 0.718, 0.945), white, 70],
	"16"   : [Color(0.9, 0.5, 1), white, 70],
	"32"   : [Color(0.8, 0.1, 1), white, 70],
	"64"   : [Color(0.663, 0.529, 1), white, 70],
	"128"  : [Color(0.486, 0.294, 0.98), white, 70],
	"256"  : [Color(0.361, 0.118, 0.98), white, 70],
	"512"  : [Color(0.373, 0.89, 1), white, 70],
	"1024" : [Color(0.373, 1, 0.545), white, 60],
	"2048" : [Color(1, 0.914, 0.373), black, 60],
}
