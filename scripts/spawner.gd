extends Node2D

#Könnyen változtatható változók
@export var Spawn=0
@export var MAX_SPAWN=2
@export var enemy = preload("res://scenes/MapScenes/Enemy/enemy.tscn")

#Szükséges változók
var canspawn=true
var playerClose=false

func _ready() -> void:
	MAX_SPAWN+=get_child_count()

#Lény idézése a szerint hogy van beállítva
func _on_timer_timeout() -> void:
	if Spawn>0 and MAX_SPAWN>get_child_count() and playerClose:
		var instance = enemy.instantiate()
		instance.global_position = $".".global_position
		print($".".global_position," ",instance.position," ",instance," ",enemy)
		get_tree().current_scene.add_child(instance)
		Spawn-=1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		playerClose=true
