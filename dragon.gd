extends CharacterBody2D
@export var speed: float = 100.0
@export var left_boundary: float = 64.0
@export var right_boundary: float = 448.0

var direction: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(256, 256)
	print(speed * direction)
	print_tree_pretty()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_x: float
	if direction>0:
		target_x = right_boundary
	else:
		target_x=left_boundary
	position.x = move_toward(
		position.x,target_x,speed * delta
	)
	if position.x == target_x:
		direction*=-1.0
	$dragonsprite.flip_v = direction < 0
	pass
