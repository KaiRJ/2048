class_name Square
extends Panel

signal occupied_signal

@export_range(0,50) var movement_weight: float = 15

@onready var occupied: bool = false
@onready var is_moving: bool = false

var end_position: Vector2


func _process(delta):
	if is_moving:
		self.position = self.position.lerp(end_position, delta*movement_weight)
		# Check whem movement finished
		if self.position.distance_squared_to(end_position) < 0.1:
			is_moving = false


func move(direction):
	end_position = direction
	is_moving = true


func _on_area_2d_area_entered(area):
	occupied = true
	occupied_signal.emit


func _on_area_2d_area_exited(area):
	occupied = false
