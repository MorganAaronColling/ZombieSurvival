extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mushroom_sprite = $MushroomSprite
	var scale_factor = randf_range(0.8, 1.2)
	mushroom_sprite.scale *= Vector2(scale_factor, scale_factor)
	if randf_range(0, 1) > 0.5:
		mushroom_sprite.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
