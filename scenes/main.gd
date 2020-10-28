extends Node2D

const Entity = preload("res://scenes/entity.tscn")
const Obstacle = preload("res://scenes/Obstacle.tscn")
var click_cooldown = 0
var disable_controls = false
var SCREEN_CENTER = OS.get_window_size() / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	Controller.set_max_speed($speed.value)
	Controller.set_alingment_level($alignment.value)
	Controller.set_separation_level($separation.value)
	Controller.set_cohension_level($cohesion.value)
	$speed.connect("gui_input", self, "on_gui_input")
	$speed.connect("mouse_exited", self, "on_gui_mouse_exited")
	$cohesion.connect("gui_input", self, "on_gui_input")
	$cohesion.connect("mouse_exited", self, "on_gui_mouse_exited")
	$separation.connect("gui_input", self, "on_gui_input")
	$separation.connect("mouse_exited", self, "on_gui_mouse_exited")
	$alignment.connect("gui_input", self, "on_gui_input")
	$alignment.connect("mouse_exited", self, "on_gui_mouse_exited")

	for i in range(20):
		create_boid(Vector2(200,150))

	for i in range(20):
		create_boid(Vector2(900,500))

	for i in range(10):
		create_boid(SCREEN_CENTER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = "FPS: %s" % String(Engine.get_frames_per_second())
	$Label2.text = "Speed: %s" % Controller.get_max_speed()

	if not disable_controls and OS.get_ticks_msec() - click_cooldown > 25:
		if Input.is_mouse_button_pressed(2):
			click_cooldown = OS.get_ticks_msec()
			var obstacle = Obstacle.instance()
			obstacle.initialize(get_global_mouse_position())
			add_child(obstacle)

		if Input.is_mouse_button_pressed(1):
			click_cooldown = OS.get_ticks_msec()
			create_boid(get_global_mouse_position())

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
		
func _on_speed_value_changed(value):
	Controller.set_max_speed(value)

func on_gui_input(event):
	disable_controls = true
	
func on_gui_mouse_exited():
	disable_controls = false

func create_boid(pos):
	var e = Entity.instance()
	e.initialize(pos, null)
	add_child(e)	


func _on_alignment_value_changed(value):
	Controller.set_alingment_level(value)


func _on_separation_value_changed(value):
	Controller.set_separation_level(value)


func _on_cohesion_value_changed(value):
	Controller.set_cohension_level(value)
