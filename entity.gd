extends Node2D

var rng = RandomNumberGenerator.new()
var MAX_SPEED = Controller.get_max_speed()
var MAX_FORCE = Controller.get_max_force()
var velocity = Vector2()
var keep_steering_away = false
var keep_steering_away_walls = false
var obstacle_to_steer_away
var colliding_count = 0
var separation_boids = Array()
var neighbor_boids = Array()
var neighbor_obstacles = Array()

var SCREEN_CENTER = OS.get_window_size() / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func initialize(pos, goal):
	global_position = pos
	var creation_velocity = global_position
	var creation_angle = global_position.angle_to_point(SCREEN_CENTER)
	var new_vel = Vector2(0,0)
	new_vel.x = creation_angle * cos(creation_angle)
	new_vel.y = creation_angle * sin(creation_angle)

#	print("center", OS.get_window_size())
	print(rad2deg(creation_angle))
	print(new_vel)

	if goal == null:
		velocity = new_vel * MAX_SPEED/3
	else:
		velocity = goal
	
	modulate = Color.from_hsv(randf(), 0.8, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	MAX_SPEED = Controller.get_max_speed()
	MAX_FORCE = Controller.get_max_force()
	move(delta)

func randomly_choose_place():
	rng.randomize()
	return Vector2(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0)
	)

func move(delta):
#	if global_position.x > 1050:
	if global_position.x > (1000 - 32):
#		global_position = Vector2(0, global_position.y)
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x + 10, global_position.y)
		
#	elif global_position.x < -50:
	elif global_position.x < 32:
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x - 10, global_position.y)
#		global_position = Vector2(1000, global_position.y)

#	elif global_position.y > 650:
	elif global_position.y > 600 - 32:
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x, global_position.y + 10)
#		global_position = Vector2(global_position.x, 0)

#	elif global_position.y < -50:
	elif global_position.y < 32:
		keep_steering_away_walls = true
		obstacle_to_steer_away = Vector2(global_position.x, global_position.y - 10)
#		global_position = Vector2(global_position.x, 600)
	else:
		keep_steering_away_walls = false

	for boid in separation_boids:
		var obstacle = boid.global_position
		velocity = velocity + (separate(obstacle) * 2.5)

	if keep_steering_away_walls:
		velocity = velocity + flee(obstacle_to_steer_away) * MAX_SPEED
	
	velocity = velocity + alignment()
	velocity = velocity + cohesion()
	velocity = velocity +  steer_away()
	
	velocity = velocity.clamped(MAX_SPEED)
	
	rotation_degrees = rad2deg(atan2(velocity.y, velocity.x))
	position += velocity * delta

func steer_away():
	if len(neighbor_obstacles) == 0:
		return Vector2.ZERO
	
	var ahead = global_position + velocity.normalized() * 1
	var thing = neighbor_obstacles[0]
	var force = ahead - thing.global_position
	return force.normalized() * 10

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
#	print(velocity)
	var desired_velocity = Vector2(target - global_position).normalized() * MAX_SPEED
	var steer = (-1 * desired_velocity) - velocity
	return steer.clamped(MAX_FORCE / 20)

func _on_neighbor_area_area_entered(area):
	if area.is_in_group("neighbor_area"):
		var boid = area.get_parent()
		var index = neighbor_boids.find(boid)
		if index == -1:
			neighbor_boids.append(boid)

	if area.is_in_group("obstacles_area"):
		var obstacle = area.get_parent()
		var index = neighbor_obstacles.find(obstacle)
		if index == -1:
			neighbor_obstacles.append(obstacle)


func _on_neighbor_area_area_exited(area):
	if area.is_in_group("neighbor_area"):
		var boid = area.get_parent()
		var index = neighbor_boids.find(boid)
		if index >= 0:
			neighbor_boids.erase(boid)
			
	if area.is_in_group("obstacles_area"):
		var obstacle = area.get_parent()
		var index = neighbor_obstacles.find(obstacle)
		if index >= 0:
			neighbor_obstacles.erase(obstacle)



func _on_separation_area_area_entered(area):
	if area.is_in_group("separation_area"):
		var entity = area.get_parent()
		var index = separation_boids.find(entity)
		if index == -1:
			separation_boids.append(entity)


func _on_separation_area_area_exited(area):
	if area.is_in_group("separation_area"):
		var entity = area.get_parent()
		var index = separation_boids.find(entity)
		if index >= 0:
			separation_boids.erase(entity)

