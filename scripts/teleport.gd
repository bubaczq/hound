extends AnimatedSprite2D

#Szükséges változók
var playerin=false
var next_sceene=""
const Lobby="res://scenes/MainMenu/map_selection.tscn"
const FILE_BEGIN="res://levels/level_"

#Könynen változtatható változók
@export var lobby=true
@export var message="PRESS \"E\" to travel." 
@export var teleport_location=""
@export var NewBestLevel=0 # ha 0 akkor nem változik

func _ready() -> void:
	$".".play("default")

#Események aszerint mit csinálunk
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and playerin:
		GameManeger.mentes()
	#Ha a lobby-ba akarunk menni akkor oda irányit
	if Input.is_action_just_pressed("action") and playerin and lobby:
		if NewBestLevel>0 and GameManeger.BestLevel<NewBestLevel:
			GameManeger.BestLevel=NewBestLevel
		GameManagerClear()
		get_tree().change_scene_to_file(Lobby)
		var file = FileAccess.open(GameManeger.savename+"/"+str(GameManeger.courrentsave)+".dat", FileAccess.WRITE)
		var data = {
				"BestLevel": GameManeger.BestLevel
			}
		file.store_string(JSON.stringify(data))
		file.close()
	#Ha a nem lobby-ba akarunk menni akkor oda irányit
	elif Input.is_action_just_pressed("action") and playerin and !lobby:
		next_sceene=FILE_BEGIN+teleport_location+".tscn"
		GameManagerClear()
		GameManeger.NextScene=next_sceene
		get_tree().change_scene_to_file(GameManeger.LoadingScene)
	
#Érzékeli a játékost
func _on_area_2d_body_entered(body: Node2D) -> void:
	GameManeger.message=message
	playerin=true

#Érzékeli ha elmegy a játékos
func _on_area_2d_body_exited(body: Node2D) -> void:
	playerin=false
	if GameManeger.message==message:
		GameManeger.message=""

#Game Manager törlése hogy ne legyenek bugok
func GameManagerClear():
	GameManeger.dialog=false
	GameManeger.BossHP=0
	GameManeger.message=""
