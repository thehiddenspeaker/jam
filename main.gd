extends Control
var mult = 1
var value = 1
var timer =1 
@onready var money_label: Label = $MarginContainer/gamelayout/Panel/MoneyLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	timer -=delta
	if timer <0:
		print("main mult = ",mult," value = ",value)
		timer =1
		
	global.parseUpgrades(passUpgrades())
	if money_label != null:
		money_label.text = str(global.money)

func _Button1Press() -> void:
	pass # Replace with function body.

func _Button2Press() -> void:
	value+=1
	print(value)
	pass # Replace with function body.


func _Button3Press() -> void:
	mult+=1
	print(mult)
	pass # Replace with function body.

func passUpgrades() -> Array[int]:
	return [mult,value]


func _on_money_pressed() -> void:
	global.villageDestroyed()
	pass # Replace with function body.
