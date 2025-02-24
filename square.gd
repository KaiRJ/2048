class_name Square
extends Panel

var occupied: bool = false
var move_amount: int


func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		self.position = self.position + Vector2(move_amount,0)
	elif Input.is_action_just_pressed("ui_left"):
		self.position = self.position + Vector2(-move_amount,0)
	elif Input.is_action_just_pressed("ui_up"):
		self.position = self.position + Vector2(0, -move_amount)
	elif Input.is_action_just_pressed("ui_down"):
		self.position = self.position + Vector2(0, move_amount)


func set_move_amount(x):
	move_amount = x


func _on_area_2d_area_entered(area):
	occupied = true


func _on_area_2d_area_exited(area):
	occupied = false
