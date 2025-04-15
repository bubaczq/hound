extends Button

#Szükséges változók
const FILE_BEGIN="res://levels/level_"
var NewLocation=""

#Könnyen változtatható változók
@export var LevelName="1"
@export var NeededBestLevel=0

#Node-ok változóba szervezése
@onready var button=$"."

#A következő jelenet Stringé összerakása és a gomb felirata
func _ready() -> void:
	NewLocation=FILE_BEGIN+str(LevelName)+".tscn"

#A szint elérhető-e
func _process(delta: float) -> void:
	if NeededBestLevel<=GameManeger.BestLevel:
		button.disabled=false
	else:
		button.disabled=true

#Megnyomásával a szint betőltése
func _on_pressed() -> void:
	#print("megnyomva ",button.disabled," ",NewLocation)
	if !button.disabled:
		GameManeger.NextScene=NewLocation
		get_tree().change_scene_to_file(GameManeger.LoadingScene)
