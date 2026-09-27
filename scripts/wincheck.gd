class_name WinCheck
extends Node2D

@onready var goal: TextureRect = $Goal

@onready var control: Control = $Control
@onready var background_color_rect: ColorRect = $Control/BackgroundColorRect
@onready var time_label: Label = $Control/Time
@onready var level_label: Label = $Control/Level
@onready var return_button: LevelSelectButton = $Control/ReturnButton

@onready var timer_label: Label = $Control/TimerLabel
@onready var goal_height = goal.position.y;

@export var hand : Hand;
@export var level_name : String;


var won = false;

var in_win_timeout: bool = false;
var win_timeout_time = 5.0;
var win_timeout = 5.0;

var timer_label_tween : Tween;
var win_tween : Tween;

var scene_start_time;

func _ready() -> void:
	scene_start_time = Time.get_ticks_msec();
	
func is_winning() -> bool:
	var winning = false;
	
	var card_is_locked = hand.locked_card != null;
	var card_is_being_held = hand.holding_card != null;
	
	if card_is_locked:
		#print("A CARD IS LOCKED");
		return false;
	
	if card_is_being_held:
		#print("YOU'RE HOLDING A CARD");
		return false;
		
	for card: Card in get_tree().get_nodes_in_group("card"):
		var card_at_top = card.get_tippy_top() <= goal_height;
		var card_resting = card.is_resting(card, []);

		if card_at_top and  card_resting:
			winning = true;
	
	#if !winning:
		#print("The height...");
	#else:
		#print("WINNING");
		
	return winning;

func check_timeout() -> void:
	if in_win_timeout: return;
	if is_winning():
		in_win_timeout = true;
		win_timeout = win_timeout_time;
		timer_label.show();

func time_in_milliseconds_to_string(time: int) -> String:
	var seconds = floor(time/1000.0);
	var minutes = floor(seconds/60);
	var post_seconds = seconds - minutes*60;
	
	return str(int(minutes)) + ":" + str(int(post_seconds));
	
func win() -> void:
	won = true;
	in_win_timeout = false;
	tween_label_size();
	timer_label.text = "SUCCESS!"
	
	background_color_rect.show();
	time_label.show();
	level_label.show();
	return_button.show();
	
	win_tween = create_tween().set_ease(Tween.EASE_IN);
	print("MAKE TWEEN")
	win_tween.set_parallel(true);
	win_tween.tween_property(background_color_rect, "modulate:a", 1.0, 1).from(0.0);
	win_tween.tween_property(time_label, "scale", Vector2(1,1), 1).from(Vector2(0,0));
	win_tween.tween_property(level_label, "scale", Vector2(1,1), 1).from(Vector2(0,0));
	win_tween.tween_property(return_button, "scale", Vector2(1,1), 1).from(Vector2(0,0));
	
	for card: Card in get_tree().get_nodes_in_group("card"):
		card.sprite.material = null;
		
	time_label.text = "Time taken: " + time_in_milliseconds_to_string(Time.get_ticks_msec()-scene_start_time);
	level_label.text = level_name;

func tween_label_size() -> void:
	if timer_label_tween:
		timer_label_tween.kill();
	timer_label_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK);
	timer_label_tween.tween_property(timer_label, "scale", Vector2(1,1), 0.5).from(Vector2(0.0,0.0))
	
func _process(delta: float) -> void:
	if !in_win_timeout or won: return;
	win_timeout -= delta;
	
	var old_text = timer_label.text;
	timer_label.text = str(ceil(win_timeout));
	if timer_label.text != old_text:
		tween_label_size();
	
	if !is_winning():
		in_win_timeout = false;
		timer_label.hide();
		
	if win_timeout < 0.0:
		win();
