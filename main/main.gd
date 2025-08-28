extends Node

@export var square_scene: PackedScene
@export var end_scene: PackedScene

const win_total = 2048

var rng = RandomNumberGenerator.new()
var state: Constants.GameStates
var newest_player_square: Square


func _ready():
	state = Constants.GameStates.ADD_NEW_SQUARE


func _process(_delta):
	match state:
		Constants.GameStates.CHECK_IF_CAN_MOVE:
			if check_if_can_move():
				state = Constants.GameStates.WAIT_FOR_INPUT
			else:
				show_end_scene("Game Over!")
		
		Constants.GameStates.WAIT_FOR_INPUT:
			var move_order: Array = get_player_input()
			if move_squares_in_grid(move_order):
				state = Constants.GameStates.WAIT_ON_MOVING_SQUARES

		Constants.GameStates.WAIT_ON_MOVING_SQUARES:
			if not player_squares_are_moving():
				state = Constants.GameStates.MERGE_SQUARES
				
		Constants.GameStates.MERGE_SQUARES:
			get_tree().call_group("KillSquares", "queue_free")
			for square in get_tree().get_nodes_in_group("DoubleSquares"):
				square.double_number()
				square.remove_from_group("DoubleSquares")
			state = Constants.GameStates.CHECK_FOR_WIN
			
		Constants.GameStates.CHECK_FOR_WIN:
			for square in $%PlayerSquares.get_children():
				if (square.number >= win_total):
					show_end_scene("You win!")
					
			if state != Constants.GameStates.GAME_OVER:
				state = Constants.GameStates.ADD_NEW_SQUARE
		
		Constants.GameStates.ADD_NEW_SQUARE:
			newest_player_square = add_square_to_grid()
			state = Constants.GameStates.WAIT_ON_NEW_SQUARE

		Constants.GameStates.WAIT_ON_NEW_SQUARE:
			# Area entered isnt updated immediatly
			if newest_player_square.is_overlapping():
				state = Constants.GameStates.CHECK_IF_CAN_MOVE


func check_if_can_move() -> bool:
	"Return true if there is a move available."
	for direction in Constants.MoveMap:
		if move_squares_in_grid(Constants.MoveMap[direction], false):
			return true

	return false
	
func show_end_scene(text) -> void:
	var end_scene_instance = end_scene.instantiate()
	end_scene_instance.set_label(text)
	get_tree().current_scene.add_child(end_scene_instance)
	state = Constants.GameStates.GAME_OVER


func get_player_input() -> Array:
	"Get the player input and return the square move order"
	var square_move_order: Array = [[]]
	for action in Constants.MoveMap.keys():
		if Input.is_action_just_pressed(action):
			square_move_order = Constants.MoveMap[action]
			break

	return square_move_order


func move_squares_in_grid(move_order: Array, do_moves:= true) -> bool:
	"Move all the squares using MOVE_ORDER and return true if a square was moved.
	Only do the moving if DO_MOVES is true."
	var square_moved: bool = false
	for line in move_order:
		if move_squares_in_line(line, do_moves):
			square_moved = true

	return square_moved


func move_squares_in_line(line_order: Array, do_moves:= true) -> bool:
	"Helping function for move_squares_in_grid, moves squares in a specifed line.
	Return true if a square was moved."
	var square_moved: bool = false
	var free_squares: Array[Square] = []
	var previous_player_square: Square = null
	var previous_player_square_position: Vector2 # global position doesn't update immediaty so need to track this
	var already_merged := false
	for i in line_order:
		var grid_square: Square = $%GridContainer.get_children()[i]
		
		# check if the current grid square is free
		if not grid_square.is_overlapping():
			free_squares.append(grid_square)
			continue
		var current_player_square: Square = grid_square.get_node("Area2D").get_overlapping_areas()[0].get_parent()
		
		# check if can merge with previous square
		if previous_player_square \
		   and not already_merged \
		   and (current_player_square.number == previous_player_square.number):
			free_squares.append(grid_square) # this square is now free
			square_moved = true
			already_merged = true
			if do_moves:
				current_player_square.add_to_group("KillSquares")
				previous_player_square.add_to_group("DoubleSquares")
				current_player_square.move(previous_player_square_position)
				continue
		previous_player_square = current_player_square
		previous_player_square_position = current_player_square.global_position
		
		# check if there is a free square to move into
		var free_square: Square = free_squares.pop_front()
		if free_square:
			previous_player_square_position = free_square.global_position
			free_squares.append(grid_square) # this square is now free
			square_moved = true
			if do_moves:
				current_player_square.move(free_square.global_position)

	return square_moved


func player_squares_are_moving() -> bool:
	"Check if any of the player squares are moving."
	for square: Square in get_tree().get_nodes_in_group("player_squares"):
		if square.is_moving:
			return true

	return false


func add_square_to_grid() -> Square:
	# Get all the free squares in the grid
	var free_squares: Array[Square] = []
	for square: Square in $%GridContainer.get_children():
		if not square.is_overlapping():
			free_squares.append(square)

	if free_squares.is_empty():
		state = Constants.GameStates.CHECK_IF_CAN_MOVE
		return
	
	# Add new square to scene
	var random_free_square: Square = free_squares.pick_random()
	var new_player_square: Square = square_scene.instantiate()
	
	# Pick a random starting number
	var numbers = [2, 4, 8]
	var weights = PackedFloat32Array([1, 0.2, 0.01])
	var random_number = numbers[rng.rand_weighted(weights)]
	new_player_square.set_number(random_number)
	
	# Set position and add to group
	new_player_square.global_position = random_free_square.global_position
	new_player_square.add_to_group("player_squares")
	$%PlayerSquares.add_child(new_player_square)
	
	return new_player_square
