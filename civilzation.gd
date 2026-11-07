extends TileMapLayer
var upgrade = {
	"dragonSpeed": 1,
	"turnSpeed": 1,
	"fireLength": 1,
	"fireWidth": 1,
	"fireDamage":1,
	"citySpawnChance":1,
	"citySpawnInterval":1,
	"castleSpawnChance":1,
	"castleSpawnInterval":1,
	"rebuildTime":1,
	"villageClustering":1,
	"cityClustering":1,
	"castleAttraction":1
}
# ATLAS SETTINGS
const SOURCE_ID = 0

const GRASS = Vector2i(0, 0)
const VILLAGE = Vector2i(0, 2)
const CITY = Vector2i(2, 2)
const RUBBLE = Vector2i(4, 2)
const CASTLE = Vector2i(4, 0)
const BURNT_GRASS = Vector2i(2, 0)

# WORLD SETTINGS
const WORLD_SIZE = Vector2i(32, 32)
var game_over = false
# DIFFICULTY
var game_time: float = 0.0
var difficulty: float = 1.0
# CIVILIZATION SETTINGS
@export var villages_can_become_cities = true
@export var cities_can_become_castles = true

@export var village_spawn_interval = 2.0
@export var city_spawn_interval = 8.0
@export var castle_spawn_interval = 25.0

@export var fast_rebuild_time = 3.0
@export var normal_rebuild_time = 15.0

@export var village_clustering_distance = 4.0
@export var city_spacing_distance = 8.0
@export var castle_attraction_distance = 6.0
@export var guaranteed_destroy_distance: float = 32.0
@export var distant_building_destroy_chance: float = 0.25
@export var minimum_castle_distance: float = 10.0
# SPAWNING SETTINGS
@export var random_village_chance = 0.1
@export var village_nearby_distance = 4.0
@export var castle_village_distance = 6.0

# BUILDING DATA
var buildings = {}
var destroyed_sites = {}
var destruction_history = {}
var population = {}
var recently_rebuilt = []

# TIMERS
var village_timer = 0.0
var city_timer = 0.0
var castle_timer = 0.0

var village_spawn_chance = 0.75
var city_spawn_chance = 0.35
var castle_spawn_chance = 0.20

@export var grass_burn_chance: float = 0.35
@export var grass_regrow_time: float = 2.0

var regrowing_tiles: Array[Vector2i] = []

func _ready():
	print("TERRAIN SCRIPT RUNNING")
	print("TileSet: ", tile_set)
	print("Has TileSet: ", tile_set != null)
	print("Has Source: ", tile_set.has_source(SOURCE_ID))


	randomize()
	generate_world()

func generate_world():
	clear()

	for x in range(WORLD_SIZE.x):
		for y in range(WORLD_SIZE.y):
			var grass_tile = Vector2i(
				randi_range(0, 1),
				randi_range(0, 1)
			)

			set_cell(Vector2i(x, y), SOURCE_ID, grass_tile)
func get_atlas_for_kind(kind: String) -> Vector2i:
	match kind:
		"village":
			return VILLAGE
		"city":
			return CITY
		"castle":
			return CASTLE

	return GRASS

func can_place_building(position: Vector2i) -> bool:
	if position.x < 0 or position.y < 0:
		return false

	if position.x >= WORLD_SIZE.x or position.y >= WORLD_SIZE.y:
		return false

	if buildings.has(position):
		return false

	if destroyed_sites.has(position):
		return false

	return true


func register_building(position: Vector2i, kind: String):
	buildings[position] = {
		"kind": kind,
		"size": Vector2i(1, 1)
	}

	set_cell(position, SOURCE_ID, get_atlas_for_kind(kind))
	update_connections()
func attempt_spawn_village():
	for i in range(100):
		var position = Vector2i(
			randi_range(0, WORLD_SIZE.x - 1),
			randi_range(0, WORLD_SIZE.y - 1)
		)

		if not can_place_building(position):
			continue

		var nearest_village_distance = 999.0

		for location in buildings:
			if buildings[location]["kind"] != "village":
				continue

			var distance = Vector2(position).distance_to(Vector2(location))

			if distance < nearest_village_distance:
				nearest_village_distance = distance

		var spawn_chance = random_village_chance

		if nearest_village_distance <= 3:
			spawn_chance = 0.8
		elif nearest_village_distance <= 6:
			spawn_chance = 0.3

		if randf() < spawn_chance:
			register_building(position, "village")
			return
