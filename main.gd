extends Node2D

const Entity = preload("res://entity.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var click_cooldown = 0
const MAX_SPEED = 300
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
#	$entity.initialize(Vector2(110, 150), Vector2(MAX_SPEED, 0))
#	$entity2.initialize(Vector2(620, 150), Vector2(MAX_SPEED, 0))
#	$entity3.initialize(Vector2(130, 150), Vector2(300, 0))

#func _input(event):
#	print(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = String(Engine.get_frames_per_second())
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
		
func _on_Area2D2_area_entered(area):
	print('ddddddd')

func _on_HSlider_value_changed(value):
	Controller.set_max_speed(value)

func _on_force_value_changed(value):
	Controller.set_max_force(value)
