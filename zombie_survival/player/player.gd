extends CharacterBody2D

@onready var player_animations = $PlayerAnimations
@onready var gun_sounds = $GunSounds
@onready var bullet = preload("res://zombie_survival/bullet/bullet.tscn")
@onready var gun_alert_area = $GunAlertArea
@onready var player_take_damage = $PlayerTakeDamageArea

var gun_offset : Array[Vector2] = [Vector2(0, -42), Vector2(0, 5), Vector2(-8, -18), Vector2(8, -18)]

var speed = 100  # speed in pixels/sec
var last_input_direction
var dead = false
var health = 5

func _physics_process(delta):
	if !dead:
		var direction = Input.get_vector("left", "right", "up", "down")
		if !direction.is_zero_approx():
			last_input_direction = direction
		if (player_animations.animation.contains('shoot') and !player_animations.is_playing() and direction != Vector2.ZERO) or !player_animations.animation.contains('shoot'):
			speed = 100
			animation_controller(direction)
		velocity = direction * speed
		move_and_slide()
	
func _unhandled_input(event):
	# Mouse in viewport coordinates.
	if !dead and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and (!player_animations.animation.contains('shoot') or (player_animations.animation.contains('shoot') and !player_animations.is_playing())):
		speed = 25
		gun_sounds.play()
		var bullet_instance = bullet.instantiate()
		var mouse_position = get_global_mouse_position()
		var bullet_direction = (mouse_position - global_position).normalized()
		get_parent().add_child(bullet_instance)
		if bullet_direction.x <= -0.5:
			player_animations.play("shoot_left")
			bullet_instance.global_position = global_position + gun_offset[2]
			bullet_instance.bullet_direction = (mouse_position - (global_position + gun_offset[2])).normalized()
			bullet_instance.bullet_animation.play('default_left')
		elif bullet_direction.x >= 0.5:
			player_animations.play("shoot_right")
			bullet_instance.global_position = global_position + gun_offset[3]
			bullet_instance.bullet_direction = (mouse_position - (global_position + gun_offset[3])).normalized()
			bullet_instance.bullet_animation.play('default_right')
		elif bullet_direction.y <= -0.5:
			player_animations.play("shoot_up")
			bullet_instance.global_position = global_position + gun_offset[0]
			bullet_instance.bullet_direction = (mouse_position - (global_position + gun_offset[0])).normalized()
			bullet_instance.bullet_animation.play('default_up')
		elif bullet_direction.y >= 0.5:
			player_animations.play("shoot_down")
			bullet_instance.global_position = global_position + gun_offset[1]
			bullet_instance.bullet_direction = (mouse_position - (global_position + gun_offset[1])).normalized()
			bullet_instance.bullet_animation.play('default_down')
		for body in gun_alert_area.get_overlapping_bodies():
			if body.is_in_group('Zombie'):
				body.alert_zombie_state()
		

func animation_controller(input_direction):
	if !velocity.is_zero_approx():
		if input_direction.y <= -0.5:
			player_animations.play("walk_up")
		elif input_direction.y >= 0.5:
			player_animations.play("walk_down")
		elif input_direction.x <= -0.5:
			player_animations.play("walk_left")
		elif input_direction.x >= 0.5:
			player_animations.play("walk_right")
	elif last_input_direction != null:
		if last_input_direction.y <= -0.5:
			player_animations.play("idle_up")
		elif last_input_direction.y >= 0.5:
			player_animations.play("idle_down")
		elif last_input_direction.x <= -0.5:
			player_animations.play("idle_left")
		elif last_input_direction.x >= 0.5:
			player_animations.play("idle_right")

func take_damage(damage):
	if !dead:
		health -= damage
		if health <= 0:
			death()
	print(health)
			
func death():
	dead = true
	player_take_damage.queue_free()
	last_input_direction = velocity.normalized()
	if last_input_direction.y <= -0.5:
		player_animations.play("death_up")
	elif last_input_direction.y >= 0.5:
		player_animations.play("death_down")
	elif last_input_direction.x <= -0.5:
		player_animations.play("death_left")
	elif last_input_direction.x >= 0.5:
		player_animations.play("death_right")
	else:
		player_animations.play("death_down")
		
