class_name Hand
extends CharacterBody2D

@export var card_detection_area: Area2D
@export var sprite: Sprite2D
@export var lock_sprite: Sprite2D

@onready var hover_sound_player: AudioStreamPlayer = $HoverSoundPlayer
@onready var grab_sound_player: AudioStreamPlayer = $GrabSoundPlayer
@onready var lock_sound_player: AudioStreamPlayer = $LockSoundPlayer

var mouse_position : Vector2 = Vector2(0,0);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var hold_joint : Joint2D = null;

var highlighted_card : Card = null;
var holding_card : Card = null;
var locked_card : Card = null;

func _process(_delta: float) -> void:
	var overlapping_card = get_first_overlapping_card()
		
	#if highlighted_card:
		
		#highlighted_card = null;
		
	if overlapping_card and highlighted_card:
		if overlapping_card != highlighted_card:
			highlighted_card.sprite.set_instance_shader_parameter("enabled", false);
			highlighted_card = overlapping_card;
			overlapping_card.sprite.set_instance_shader_parameter("enabled", true)
			play_sound_random(hover_sound_player)
			sprite.frame = 1;
	elif overlapping_card:
		overlapping_card.sprite.set_instance_shader_parameter("enabled", true)
		highlighted_card = overlapping_card;
		if !holding_card:
			play_sound_random(hover_sound_player);
		sprite.frame = 1;
	elif highlighted_card:
		highlighted_card.sprite.set_instance_shader_parameter("enabled", false);
		highlighted_card = null;
		sprite.frame = 0;
	
	if holding_card:
		sprite.frame = 2;
		
func play_sound_random(player: AudioStreamPlayer) -> void:
	player.pitch_scale = randf_range(0.9, 1.1);
	player.play();
	
func _physics_process(_delta: float) -> void:
	var direction = (mouse_position-global_position).normalized();
	var magnitude = (mouse_position-global_position).length();
	
	velocity = direction*magnitude*40;
	var last_pos = global_position;
	
	move_and_slide();
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider();
		if collider is Card:
			collider.apply_force(velocity);
		if collider is StaticBody2D:
			global_position = last_pos;
			
func get_first_overlapping_card() -> Card:
	var overlapping_cards = card_detection_area.get_overlapping_bodies();
	if overlapping_cards.size() > 0:
		var overlapping_card = overlapping_cards[0];
		return overlapping_card;
	return null;
			
func hold():
	var overlapping_card = get_first_overlapping_card()
	if !overlapping_card: return;
	
	var joint = PinJoint2D.new();
	
	joint.node_a = overlapping_card.get_path();
	joint.node_b = self.get_path();
	joint.bias = 0.01;
	
	add_child(joint)
	
	set_collision_mask_value(1, true);
	set_collision_mask_value(2, true);
	add_collision_exception_with(overlapping_card);
	
	grab_sound_player.play();
	
	holding_card = overlapping_card;
	hold_joint = joint;
	
func release():
	if hold_joint:
		hold_joint.queue_free();
		hold_joint = null;
		
	set_collision_mask_value(1, false);
	set_collision_mask_value(2, false);
	holding_card = null;

func lock_card():
	var overlapping_card = get_first_overlapping_card()
	if !overlapping_card: return;
	if overlapping_card.locked:
		lock_sprite.hide();
		overlapping_card.unlock();
		locked_card = null;
	else:
		if locked_card:
			locked_card.unlock();
		
		lock_sound_player.play();
		
		overlapping_card.lock();
		lock_sprite.show();
		lock_sprite.global_position = global_position;
		
		locked_card = overlapping_card;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position;
		
	if event.is_action_pressed("hold_card"):
		hold();
	
	if event.is_action_released("hold_card"):
		release();
	
	if event.is_action_pressed("rotate_card_cw"):
		if holding_card:
			holding_card.apply_torque_impulse(5000);
	
	if event.is_action_pressed("rotate_card_ccw"):
		if holding_card:
			holding_card.apply_torque_impulse(-5000);
	
	if event.is_action_pressed("lock_card"):
		lock_card();
			
