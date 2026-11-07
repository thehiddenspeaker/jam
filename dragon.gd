extends CharacterBody2D

@export var speed: float = 50.0
@export var turn_speed: float = 1.5
@export var world_size: Vector2 = Vector2(512, 512)

@export var segment_spacing: float = 16.0

@onready var head: Sprite2D = $Head
@onready var tail: Sprite2D = $Tail

var body_segments: Array[Sprite2D] = []

var position_history: Array[Vector2] = []


func _ready() -> void:
	position = world_size / 2.0

	# Find all body segments.
	for child in get_children():
		if child.name.begins_with("Body"):
			body_segments.append(child)

	# Initialize position history.
	for i in range(200):
		position_history.append(global_position)


func _physics_process(delta: float) -> void:

	# Apply upgrades.
	speed = 50 * pow(1.1, global.upgrade["dragonSpeed"])
	turn_speed = 1.5 * pow(1.1, global.upgrade["turnSpeed"])

	# Mouse steering.
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

	# Bounce off boundaries.
	if position.x < 0:
		position.x = 0
		velocity = velocity.bounce(Vector2.RIGHT)

	if position.x > world_size.x:
		position.x = world_size.x
		velocity = velocity.bounce(Vector2.LEFT)

	if position.y < 0:
		position.y = 0
		velocity = velocity.bounce(Vector2.DOWN)

	if position.y > world_size.y:
		position.y = world_size.y
		velocity = velocity.bounce(Vector2.UP)

	# Face direction of travel.
	if velocity.length_squared() > 0:
		rotation = velocity.angle() + PI / 2.0

	# Record head position.
	position_history.push_front(global_position)

		# Update body segments.
	for i in range(body_segments.size()):
		var distance = segment_spacing * (i + 1)

		var current_position = get_history_position(distance)
		var previous_position = get_history_position(distance - 2.0)

		body_segments[i].global_position = current_position

		var direction = previous_position.direction_to(current_position)
		body_segments[i].global_rotation = direction.angle() + PI / 2.0

	# Update tail.
	var tail_distance = segment_spacing * (body_segments.size() + 1)

	var tail_position = get_history_position(tail_distance)
	var previous_position = get_history_position(tail_distance - 2.0)

	tail.global_position = tail_position

	var tail_direction = previous_position.direction_to(tail_position)
	tail.global_rotation = tail_direction.angle() + PI / 2.0


func get_history_position(distance: float) -> Vector2:
	var traveled = 0.0

	for i in range(position_history.size() - 1):
		var segment_distance = position_history[i].distance_to(
			position_history[i + 1]
		)

		traveled += segment_distance

		if traveled >= distance:
			return position_history[i + 1]

	return position_history[-1]
