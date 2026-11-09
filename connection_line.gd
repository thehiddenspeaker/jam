extends Node2D

@onready var terrain = get_parent()

func _draw():
	var castles = []

	for location in terrain.buildings:
		if terrain.buildings[location]["kind"] == "castle":
			castles.append(location)

	# Connect every castle to every other castle
	for i in range(castles.size()):
		for j in range(i + 1, castles.size()):
			var start = terrain.map_to_local(castles[i])
			var finish = terrain.map_to_local(castles[j])

			# Outer glow
			draw_line(
				start,
				finish,
				Color(1.0, 0.75, 0.2, 0.2),
				9.0
			)

			# Gold line
			draw_line(
				start,
				finish,
				Color(1.0, 0.8, 0.3, 0.9),
				4.0
			)

			# Bright center
			draw_line(
				start,
				finish,
				Color(1.0, 1.0, 0.9),
				1.5
			)
