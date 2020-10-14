extends Node2D

const Entity = preload("res://entity.tscn")
const Obstacle = preload("res://Obstacle.tscn")
var click_cooldown = 0
var disable_controls = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Controller.set_max_force($force.value)
	Controller.set_max_speed($speed.value)

func _unhandled_input(event):
	if not disable_controls and OS.get_ticks_msec() - click_cooldown > 50:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == BUTTON_RIGHT:
				click_cooldown = OS.get_ticks_msec()
				var obstacle = Obstacle.instance()
				obstacle.initialize(get_global_mouse_position())
				add_child(obstacle)
		
			if event.button_index == BUTTON_LEFT:
				click_cooldown = OS.get_ticks_msec()
				var e = Entity.instance()
				e.initialize(get_global_mouse_position(), null)
				add_child(e)

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = "FPS: %s" % String(Engine.get_frames_per_second())
	$Label2.text = "Max speed: %s" % Controller.get_max_speed()
	$Label3.text = "Max force: %s" % Controller.get_max_force()
	
#	if not disable_controls and OS.get_ticks_msec() - click_cooldown > 50:
#		if Input.is_mouse_button_pressed(2):
#			click_cooldown = OS.get_ticks_msec()
#			var obstacle = Obstacle.instance()
#			obstacle.initialize(get_global_mouse_position())
#			add_child(obstacle)
#
#		if Input.is_mouse_button_pressed(1):
#			click_cooldown = OS.get_ticks_msec()
#			var e = Entity.instance()
#			e.initialize(get_global_mouse_position(), null)
#			add_child(e)
#
#	if Input.is_action_just_pressed("ui_accept"):
#		get_tree().reload_current_scene()
		
func _on_HSlider_value_changed(value):
	Controller.set_max_speed(value)

func _on_force_value_changed(value):
	Controller.set_max_force(value)