func is_good_village_location(position: Vector2i) -> bool:
	var near_village = false

	for location in buildings:
		var kind = buildings[location]["kind"]
		var distance = Vector2(position).distance_to(Vector2(location))

		if kind == "village" and distance <= village_nearby_distance:
			near_village = true

		if kind == "castle" and distance <= castle_village_distance:
			return true

	return near_village
func attempt_spawn_city():
	if not villages_can_become_cities:
		return

	for location in buildings:
		if buildings[location]["kind"] != "village":
			continue

		var nearby_villages = 0
		var nearest_city_distance = 999.0
		var aligned_with_city = false

		for other_location in buildings:
			var kind = buildings[other_location]["kind"]
			var distance = Vector2(location).distance_to(Vector2(other_location))

			if kind == "village" and distance <= village_clustering_distance:
				nearby_villages += 1

			if kind == "city":
				nearest_city_distance = min(nearest_city_distance, distance)

				var difference = location - other_location

				if abs(difference.x) <= 1 or abs(difference.y) <= 1:
					aligned_with_city = true

		if nearby_villages < 3:
			continue

		# First city has no spacing restrictions
		if nearest_city_distance == 999.0:
			register_city(location)
			return

		# Cities can form close clusters or distant chains
		var close_to_city = nearest_city_distance <= 2.0
		var far_from_city = nearest_city_distance >= 8.0

		if close_to_city or (far_from_city and aligned_with_city):
			register_city(location)
			return


func register_city(location: Vector2i):
	buildings[location]["kind"] = "city"
	set_cell(location, SOURCE_ID, CITY)
	update_connections()
func attempt_spawn_castle():
	if not cities_can_become_castles:
		return

	for city_location in buildings:
		if buildings[city_location]["kind"] != "city":
			continue

		for i in range(50):
			var offset = Vector2i(
				randi_range(-6, 6),
				randi_range(-6, 6)
			)

			var castle_position = city_location + offset
			var distance = Vector2(offset).length()

			if distance < 3.0 or distance > 6.0:
				continue

			if not can_place_building(castle_position):
				continue

			var atlas = get_cell_atlas_coords(castle_position)

			# Only build on grass
			if get_cell_source_id(castle_position) != SOURCE_ID:
				continue

			if atlas.x > 1 or atlas.y > 1:
				continue

			# Keep castles separated
			# Keep castles separated
			var too_close = false

			for location in buildings:
				if buildings[location]["kind"] != "castle":
					continue

				var castle_distance = Vector2(castle_position).distance_to(Vector2(location))

				if castle_distance < minimum_castle_distance:
					too_close = true
					break

			if too_close:
				continue

			register_building(castle_position, "castle")
			check_game_over()
			return
func update_difficulty(delta: float):
	game_time += delta

	var time_pressure = game_time / 120.0
	var population_pressure = buildings.size() / 20.0

	difficulty = 1.0 + time_pressure + population_pressure

func check_game_over():
	if game_over:
		return

	var castle_count = 0

	for location in buildings:
		if buildings[location]["kind"] == "castle":
			castle_count += 1

	if castle_count >= 5:
		game_over = true
		print("GAME OVER! FIVE CASTLES HAVE BEEN BUILT!")
		get_tree().paused = true
func destroy_in_fire(fire):
	var fire_steps = 20

	for i in range(fire_steps):
		var distance = float(i) / float(fire_steps - 1)

		var local_fire_position = Vector2(
			0,
			-fire.fire_length * distance
		)

		var world_position = fire.to_global(local_fire_position)
		var tile_pos = local_to_map(world_position)

		var source_id = get_cell_source_id(tile_pos)

		if source_id != SOURCE_ID:
			continue

		var atlas = get_cell_atlas_coords(tile_pos)

		# Burn grass
		if atlas == VILLAGE or atlas == GRASS:
			if randf() > grass_burn_chance:
				continue

			if tile_pos in regrowing_tiles:
				continue
			if atlas ==VILLAGE:
				global.villageDestroyed()
			else:
				global.grassDestroyed()
			set_cell(tile_pos, SOURCE_ID, BURNT_GRASS)
			regrowing_tiles.append(tile_pos)
			regrow_grass(tile_pos)

		# Destroy villages and cities
		elif  atlas == CITY or atlas == CASTLE:
			queue_redraw()
			print("queued redraw from destruction")
			var building_distance = world_position.distance_to(fire.global_position)

			if building_distance <= guaranteed_destroy_distance:
				if atlas== CITY:
					global.cityDestroyed()
				else:
					global.castleDestroyed()
				destroy_building(tile_pos)

			elif randf() < distant_building_destroy_chance:
				if atlas== CITY:
					global.cityDestroyed()
				else:
					global.castleDestroyed()
				destroy_building(tile_pos)


