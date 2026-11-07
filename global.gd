extends Node
var money = 100
var mult = 1
var value = 1
var timer = 1

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
	"villageClustering":1,
	"cityClustering":1,
	"castleAttraction":1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -=delta
	if timer <0:
		print(upgrade["dragonSpeed"])
		timer =1
	pass

func villageDestroyed() -> void:
	money += (mult*(value+1))
	pass
func townDestroyed() -> void:
	money += (mult*(value+10))
	pass
func cityDestroyed() -> void:
	money += (mult*(value+100))
	pass
func castleDestroyed() -> void:
	money += (mult*(value+1000))
	pass
	
func parseUpgrades(upgradeToParse: Dictionary) -> void:
	upgrade.merge(upgradeToParse,true)
