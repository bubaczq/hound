extends Area2D

var activated=false
var whatToSeePosition=Vector2.ZERO

@export var whatToSeeDisaper=true
@export var GetAchivement = false

@export var Achivement = 0

@export var camera: Camera2D
@export var player: CharacterBody2D

@export var whatToSee: Node2D
@export var others: Array[Node2D]=[]

@export var Szovegek = ["1:ismeriasjav:Ismeretlen:Nem menekülhet senki!"]

@export var afterSpawn=true
@export var whatSpawn= preload("res://scenes/MapScenes/Enemy/enemy_2.tscn")

# Achivement jelent betöltése ha szükség lenne rá
@onready var achivement = preload("res://scenes/Other/NewAchivement.tscn")

# A dialógus jelenet betöltése előre
@onready var dialog = preload("res://scenes/Other/dialog.tscn")

func _on_body_entered(body: Node2D) -> void:
	if !activated:
		GameManeger.cutSceene=true
		activated=true
		
		whatToSeePosition=whatToSee.position
		player.process_mode=Node.PROCESS_MODE_DISABLED
		camera.player = whatToSee  # Kamera célpontját átállítjuk
		
		# Tween az első mozgásra
		var tween1 = create_tween()
		tween1.tween_property(camera, "position", whatToSee.position, 1.0)
		await tween1.finished
		
		await get_tree().create_timer(0.5).timeout  # Plusz 1 mp várakozás
		
		# Dialógus megjelenítése
		var new_dialog = dialog.instantiate()
		add_child(new_dialog)
		new_dialog.set_tooltip(Szovegek, GetAchivement, Achivement)
		
		await new_dialog.tree_exited  # Megvárjuk, amíg a dialógus eltűnik
		
		await get_tree().create_timer(0.5).timeout  # Még 1 mp várakozás
		
		camera.player = player  # Visszaállítjuk a kamerát a játékosra
		
		# Új tween létrehozása a visszamozgáshoz
		var tween2 = create_tween()
		tween2.tween_property(camera, "position", player.position, 1.0)
		await tween2.finished
		GameManeger.cutSceene=false
		player.process_mode=Node.PROCESS_MODE_INHERIT
		
		if whatToSeeDisaper:
			whatToSee.queue_free()
			
		for other in others:
			other.queue_free()
		
		if afterSpawn:
			whatToSeePosition.y-=1000
			var instance = whatSpawn.instantiate()
			instance.position = whatToSeePosition
			get_tree().current_scene.add_child(instance)
