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

#tab buttons
@export var DragonTab: Button
@export var FireTab: Button
@export var CivTab: Button

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

#prices
@export var dragonSpeedPrice: Label
@export var turnSpeedPrice: Label
@export var fireLengthPrice: Label
@export var fireWidthPrice: Label
@export var fireDamagePrice: Label
@export var rebuild_timePrice: Label
@export var village_clusteringPrice: Label
@export var city_clusteringPrice: Label
@export var castleAttractionPrice: Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_tabs()
	_setup_upgrade_buttons()
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	timer -=delta
	if timer <0:
		global.parseUpgrades(upgrade)
		timer =1
		
	if money_label != null:
		money_label.text = str(global.money)

func _setup_tabs() -> void:
	var tabs := {
		DragonTab:DragonPanel,
		FireTab:FirePanel,
		CivTab:CivPanel,
	}
	var group := ButtonGroup.new()
	for tab in tabs:
		tab.toggle_mode = true
		tab.button_group = group
		tab.pressed.connect(_show_panel.bind(tabs[tab]))
		DragonTab.button_pressed = true
		_show_panel(DragonPanel)

func _setup_upgrade_buttons() -> void:
	var buttons := {
		"dragonSpeed": dragonSpeed,
		"turnSpeed": turnSpeed,
		"fireLength": fireLength,
		"fireWidth": fireWidth,
		"fireDamage": fireDamage,
		"rebuildTime": rebuild_time,
		"villageClustering": village_clustering,
		"cityClustering": city_clustering,
		"castleAttraction": castleAttraction,
	}
	for key in buttons:
		var button: Button = buttons[key]
		if button:
			button.pressed.connect(purchase.bind(key, button))

func _show_panel(active: Panel) -> void:
	for panel in [DragonPanel, FirePanel, CivPanel]:
		var on: bool = (panel == active)
		panel.visible = on
		panel.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED


func passUpgrades() -> Dictionary:
	return upgrade
	
#func toggle_panel(panel: Panel, is_toggled: bool) -> void:
	#if not panel: 
		#print("nopanelerror")
		#return
	#if is_toggled:
		#panel.process_mode = Node.PROCESS_MODE_DISABLED
		#panel.hide()
	#else:
		#panel.process_mode = Node.PROCESS_MODE_INHERIT
		#panel.show()
#
#func _on_dragon_toggled(toggled_on: bool) -> void:
	#toggle_panel(DragonPanel, toggled_on)
#
#func _on_fire_toggled(toggled_on: bool) -> void:
	#toggle_panel(FirePanel, toggled_on)
#
#func _on_civilization_toggled(toggled_on: bool) -> void:
	#toggle_panel(CivPanel, toggled_on)


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
		dragonSpeedPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["dragonSpeed"]+=1
	else:
		print("broke")
		dragonSpeedPrice.text = str(price)
		flash_red(dragonSpeed)
	pass 

func turnspeedpurchase() -> void:
	var price =1
	price = upgrade["turnSpeed"]*10
	if global.money - price > 0:
		turnSpeedPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["turnSpeed"]+=1
	else:
		print("broke")
		flash_red(turnSpeed)
	pass 


func firelengthpurchase() -> void:
	var price =1
	price = upgrade["fireLength"]*10
	if global.money - price > 0:
		fireLengthPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["fireLength"]+=1
	else:
		print("broke")
		flash_red(fireLength)
	pass 


func firewidthpurchase() -> void:
	var price =1
	price = upgrade["fireWidth"]*10
	if global.money - price > 0:
		fireWidthPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["fireWidth"]+=1
	else:
		print("broke")
		flash_red(fireWidth)
	pass 


func firedamagepurchase() -> void:
	var price =1
	price = upgrade["fireDamage"]*10
	if global.money - price > 0:
		fireDamagePrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["fireDamage"]+=1
	else:
		print("broke")
		flash_red(fireDamage)
	pass 


func rebuildtimepurchase() -> void:
	var price =1
	price = upgrade["rebuildTime"]*10
	if global.money - price > 0:
		rebuild_timePrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["rebuildTime"]+=1
	else:
		print("broke")
		flash_red(rebuild_time)
	pass 


func villageclusteringpurchase() -> void:
	var price =1
	price = upgrade["villageClustering"]*10
	if global.money - price > 0:
		village_clusteringPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["villageClustering"]+=1
	else:
		print("broke")
		flash_red(village_clustering)
	pass 


func cityclusteringpurchase() -> void:
	var price =1
	price = upgrade["cityClustering"]*10
	if global.money - price > 0:
		city_clusteringPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["cityClustering"]+=1
	else:
		print("broke")
		flash_red(city_clustering)
	pass 

func castleattractionpurchase() -> void:
	var price =1
	price = upgrade["castleAttraction"]*10
	if global.money - price > 0:
		castleAttractionPrice.text = str(price+10)
		price = -price
		global.changeMoney(price)
		upgrade["castleAttraction"]+=1
	else:
		print("broke")
		flash_red(castleAttraction)
	pass 
