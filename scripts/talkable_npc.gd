extends Sprite2D

#Könnyen változtatható változók
@export var Kinezet=Texture2D
@export var NPC_Img=Texture2D
@export var GetAchivement=false
@export var Achivement=0
@export var szovegek=["Istvanmester:Dávid:szia szerény vitéz","Player:Dávid:Na mégesgyszer"]

#Dialógus jelenet előre való betöltése
@export var dialog = preload("res://scenes/Other/dialog.tscn")

#A Játékosnak külön küldött üzenet
@export var message="PRESS \"E\" to talk." 

#Node-ok változóba szervezése
@onready var Npc_look=$AnimatedSprite2D
@onready var Npc_img=$Sprite2D

#Szükséges változók
var playerin=false
var played=false

func _ready() -> void:
	if Kinezet==null:
		Npc_img.visible=false
		Npc_look.visible=true
		Npc_look.play("idle")
	else:
		Npc_img.texture=Kinezet
		Npc_img.visible=true
		Npc_look.visible=false

#A Karakter Animálciója és eseményre kötött beszélgetése
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and playerin and !GameManeger.dialog:
		var new_dialog=dialog.instantiate()
		add_child(new_dialog)
		new_dialog.set_tooltip(szovegek,GetAchivement,Achivement)

#A Játékos észlelése a közelbe és a neki szánt üzenet küldése
func _on_area_2d_body_entered(body: Node2D) -> void:
	GameManeger.message=message
	playerin=true
	if Npc_img.texture.resource_path=="res://assets/pngs/hood/i1.png" and !played:
		played=true
		Npc_img.visible=false 
		Npc_look.visible=true
		Npc_look.play("cutsceene")

#Játékos észlelése ha kilép a körzetből
func _on_area_2d_body_exited(body: Node2D) -> void:
	playerin=false
	if GameManeger.message==message:
		GameManeger.message=""
