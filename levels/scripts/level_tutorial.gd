extends Node2D

func _ready() -> void:
	GameManeger.restartSceene="res://levels/level_tutorial.tscn"
	get_tree().connect("about_to_quit", Callable(self, "_on_about_to_quit"))

func _on_about_to_quit():
	GameManeger.mentes()
