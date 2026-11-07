extends Control
var mult = 1
var value = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$MarginContainer/gamelayout/Panel/MoneyLabel.text = str(global.money)
	global.parseUpgrades(passUpgrades())
	pass

func _Button1Press() -> void:
	global.money+=(value * mult)
	pass # Replace with function body.


func _Button2Press() -> void:
	value+=1
	pass # Replace with function body.


func _Button3Press() -> void:
	mult+=1
	pass # Replace with function body.

func passUpgrades() -> Array[int]:
	return [mult,value]
