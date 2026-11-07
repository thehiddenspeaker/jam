extends Polygon2D

@export var fire_length: float = 120.0
@export var fire_width: float = 25.0
@export var civilization: TileMapLayer
@export var damage_interval: float = 0.1

var damage_timer = 0.0

func _ready():
	color = Color(1.0, 0.3, 0.0, 0.7)

	polygon = PackedVector2Array([
		Vector2(-8, 0),
		Vector2(8, 0),
		Vector2(fire_width, -fire_length),
		Vector2(-fire_width, -fire_length)
	])
	

func _process(delta):
	damage_timer += delta
	fire_width=20 * pow(1.1,global.upgrade["fireWidth"])
	fire_length= 60 * pow(1.1, global.upgrade["fireLength"])
	polygon = PackedVector2Array([
		Vector2(-8, 0),
		Vector2(8, 0),
		Vector2(fire_width, -fire_length),
		Vector2(-fire_width, -fire_length)
	])
	if damage_timer >= damage_interval:
		damage_timer = 0.0
		
		if civilization != null:
			
			civilization.destroy_in_fire(self)
		else:
			print("NO CIVILIZATION ASSIGNED")
