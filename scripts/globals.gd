extends Node


var viewport_height : int
var viewport_width: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size;
	viewport_height = viewport_size.y;
	viewport_width = viewport_size.x;
	
