extends Node2D

const Entity = preload("res://entity.tscn")
const Obstacle = preload("res://Obstacle.tscn")
var click_cooldown = 0
var disable_controls = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Controller.set_max_force($force.value)
	Controller.set_max_speed($speed.value)
	$speed.connect("gui_input", self, "on_gui_input")
	$speed.connect("mouse_exited", self, "on_gui_mouse_exited")
	$force.connect("gui_input", self, "on_gui_input")
	$force.connect("mouse_exited", self, "on_gui_mouse_exited")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = "FPS: %s" % String(Engine.get_frames_per_second())
	$Label2.text = "Speed: %s" % Controller.get_max_speed()
	$Label3.text = "Force: %s" % Controller.get_max_force()

	if not disable_controls and OS.get_ticks_msec() - click_cooldown > 25:
		if Input.is_mouse_button_pressed(2):
			click_cooldown = OS.get_ticks_msec()
			var obstacle = Obstacle.instance()
			obstacle.initialize(get_global_mouse_position())
			add_child(obstacle)

		if Input.is_mouse_button_pressed(1):
			click_cooldown = OS.get_ticks_msec()
			var e = Entity.instance()
			e.initialize(get_global_mouse_position(), null)
			add_child(e)

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
		
func _on_HSlider_value_changed(value):
	Controller.set_max_speed(value)

func _on_force_value_changed(value):
	Controller.set_max_force(value)

func on_gui_input(event):
	disable_controls = true
	
func on_gui_mouse_exited():
	disable_controls = false
