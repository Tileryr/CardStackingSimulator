extends Node2D

@export var speed_label: Label
@export var speed = 0.0;

var wind_ray_count : int = 100;
var wind_rays : Array[RayCast2D];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = DisplayServer.screen_get_size();
	for i in range(wind_ray_count):
		var ray = RayCast2D.new();
		ray.position.y = screen_size.y/wind_ray_count * i;
		ray.position.x = 0;
		ray.target_position = Vector2(screen_size.x, 0);
		wind_rays.append(ray);
		add_child(ray);
	
func apply_wind():
	for ray in wind_rays:
		var first_collider : Card = ray.get_collider();
		if first_collider:
			first_collider.apply_impulse(Vector2(speed, 0));

func _input(event: InputEvent) -> void:
	pass
	#if event.is_action("ui_up"):
		#speed += 0.1;
	#if event.is_action("ui_down"):
		#speed -= 0.1;

func _on_timeout() -> void:
	apply_wind();

func _process(delta: float) -> void:
	speed_label.text = "Wind speed: " + str(speed);
	 
