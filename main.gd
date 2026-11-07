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
	

func dragonDown() -> void:
	pass # Replace with function body.

func dragonUp() -> void:
	pass # Replace with function body.


func fireDown() -> void:
	pass # Replace with function body.

func fireUp() -> void:
	pass # Replace with function body.


func civilizationDown() -> void:
	pass # Replace with function body.


func civilizationUp() -> void:
	pass # Replace with function body.

func rebuildDown() -> void:
	pass # Replace with function body.

func rebuildUp() -> void:
	pass # Replace with function body.
