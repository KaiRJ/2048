extends Node

@export var square_scene: PackedScene


func _ready():

	add_square_to_grid()


func add_square_to_grid():
	var square = square_scene.instantiate()

	# TODO: get random panel
	var panel = $Grid/PanelContainer/MarginContainer/GridContainer/Panel5

	# Layouts update at end of frame, so call update_square_position on next frame.
	call_deferred("update_square_position", square, panel)

	$Grid/Squares.add_child(square)


func update_square_position(square, panel):
	square.global_position = panel.global_position
