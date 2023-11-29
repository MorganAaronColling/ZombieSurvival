extends CharacterBody2D

@onready var zombie_animations = $ZombieAnimations
@onready var zombie_navigation = $ZombieNavigation
@onready var zombie_vision_pivot = $ZombieVisionPivot
@onready var zombie_vision = $ZombieVisionPivot/ZombieVision
@onready var zombie_take_damage = $ZombieTakeDamageArea
@onready var zombie_collision = $ZombieCollision
@onready var zombie_alert_timer = $ZombieAlertTimer
@onready var zombie_attack_area = $ZombieAttackRange
@onready var zombie_damage_delay = $ZombieAttackDamageDelay
@onready var zombie_attack_sound = $ZombieAttackSound
@onready var zombie_alert_sound = $ZombieAlertSound
@onready var zombie_growl_sound = $ZombieGrowlSound
@onready var zombie_growl_timer = $ZombieGrowlTimer
@onready var zombie_hurt_sound = $ZombieHurtSound

var speed = 50  # speed in pixels/sec
var base_vision = 100
var alert_vision = 210
var last_input_direction = Vector2(0, -1)
var targets_in_view = []
var targets_in_attack_range = []
var dead = false
var health = 5
var damage = 1

func _ready():
	zombie_growl_timer.wait_time = randf_range(1.5, 6)

func _physics_process(delta):
	if !dead:
		if !zombie_animations.animation.contains('attack') or (zombie_animations.animation.contains('attack') and !zombie_animations.is_playing()):
			if check_attack_area():
				return
			if !targets_in_view.is_empty():
				set_movement_target(targets_in_view.front().global_position)
				alert_zombie_state()
			if zombie_navigation.is_navigation_finished():
				last_input_direction = velocity.normalized()
				velocity = Vector2.ZERO
				animation_controller(Vector2.ZERO)
				return
			# Navigation and Movement Animations
			var current_zombie_position: Vector2 = global_position
			var next_path_position: Vector2 = zombie_navigation.get_next_path_position()
			var new_velocity: Vector2 = next_path_position - current_zombie_position
			new_velocity = new_velocity.normalized()
			animation_controller(new_velocity)
			new_velocity = new_velocity * speed
			velocity = new_velocity
			move_and_slide()

func animation_controller(input_direction):
	if !velocity.is_zero_approx():
		if input_direction.x <= -0.5:
			zombie_animations.play("walk_left")
			zombie_vision_pivot.rotation_degrees = 90
			zombie_attack_area.rotation_degrees = 90
			zombie_attack_area.position.x = -3
		elif input_direction.x >= 0.5:
			zombie_animations.play("walk_right")
			zombie_vision_pivot.rotation_degrees =-90
			zombie_attack_area.rotation_degrees = -90
			zombie_attack_area.position.x = 3
		elif input_direction.y <= -0.5:
			zombie_animations.play("walk_up")
			zombie_vision_pivot.rotation_degrees = 180
			zombie_attack_area.rotation_degrees = 180
			zombie_attack_area.position.x = 0
		elif input_direction.y >= 0.5:
			zombie_animations.play("walk_down")
			zombie_vision_pivot.rotation_degrees = 0
			zombie_attack_area.rotation_degrees = 0
			zombie_attack_area.position.x = 0
	elif last_input_direction != null:
		if last_input_direction.x <= -0.5:
			zombie_animations.play("idle_left")
			zombie_vision_pivot.rotation_degrees = 90
			zombie_attack_area.rotation_degrees = 90
		elif last_input_direction.x >= 0.5:
			zombie_animations.play("idle_right")
			zombie_vision_pivot.rotation_degrees = -90
			zombie_attack_area.rotation_degrees = -90
		elif last_input_direction.y <= -0.5:
			zombie_animations.play("idle_up")
			zombie_vision_pivot.rotation_degrees = 180
			zombie_attack_area.rotation_degrees = 180
		elif last_input_direction.y >= 0.5:
			zombie_animations.play("idle_down")
			zombie_vision_pivot.rotation_degrees = 0
			zombie_attack_area.rotation_degrees = 0
			
func set_movement_target(movement_target):
	zombie_navigation.target_position = movement_target
	
func death():
	dead = true
	zombie_take_damage.queue_free()
	zombie_collision.set_deferred('disabled', true)
	last_input_direction = velocity.normalized()
	if last_input_direction.x <= -0.5:
		zombie_animations.play("death_left")
	elif last_input_direction.x >= 0.5:
		zombie_animations.play("death_right")
	elif last_input_direction.y <= -0.5:
		zombie_animations.play("death_up")
	elif last_input_direction.y >= 0.5:
		zombie_animations.play("death_down")
	else:
		zombie_animations.play("death_down")
		
func take_damage(damage):
	if !dead:
		health -= damage
		zombie_hurt_sound.pitch_scale *= randf_range(0.95, 1.05)
		zombie_hurt_sound.play()
		alert_zombie_state()
		if health <= 0:
			death()
			
func alert_zombie_state():
	zombie_vision.shape.radius = alert_vision
	zombie_alert_timer.start()
	if zombie_animations.animation.contains('idle'):
		zombie_alert_sound.pitch_scale *= randf_range(0.9, 1.1)
		zombie_alert_sound.play()
	
func check_attack_area():
	if !targets_in_attack_range.is_empty():
		var target = targets_in_attack_range.front()
		var attack_direction = (target.global_position - global_position).normalized()
		zombie_damage_delay.start()
		zombie_attack_sound.pitch_scale *= randf_range(0.9, 1.1)
		zombie_attack_sound.play()
		if attack_direction.x <= -0.5:
			zombie_animations.play("attack_left")
		elif attack_direction.x >= 0.5:
			zombie_animations.play("attack_right")
		elif attack_direction.y <= -0.5:
			zombie_animations.play("attack_up")
		elif attack_direction.y >= 0.5:
			zombie_animations.play("attack_down")
		return true
	return false

func _on_zombie_vision_pivot_body_entered(body):
	if body.is_in_group('Human'):
		targets_in_view.append(body)

func _on_zombie_vision_pivot_body_exited(body):
	if body.is_in_group('Human'):
		targets_in_view.erase(body)
		
func _on_zombie_alert_timer_timeout():
	zombie_vision.shape.radius = base_vision

func _on_zombie_attack_range_area_entered(area):
	if area.is_in_group('PlayerTakeDamage'):
		targets_in_attack_range.append(area.get_parent())

func _on_zombie_attack_range_area_exited(area):
	if area.is_in_group('PlayerTakeDamage'):
		targets_in_attack_range.erase(area.get_parent())

func _on_zombie_attack_damage_delay_timeout():
	if !targets_in_attack_range.is_empty():
		var target = targets_in_attack_range.front()
		target.take_damage(damage)

func _on_zombie_growl_timer_timeout():
	if randf_range(0, 1) > 0.8 and !dead:
		zombie_growl_sound.pitch_scale *= randf_range(0.9, 1.1)
		zombie_growl_sound.play()
