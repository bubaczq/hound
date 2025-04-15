extends Node2D

#Új achivement Jelenet
@export var achivement = preload("res://scenes/Other/NewAchivement.tscn")
#Achivment megszerzése ha nincs meg
func _ready() -> void:
	GameManeger.restartSceene="res://levels/level_1.tscn"
	var new_achivement=achivement.instantiate()
	add_child(new_achivement)
	new_achivement.set_tooltip(2)