func regrow_grass(tile_pos: Vector2i):
	await get_tree().create_timer(grass_regrow_time).timeout

	if get_cell_atlas_coords(tile_pos) == BURNT_GRASS:
		set_cell(tile_pos, SOURCE_ID, GRASS)

	regrowing_tiles.erase(tile_pos)


func destroy_building(tile_pos: Vector2i):
	if not buildings.has(tile_pos):
		return

	var building = buildings[tile_pos]

	# Leave rubble behind
	set_cell(tile_pos, SOURCE_ID, RUBBLE)

	# Remove the building from civilization data
	buildings.erase(tile_pos)
	population.erase(tile_pos)

	# Remember that a building was destroyed
	destroyed_sites[tile_pos] = building
	update_connections()
	
func update_connections():
	$ConnectionLine.queue_redraw()
func apply_upgrades():
	var upgrades = global.upgrade

	#village_spawn_chance = min(1.0, 0.75 * pow(1.15, upgrades["villageSpawnChance"] - 1))
	city_spawn_chance = min(1.0, 0.35 * pow(1.15, upgrades["citySpawnChance"] - 1))
	castle_spawn_chance = min(1.0, 0.20 * pow(1.15, upgrades["castleSpawnChance"] - 1))


	fast_rebuild_time = 3.0 * pow(1.15, upgrades["rebuildTime"])

	normal_rebuild_time = 15.0 * pow(1.15, upgrades["rebuildTime"])
	#village_spawn_interval = 2.0 * pow(0.9, upgrades["villageSpawnInterval"] - 1)
	city_spawn_interval = 8.0 * pow(0.9, upgrades["citySpawnInterval"] - 1)
	castle_spawn_interval = 25.0 * pow(0.9, upgrades["castleSpawnInterval"] - 1)

	village_clustering_distance = 4.0 * pow(0.9, upgrades["villageClustering"] - 1)
	city_spacing_distance = 8.0 * pow(0.9, upgrades["cityClustering"] - 1)
	castle_attraction_distance = 6.0 * pow(1.1, upgrades["castleAttraction"] - 1)

	guaranteed_destroy_distance = 32.0 * pow(1.1, upgrades["fireDamage"] - 1)
	distant_building_destroy_chance = min(1.0, 0.25 * pow(1.1, upgrades["fireDamage"] - 1))
func _process(delta):
	if game_over:
		return

	# Update difficulty.
	update_difficulty(delta)

	# Update upgrades.
	apply_upgrades()

	# Calculate effective spawn rates.
	var rate_multiplier = sqrt(difficulty)

	var village_interval = max(0.5, village_spawn_interval / rate_multiplier)
	var city_interval = max(1.5, city_spawn_interval / rate_multiplier)
	var castle_interval = max(4.0, castle_spawn_interval / rate_multiplier)

	var village_chance = min(0.95, village_spawn_chance * pow(difficulty, 0.25))
	var city_chance = min(0.95, city_spawn_chance * pow(difficulty, 0.45))
	var castle_chance = min(0.95, castle_spawn_chance * pow(difficulty, 0.65))

	# Village spawning.
	village_timer += delta

	if village_timer >= village_interval:
		village_timer = 0.0

		if randf() < village_chance:
			attempt_spawn_village()

	# City spawning.
	city_timer += delta

	if city_timer >= city_interval:
		city_timer = 0.0

		if randf() < city_chance:
			attempt_spawn_city()

	# Castle spawning.
	castle_timer += delta

	if castle_timer >= castle_interval:
		castle_timer = 0.0

		if randf() < castle_chance:
			attempt_spawn_castle()
