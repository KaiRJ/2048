extends Node

@export var square_scene: PackedScene

var grid_squares: Array[Node]


func _ready():
	grid_squares = $Grid/PanelContainer/MarginContainer/GridContainer.get_children()

	add_square_to_grid()


func _process(delta):
	if Input.is_action_just_released("ui_right") \
	or Input.is_action_just_released("ui_left") \
	or Input.is_action_just_released("ui_up") \
	or Input.is_action_just_released("ui_down"):
		add_square_to_grid()


func add_square_to_grid():
	var new_square = square_scene.instantiate()

	var grid_square = get_random_grid_square()
	# TODO: this check should actually be after the square is added and check if
	# the player can make a move. atm this just stops an error
	if grid_square == null:
		print("Game over")
		return

	# Layouts update at end of frame, so call update_square_position on next frame.
	call_deferred("update_square", new_square, grid_square)
	$Grid/Squares.add_child(new_square)


func get_random_grid_square():
	var available_grid_squares: Array[Square] = get_free_grid_squares()

	if len(available_grid_squares) == 0:
		return null

	var random_i = randi() % len(available_grid_squares)
	return available_grid_squares[random_i]


func get_free_grid_squares():
	var available_grid_squares: Array[Square] = []
	for grid_square: Square in grid_squares:
		if not grid_square.occupied:
			available_grid_squares.append(grid_square)

	return available_grid_squares


func update_square(square, panel):
	# TODO: update name of function
	square.global_position = panel.global_position
	square.move_amount = (grid_squares[1].position.x - grid_squares[0].position.x)

	# Update colour of square
	var sb = square.get_theme_stylebox("panel").duplicate()
	sb.bg_color = Color(0.8, 0.2, 0.2, 1)
	square.add_theme_stylebox_override("panel", sb)

	# Update label of square
	square.get_node("Label").text = "2"
