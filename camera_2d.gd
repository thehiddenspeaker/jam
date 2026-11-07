extends Camera2D

func _process(_delta):
	if zoom.x == 0 or zoom.y == 0:
		print("INVALID CAMERA ZOOM: ", zoom)
