extends CanvasLayer

#Előre betölti a következő jelenetet a háttérben
func _ready() -> void:
	ResourceLoader.load_threaded_request(GameManeger.NextScene)

#A hány %-a van már betöltve és ha 100% akkor betölti
func _process(delta: float) -> void:
	var progress=[]
	ResourceLoader.load_threaded_get_status(GameManeger.NextScene,progress)
	
	if progress[0]==1:
		var packed_scene=ResourceLoader.load_threaded_get(GameManeger.NextScene)
		get_tree().change_scene_to_packed(packed_scene)
