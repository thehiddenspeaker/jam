extends TileMapLayer

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

# CIVILIZATION SETTINGS
@export var villages_can_become_cities = false
@export var cities_can_become_castles = false

@export var village_spawn_interval = 2.0
@export var city_spawn_interval = 8.0
@export var castle_spawn_interval = 30.0

@export var fast_rebuild_time = 3.0
@export var normal_rebuild_time = 15.0

@export var village_clustering_distance = 4.0
@export var city_spacing_distance = 8.0
@export var castle_attraction_distance = 6.0
@export var guaranteed_destroy_distance: float = 32.0
@export var distant_building_destroy_chance: float = 0.25
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
		var too_close_to_city = false

		for other_location in buildings:
			var distance = Vector2(location).distance_to(Vector2(other_location))
			var kind = buildings[other_location]["kind"]

			if kind == "village" and distance <= village_clustering_distance:
				nearby_villages += 1

			if kind == "city" and distance < city_spacing_distance:
				too_close_to_city = true

		if nearby_villages >= 3 and not too_close_to_city:
			buildings[location]["kind"] = "city"
			set_cell(location, SOURCE_ID, CITY)
			return
func attempt_spawn_castle():
	if not cities_can_become_castles:
		return

	for location in buildings:
		if buildings[location]["kind"] != "city":
			continue

		var nearby_villages = 0
		var too_close_to_castle = false

		for other_location in buildings:
			var distance = Vector2(location).distance_to(Vector2(other_location))
			var kind = buildings[other_location]["kind"]

			if kind == "village" and distance <= castle_attraction_distance:
				nearby_villages += 1

			if kind == "castle" and distance < city_spacing_distance:
				too_close_to_castle = true

		if nearby_villages >= 2 and not too_close_to_castle:
			buildings[location]["kind"] = "castle"
			set_cell(location, SOURCE_ID, CASTLE)
			return

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

			set_cell(tile_pos, SOURCE_ID, BURNT_GRASS)
			regrowing_tiles.append(tile_pos)
			regrow_grass(tile_pos)

		# Destroy villages and cities
		elif  atlas == CITY or atlas == CASTLE:
			var building_distance = world_position.distance_to(fire.global_position)

			if building_distance <= guaranteed_destroy_distance:
				destroy_building(tile_pos)

			elif randf() < distant_building_destroy_chance:
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
func _process(delta):
	village_timer += delta
	city_timer += delta
	castle_timer += delta

	if village_timer >= village_spawn_interval:
		village_timer = 0.0
		attempt_spawn_village()

	if city_timer >= city_spawn_interval:
		city_timer = 0.0
		attempt_spawn_city()

	if castle_timer >= castle_spawn_interval:
		castle_timer = 0.0
		attempt_spawn_castle()
