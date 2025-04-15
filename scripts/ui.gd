extends CanvasLayer

##Nodeok Változóba szervezése##
@onready var Hud=$Control/CharacterInfo
@onready var Boss=$Control/BossBar
@onready var Pouse=$Control/Pouse
@onready var PouseOption=$Control/PouseOption
#Beállitás Node-k
@onready var volume=$Control/PouseOption/Volume
@onready var VSync=$Control/PouseOption/Sync
@onready var FullScreen=$Control/PouseOption/FullScreen
#Stats
@onready var KilledEntity=$Control/PouseOption/Stats/KilledEntity
@onready var DieCounts=$Control/PouseOption/Stats/DieCounts

#UI Frissitése Másodpercenként töbször
func _process(delta: float) -> void:
	#Stats
	KilledEntity.text="Killed Entity: "+str(GameManeger.KilledEntity)
	DieCounts.text="Die Counts: "+str(GameManeger.DieCounts)
	#
	if GameManeger.BossHP!=0:
		Boss.visible=true
	else:
		Boss.visible=false
	
	if GameManeger.dialog:
		Hud.visible=false
	else:
		Hud.visible=true

	if Input.is_action_just_pressed("pouse") and !GameManeger.GamePoused:
		#print(GameManeger.GamePoused)
		GameManeger.GamePoused=true
		Pouse.visible=true
		PouseOption.visible=false
	elif Input.is_action_just_pressed("pouse") and GameManeger.GamePoused:
		#print(GameManeger.GamePoused)
		GameManeger.GamePoused=false
		PouseOption.visible=false
		Pouse.visible=false

	if GameManeger.GamePoused:
		Engine.time_scale=0
	else:
		Engine.time_scale=1
		Pouse.visible=false

#Kilépés Gomb Megnyomásakor lefutó változók törlése és jelenet betöltése
func _on_exit_pressed() -> void:
	GameManeger.dialog=false
	GameManeger.mentes()
	GameManeger.GamePoused=false
	GameManeger.BossHP=0
	GameManeger.BossMaxHP=0
	GameManeger.BossName=""
	get_tree().change_scene_to_file("res://scenes/MainMenu/map_selection.tscn")

#Megállitás gomb
func _on_game_resoume_pressed() -> void:
	GameManeger.mentes()
	GameManeger.GamePoused=false

#Pálya újra töltése
func _on_load_pressed() -> void:
	GameManeger.mentes()
	GameManeger.GamePoused=false
	get_tree().change_scene_to_file(GameManeger.restartSceene)

#Játék folytatása Gomb
func _on_back_option_pressed() -> void:
	Pouse.visible=true
	PouseOption.visible=false

##Beállítások mentése gomb##
func _on_save_option_pressed() -> void:
	GameManeger.volume=volume.value
	GameManeger.VSync=VSync.button_pressed
	GameManeger.FullScreen=FullScreen.button_pressed
	betoltes()
	option_save()

################################################################################################# Beállítások
func option_save():
	var file = FileAccess.open("user://save_game_option.dat", FileAccess.WRITE)
	var data = {
			"FullScreen": GameManeger.FullScreen,
			"VSync": GameManeger.VSync,
			"volume":GameManeger.volume
		}
	file.store_string(JSON.stringify(data))
	file.close()
func option_load():
	var file_path = "user://save_game_option.dat"
	if not FileAccess.file_exists(file_path):
		#print("A mentett fájl nem létezik. Alapértelmezett beállítások használata.")
		set_default_options()  # Beállítjuk az alapértelmezett értékeket
		return
		
	var file = FileAccess.open("user://save_game_option.dat", FileAccess.READ)
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
			GameManeger.FullScreen = data["FullScreen"]
			GameManeger.VSync = data["VSync"]
			GameManeger.volume = data["volume"]
		#print("Beállítások betöltve!")
		betoltes()
func set_default_options():
	# Alapértelmezett beállítások
	GameManeger.FullScreen = false
	GameManeger.VSync = true
	GameManeger.volume = 100
	#print("Alapértelmezett beállítások beállítva.")
func betoltes():
	volume.value=GameManeger.volume
	VSync.button_pressed=GameManeger.VSync
	FullScreen.button_pressed=GameManeger.FullScreen
	if FullScreen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
	if VSync.button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED) 
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) 
func bealitas():
	volume.value=GameManeger.volume
	VSync.button_pressed=GameManeger.VSync
	FullScreen.button_pressed=GameManeger.FullScreen
#################################################################################################

#Beállitások megjelenitése
func _on_option_pressed() -> void:
	GameManeger.mentes()
	bealitas()
	Pouse.visible=false
	PouseOption.visible=true

func _on_restart_pressed() -> void:
	$Control/Death.visible=false
	GameManeger.mentes()
	GameManeger.GamePoused=false
	get_tree().change_scene_to_file(GameManeger.restartSceene)


func _on_quit_pressed() -> void:
	GameManeger.dialog=false
	GameManeger.mentes()
	GameManeger.GamePoused=false
	GameManeger.BossHP=0
	GameManeger.BossMaxHP=0
	GameManeger.BossName=""
	get_tree().change_scene_to_file("res://scenes/MainMenu/map_selection.tscn")
