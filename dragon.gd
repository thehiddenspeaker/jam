extends CharacterBody2D

@export var speed: float = 50.0
@export var turn_speed: float = 1.5
@export var world_size: Vector2 = Vector2(512, 512)


var direction: float = 1.0


func _ready() -> void:
	position = world_size / 2.0


func _physics_process(delta: float) -> void:

	# Mouse steering.
	speed = 50 * pow(1.1,global.upgrade["dragonSpeed"])
	turn_speed = 1.5 * pow(1.1,global.upgrade["turnSpeed"])
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var target_direction = global_position.direction_to(
			get_global_mouse_position()
		)

		if target_direction.length_squared() > 0.001:
			var target_angle = target_direction.angle() + PI / 2.0

			rotation = rotate_toward(
				rotation,
				target_angle,
				turn_speed * delta
			)

	# Fly forward.
	velocity = Vector2.UP.rotated(rotation) * speed
	move_and_slide()

	# Bounce off left boundary.
	if position.x < 0:
		position.x = 0
		velocity = velocity.bounce(Vector2.RIGHT) 

	# Bounce off right boundary.
	if position.x > world_size.x:
		position.x = world_size.x
		velocity = velocity.bounce(Vector2.LEFT) 

	# Bounce off top boundary.
	if position.y < 0:
		position.y = 0
		velocity = velocity.bounce(Vector2.DOWN) 

	# Bounce off bottom boundary.
	if position.y > world_size.y:
		position.y = world_size.y
		velocity = velocity.bounce(Vector2.UP)

	# Turn dragon to match its new direction.
	if velocity.length_squared() > 0:
		rotation = velocity.angle() + PI / 2.0
