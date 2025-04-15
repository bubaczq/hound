extends Panel

@export var SaveNumber=1

@onready var have=$Have
@onready var empty=$Empty
@onready var savename=$Have/SaveName

var file_path=""

func _ready() -> void:
	savename.text=str(SaveNumber)

func _process(delta: float) -> void:
	file_path = GameManeger.savename+"/"+str(SaveNumber)+".dat"
	if FileAccess.file_exists(file_path):
		have.visible=true
		empty.visible=false
	else:
		have.visible=false
		empty.visible=true

func _on_new_game_pressed() -> void:
	if not FileAccess.file_exists(file_path):
		var file = FileAccess.open(GameManeger.savename+"/"+str(SaveNumber)+".dat", FileAccess.WRITE)
		var data = {
				"BestLevel": GameManeger.BestLevel
			}
		#print("Új játék jelenlegi legnagyobb szint: ")
		#print(data.BestLevel)
		#print("A tárolt adat a: "+file_path+"-ban található!")
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		#print("Már létezik ez a mentés")
		pass


func _on_delete_pressed() -> void:
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	else:
		#print("A fájl nem létezik.")
		pass


func _on_start_pressed() -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()  # Az egész fájl tartalmának betöltése
		file.close()  # Ne felejtsd el bezárni a fájlt
		var data = JSON.parse_string(content)  # JSON formátumú sztring parse-olása
		if !data :
			#print(data)
			#print(content)
			#print("Hiba az adatok betöltésekor!")
			return
		# A betöltött adatokat a GameManager változókhoz rendeljük
		if typeof(data) == TYPE_DICTIONARY:
			GameManeger.BestLevel = data["BestLevel"]
		#print("Mentés betöltve!")
		GameManeger.courrentsave=SaveNumber
		#print(GameManeger.BestLevel)
		GameManeger.NextScene="res://scenes/MainMenu/map_selection.tscn"
		get_tree().change_scene_to_file("res://scenes/MainMenu/map_selection.tscn")
