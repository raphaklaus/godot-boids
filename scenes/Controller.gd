extends Node

var max_force = 20
var max_speed = 300
var cohension_level = 1
var separation_level = 1
var alingment_level = 1

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

func set_cohension_level(cohension):
	cohension_level = cohension

func get_cohension_level():
	return cohension_level

func set_separation_level(separation):
	separation_level = separation

func get_separation_level():
	return separation_level

func set_alingment_level(alingment):
	alingment_level = alingment

func get_alingment_level():
	return alingment_level
