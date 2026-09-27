class_name LevelSelectButton
extends Button

@export var level_path : String;

func _pressed() -> void:
	get_tree().change_scene_to_file(level_path);
