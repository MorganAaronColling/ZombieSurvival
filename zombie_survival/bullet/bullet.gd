extends Area2D

@onready var bullet_animation = $BulletAnimated
var bullet_direction: Vector2
var speed = 600
var bullet_damage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += speed * bullet_direction * delta


func _on_area_entered(area):
	if area.is_in_group('ZombieTakeDamage'):
		area.get_parent().take_damage(bullet_damage)
		queue_free()
