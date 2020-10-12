extends Node2D

export(bool) 	var master_entity

var MAX_SPEED = Controller.get_max_speed()
var MAX_FORCE = Controller.get_max_force()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var should_check_boundaries = false
const possible_angles_x = [0, 45]
const possible_angles_y = [90, 135]
var near_by_objs = Array()
var velocity = Vector2()
var direction_x = 1
var direction_y = 1
var angle = 0
var move_to
var keep_steering_away = false
var keep_steering_away_walls = false
var obstacle_to_steer_away
var colliding_count = 0
var neighbor_boids = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
#	pass # Replace with function body.
	move_to = randomly_choose_place(global_position)

func initialize(pos, goal):
	master_entity = [
		true, 
		false,
		false,
		false,
		false
	][randi() % 5]
	
	if master_entity:
		$Sprite.modulate = Color.black
	
	global_position = pos
	if goal == null:
		velocity = randomly_choose_place(global_position) * MAX_SPEED
	else:
		velocity = goal
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	MAX_SPEED = Controller.get_max_speed()
	MAX_FORCE = Controller.get_max_force()
#	if not master_entity:
#		var master_entity_ref = find_master()
#		if master_entity_ref:
##			if (Vector2(master_entity_ref.global_position - global_position) < Vector2(100, 100)):
#			velocity = seek(master_entity_ref.global_position)
#			rotation_degrees = rad2deg(master_entity_ref.move_to.angle_to_point(master_entity_ref.global_position))
#			position += velocity * delta
#		else:
#			move(delta)
#	else:
	move(delta)

#	print(near_by_objs)

func randomly_choose_place(current_pos):
	var places = [
		Vector2(-1, 0),
		Vector2(-1, 1),
		Vector2(-1, -1),
		Vector2(1, 1),
		Vector2(1, 0),
		Vector2(1, -1),
		Vector2(0, 1),
		Vector2(0, -1),
	]
	
	randomize()
	var chosen = places[randi()% len(places)]
#	print("asdasd")
#	print(chosen)
#	print(current_pos)
#	if (abs(current_pos.x - chosen.x) < 500 and
#		abs(current_pos.y - chosen.y) < 150):
#			return randomly_choose_place(current_pos)

	return Vector2(chosen)

func move(delta):
	if global_position.x > 950:
#		global_position.x = 900
#		velocity = -velocity
#		if should_check_boundaries:
#			should_check_boundaries = false
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x + 10, global_position.y)
		


#		direction_x = -1
#		direction_y = [1, -1][randi() % 2]
#		angle = possible_angles_x[randi() % possible_angles_x.size()]
	elif global_position.x < 50:
#		global_position.x = 50
#		velocity = -velocity

#		if should_check_boundaries:
#			should_check_boundaries = false
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x - 10, global_position.y)


#		direction_x = 1
#		direction_y = [1, -1][randi() % 2]
#		angle = possible_angles_x[randi() % possible_angles_x.size()]	
	elif global_position.y > 550:
#		global_position.y = 550
#		position.y = 550
#		velocity = -velocity

#		if should_check_boundaries:
#			should_check_boundaries = false
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x, global_position.y + 10)


#		direction_x = [1, -1][randi() % 2]
#		direction_y = -1
#		angle = possible_angles_y[randi() % possible_angles_y.size()]
	elif global_position.y < 50:
#		global_position.y = 50
#		position.y = 50
#		velocity = -velocity
#		if should_check_boundaries:
#			should_check_boundaries = false
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x, global_position.y - 10)

#		direction_x = [1, -1][randi() % 2]
#		direction_y = 1
#		angle = possible_angles_y[randi() % possible_angles_y.size()]
	else:
		keep_steering_away_walls = false

	for boid in neighbor_boids:
		var obstacle = boid.global_position
		velocity = velocity + (separate(obstacle) * 1.5)

	if keep_steering_away_walls:
		velocity = velocity + flee(obstacle_to_steer_away)
	
	velocity = velocity + alignment()
	velocity = velocity + cohesion()
	
	velocity = velocity.clamped(MAX_SPEED)
	
	rotation_degrees = rad2deg(atan2(velocity.y, velocity.x))
	position += velocity * delta
#		position.x += 1000 * direction_x * cos(angle) * delta
#		position.y += 1000 * direction_y * sin(angle) * delta
#
#
#func find_master():
#	var result = null
#	for i in len(near_by_objs):
#		if near_by_objs[i].master_entity:
#			result = near_by_objs[i]
#
#	return result

func cohesion():
	if len(neighbor_boids) == 0: 
		return Vector2(0,0)

	var count = 0
	var average_vel = Vector2()
	for boid in neighbor_boids:
		count += 1
		average_vel += boid.global_position
		
	average_vel /= count
	return seek(average_vel)

func separate(obstacle):
	var steer = Vector2()
	var distance = global_position.distance_to(obstacle)
	var diff_vector = global_position - obstacle
	diff_vector = diff_vector.normalized()
	diff_vector = diff_vector / distance
	steer = steer + diff_vector
	
	if steer.length() > 0:
		steer = steer.normalized()
		steer = steer * MAX_SPEED
		steer -= velocity
		steer = steer.clamped(MAX_FORCE)
	
	return steer

func alignment():
	if len(neighbor_boids) == 0:
		return Vector2(0,0)
	
	var count = 0
	var average_velocity = Vector2()
	for boid in neighbor_boids:
		count += 1
		average_velocity += boid.velocity
	
	average_velocity /= count
	average_velocity = average_velocity.normalized()
	average_velocity *= MAX_SPEED
	var steer = Vector2(average_velocity - velocity)
	return steer.clamped(MAX_FORCE)

func seek(target):
	var desired_velocity = Vector2(target - global_position).normalized() * MAX_SPEED
	var steer = desired_velocity - velocity
	return steer.clamped(MAX_FORCE)

func flee(target):
	var desired_velocity = Vector2(target - global_position).normalized() * MAX_SPEED
	var steer = (-1 * desired_velocity) - velocity
	return steer.clamped(MAX_FORCE)

#func _on_Area2D_area_entered(area):
## STEER
#	colliding_count += 1
#	keep_steering_away = true
#	obstacle_to_steer_away = area.get_parent().global_position
#

# FOLLOW
#	var index = near_by_objs.find(area.get_parent())
#	if index == -1:
#		near_by_objs.append(area.get_parent())

#func _on_Area2D_area_exited(area):
#	colliding_count -= 1
#	obstacle_to_steer_away = null
#	keep_steering_away = false


func _on_neighbor_area_area_entered(area):
	if area.is_in_group("neighbor_area"):
		var boid = area.get_parent()
		var index = neighbor_boids.find(boid)
		if index == -1:
			neighbor_boids.append(boid)


func _on_neighbor_area_area_exited(area):
	if area.is_in_group("neighbor_area"):
		var boid = area.get_parent()
		var index = neighbor_boids.find(boid)
		if index >= 0:
			neighbor_boids.erase(boid)
