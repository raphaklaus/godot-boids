extends Node

var max_force = 20
var max_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_force(max_force)
	set_max_speed(max_speed)

func set_max_force(force):
	max_force = force
	
func set_max_speed(speed):
	max_speed = speed
	
func get_max_force():
	return max_force
	
func get_max_speed():
	return max_speed
