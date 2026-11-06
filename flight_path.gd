extends Node2D
var drawing = false
var flight_points:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drawing = true
				flight_points.clear()
				flight_points.append(get_global_mouse_position())
			else:
				drawing = false
				print("Flight path:", flight_points)

	if event is InputEventMouseMotion and drawing:
		var point = get_global_mouse_position()

		# Avoid recording too many nearby points
		if flight_points.is_empty() or flight_points[-1].distance_to(point) > 5:
			flight_points.append(point)

		queue_redraw()
func _draw():
	if flight_points.size() > 1:
		draw_polyline(
			flight_points,
			Color.ORANGE,
			4.0,
			true
		)
"res://gamemanager.gd"
