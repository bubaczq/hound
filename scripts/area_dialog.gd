extends Sprite2D

#Könnyen változtatható adatok
@export var Szovegek=["Player:Dialógus:Ez egy helyhez kötött dialógus!"]
@export var GetAchivement=false
@export var Achivement=0

#Szükséges változók
var activated=false
var playerin=false

#A dialógus jelenet betöltése előre
@export var dialog = preload("res://scenes/Other/dialog.tscn")

func _process(delta: float) -> void:
	if !GameManeger.dialog and activated and !has_node("Dialog"):
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	#Ha a körzetébe vagyok és megnyomom a szükséges gombot akkor meghivja a dialógust ha nincs jelenleg már dialógus inditva
	if !GameManeger.dialog and !activated:
		activated=true
		var new_dialog=dialog.instantiate()
		add_child(new_dialog)
		new_dialog.set_tooltip(Szovegek,GetAchivement,Achivement)
		
		
		
		
	
