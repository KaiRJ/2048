extends Panel

var move_amount: int = 155


func _process(delta):
	if Input.is_action_just_released("ui_right"):
		self.position = self.position + Vector2(move_amount,0)
	elif Input.is_action_just_released("ui_left"):
		self.position = self.position + Vector2(-move_amount,0)
	elif Input.is_action_just_released("ui_up"):
		self.position = self.position + Vector2(0, -move_amount)
	elif Input.is_action_just_released("ui_down"):
		self.position = self.position + Vector2(0, move_amount)
