extends CanvasLayer

#kiírás
@onready var BestLevelText=$Map/BestLevel

func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

#Vissza a lobby-ba
func _on_back_pressed() -> void:
	GameManeger.BestLevel=0
	GameManeger.WhereBack="saves"
	get_tree().change_scene_to_file("res://scenes/MainMenu/loggin.tscn")

#kiírás beállitásai
func _process(delta: float) -> void:
	BestLevelText.text="Best Level: "+str(GameManeger.BestLevel)
