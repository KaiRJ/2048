extends Control

func set_label(text):
	$%Label.text = text


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
