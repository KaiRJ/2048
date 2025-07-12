extends Node

enum States {WAIT_FOR_INPUT,
			 WAIT_ON_MOVING_SQUARES,
			 ADD_NEW_SQUARE,
			 WAIT_ON_NEW_SQUARE,
			 CHECK_IF_CAN_MOVE,
			 GAME_OVER}

@export var square_scene: PackedScene

@onready var grid_squares: Array[Node] = $Grid/PanelContainer/MarginContainer/GridContainer.get_children()
@onready var state: States = States.WAIT_FOR_INPUT

const input_map = {
	"ui_right": [[3,2,1,0], [7,6,5,4], [11,10,9,8], [15,14,13,12]],
	"ui_left": [[0,1,2,3], [4,5,6,7], [8,9,10,11], [12,13,14,15]],
	"ui_up": [[0,4,8,12], [1,5,9,13], [2,6,10,14], [3,7,11,15]],
	"ui_down": [[12,8,4,0], [13,9,5,1], [14,10,6,2], [15,11,7,3]]
}

var latest_square: Square


func _ready():
	call_deferred("add_square_to_grid")


func _process(delta):
	if state == States.WAIT_FOR_INPUT:
		var move_order: Array = get_player_input()
		if move_squares_in_grid(move_order):
			state = States.WAIT_ON_MOVING_SQUARES
		else:
			state = States.WAIT_FOR_INPUT

	if state == States.WAIT_ON_MOVING_SQUARES:
		if not player_squares_are_moving():
			state = States.ADD_NEW_SQUARE

	if state == States.ADD_NEW_SQUARE:
		call_deferred("add_square_to_grid")
		# State is updated in the deferred function to ensure the square has
		# been added before moving on

	if state == States.WAIT_ON_NEW_SQUARE:
		# Area entered isnt updated immediatly
		if latest_square.occupied == true:
			state = States.CHECK_IF_CAN_MOVE

	if state == States.CHECK_IF_CAN_MOVE:
		if check_if_can_move():
			state = States.WAIT_FOR_INPUT
		else:
			print("Game Over")
			state = States.GAME_OVER

	if state == States.GAME_OVER:
		pass


func get_player_input() -> Array:
	var order: Array = [[]]
	for action in input_map.keys():
		if Input.is_action_just_pressed(action):
			order = input_map[action]
			break

	return order


func move_squares_in_grid(grid: Array, do_moves: bool = true) -> bool:
	"Return true if a square was moved, false if no squares moved"
	var square_moved: bool = false
	for line: Array in grid:
		if move_squares_in_line(line, do_moves):
			square_moved = true

	return square_moved


func move_squares_in_line(line: Array, do_moves: bool = true) -> bool:
	"Return true if a square was moved, false if no squares moved"
	var square_moved: bool = false # tracks if any squares were moved
	var line_squares: Array[Square] = []
	for i in line:
		var grid_square: Square = grid_squares[i]
		if not grid_square.occupied: # add this square to the free squares if its free
			line.append(grid_square)
		else:
			var player_square : Square = grid_square.get_node("Area2D").get_overlapping_areas()[0].get_parent()
			var free_grid_postion = free_grid_squares.pop_front().global_position
			if do_moves:
				player_square.move(free_grid_postion)
			free_grid_squares.append(grid_square) # this square is now free
			square_moved = true
		else:
			line.append(grid_square)

	return square_moved


func player_squares_are_moving() -> bool:
	for square: Square in get_tree().get_nodes_in_group("player_squares"):
		if square.is_moving:
			return true

	return false


func add_square_to_grid() -> void:
	# Get all the free squares in the grid
	var free_squares: Array
	for square: Square in grid_squares:
		if not square.occupied:
			free_squares.append(square)

	if free_squares.is_empty():
		state = States.CHECK_IF_CAN_MOVE
		return

	var random_free_square: Square = free_squares.pick_random()
	var new_square: Square = square_scene.instantiate()

	# Update the new squares properties
	new_square.add_to_group("player_squares")
	new_square.global_position = random_free_square.global_position
	new_square.get_node("Label").text = "2"

	# Update the color
	# TODO the colour should be stored in an array
	var sb = new_square.get_theme_stylebox("panel").duplicate()
	sb.bg_color = Color(0.8, 0.2, 0.2, 1)
	new_square.add_theme_stylebox_override("panel", sb)

	# Add to game
	$Grid/PlayerSquares.add_child(new_square)

	latest_square = new_square
	state = States.WAIT_ON_NEW_SQUARE


func check_if_can_move() -> bool:
	state = States.GAME_OVER
	for direction in input_map:
		if move_squares_in_grid(input_map[direction], false):
			#state = States.WAIT_FOR_INPUT
			return true

	return false
