extends Node2D

const Entity = preload("res://entity.tscn")
var click_cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Controller.set_max_force($force.value)
	Controller.set_max_speed($speed.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = "FPS: %s" % String(Engine.get_frames_per_second())
	$Label2.text = "Max speed: %s" % Controller.get_max_speed()
	$Label3.text = "Max force: %s" % Controller.get_max_force()
	
	if (OS.get_ticks_msec() - click_cooldown > 50 and
	Input.is_action_pressed("ui_up")):
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
