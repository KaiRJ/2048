class_name Square
extends Control

const animation_time := 0.2
const movement_weight := 25.0

var is_moving := false
var number := 0
var end_position: Vector2


func _process(delta):
	if is_moving:
		self.position = self.position.lerp(end_position, delta*movement_weight)
		# Check when movement finished
		if self.position.distance_squared_to(end_position) < 0.1:
			is_moving = false


func move(direction):
	end_position = direction
	is_moving = true


func set_number(val: int):
	var counts_per_s = animation_time / (val - self.number)
	$IncrementTimer.wait_time = counts_per_s
	self.number = val
	
	var number_characteristics = Constants.SquareColours[str(number)]
	var sb = $Panel.get_theme_stylebox("panel").duplicate()
	sb.bg_color = number_characteristics[0]
	$Panel.add_theme_stylebox_override("panel", sb)
	
	$Label.add_theme_color_override("font_color", number_characteristics[1])
	$Label.add_theme_font_size_override("font_size", number_characteristics[2])
	
	$AnimationPlayer.play("set_number")


func double_number():
	set_number(2*number)
	self.remove_from_group("DoubleNumber")
	


func is_overlapping() -> bool:
	return $Area2D.get_overlapping_areas().size() > 0
	

func _on_increment_timer_timeout() -> void:
	var current_val = int($Label.text)
	
	var increment := 1
	if (self.number - current_val) / 500 > 0:
		increment = 100
	if (self.number - current_val) / 100 > 0:
		increment = 50
	
	if current_val < self.number:
		$Label.text = str(current_val + increment)
