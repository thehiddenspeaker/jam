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

@export var DragonPanel: Panel
@export var FirePanel: Panel
@export var CivPanel: Panel



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

func _Button1Press() -> void:
	upgrade["dragonSpeed"] +=1
	print("button1speed pressed")
	pass # Replace with function body.

func _Button2Press() -> void:
	upgrade["turnSpeed"] +=1
	pass # Replace with function body.


func _Button3Press() -> void:
	pass # Replace with function body.

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
