class_name Card
extends RigidBody2D

@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D

var locked = false;

var reset_position: Vector2;
var reset_forces: bool = false;
var post_reset: bool = false;

func lock():
	locked = true;
	
	set_deferred("freeze", true);
	sprite.modulate = "#ff00ff"

func unlock():
	locked = false;
	
	reset_position = global_position;
	reset_forces = true;
	
	freeze = false;
	sprite.modulate = "#ffffff"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var too_under = global_position.y > Globals.viewport_height + 50;
	var too_right = global_position.x > Globals.viewport_width + 500;
	var too_left = global_position.x < -500;
	var too_high = global_position.y < -800;
	
	if too_under or too_right or too_left or too_high:
		return_to_desk();

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset_forces:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		reset_forces = false
		post_reset = true;
		global_position = reset_position;
		
func return_to_desk() -> void:
	reset_position = Vector2(Globals.viewport_width/2.0, -200)
	reset_forces = true;

func get_tippy_top() -> float:
	var position_y = global_position.y;
	var angle_with_x_axis = PI/2 - rotation;
	var sin = abs(sin(angle_with_x_axis));
	return position_y - (sin * collision_shape.shape.height/2.0);

func is_resting(body: RigidBody2D, checked: Array[RigidBody2D]) -> bool:
	for colliding_body in body.get_colliding_bodies():
		if colliding_body is RigidBody2D and !checked.has(colliding_body):
			checked.append(colliding_body);
			if is_resting(colliding_body, checked):
				return true;
		elif colliding_body is StaticBody2D:
			return true;
	return false;
	
func _input(event: InputEvent) -> void:
	pass
