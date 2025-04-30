extends Node2D

@onready var achivement=preload("res://scenes/Other/NewAchivement.tscn")

func _ready() -> void:
	var new_achivement=achivement.instantiate()
	add_child(new_achivement)
	new_achivement.set_tooltip(7)
