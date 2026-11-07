extends Control
var mult = 1
var value = 1
var timer =1 

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

@onready var money_label: Label = $MarginContainer/gamelayout/Panel/MoneyLabel

#panels
@export var DragonPanel: Panel
@export var FirePanel: Panel
@export var CivPanel: Panel

#buttons
@export var dragonSpeed: Button
@export var turnSpeed: Button
@export var fireLength: Button
@export var fireWidth: Button
@export var fireDamage: Button
@export var rebuild_time: Button
@export var village_clustering: Button
@export var city_clustering: Button
@export var castleAttraction: Button



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	timer -=delta
	if timer <0:
		timer =1
		
	global.parseUpgrades(upgrade)
	if money_label != null:
		money_label.text = str(global.money)

func passUpgrades() -> Dictionary:
	return upgrade
	
func toggle_panel(panel: Panel, is_toggled: bool) -> void:
	if not panel: 
		print("nopanelerror")
		return
	if is_toggled:
		panel.process_mode = Node.PROCESS_MODE_DISABLED
		panel.hide()
	else:
		panel.process_mode = Node.PROCESS_MODE_INHERIT
		panel.show()

func _on_dragon_toggled(toggled_on: bool) -> void:
	toggle_panel(DragonPanel, toggled_on)

func _on_fire_toggled(toggled_on: bool) -> void:
	toggle_panel(FirePanel, toggled_on)

func _on_civilization_toggled(toggled_on: bool) -> void:
	toggle_panel(CivPanel, toggled_on)


func purchase(button) -> void:
	
	return

func flash_red(button) -> void:
	var tween := create_tween()
	button.modulate = Color.RED
	tween.tween_property(button, "modulate", Color.WHITE, 0.3)

func speedpurchase() -> void:
	var price =1
	price = upgrade["dragonSpeed"]*10
	if global.money - price > 0:
		price = -price
		global.changeMoney(price)
		upgrade["dragonSpeed"]+=1
	else:
		print("broke")
		flash_red(dragonSpeed)
	pass 
	
	
	
	
	
