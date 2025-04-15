extends Node2D

#Panelek
@onready var Background=$UI/MainMenuBackground
@onready var Video=$UI/VideoStreamPlayer
@onready var login=$UI/Control/Login
@onready var user=$UI/Control/User
@onready var lobby=$UI/Control/Lobby
@onready var achivements=$UI/Control/Achivements
@onready var options=$UI/Control/Options
@onready var saves=$UI/Control/Saves

#Beállitásokhoz
@onready var volume=$UI/Control/Options/Panel/Volume
@onready var VSync=$UI/Control/Options/Panel/Sync
@onready var FullScreen=$UI/Control/Options/Panel/FullScreen
#Stats
@onready var KilledEntity=$UI/Control/Options/Panel/Stats/KilledEntity
@onready var DieCounts=$UI/Control/Options/Panel/Stats/DieCounts

#Egyébb kiírások
@onready var achivement_message=$UI/Control/Achivements/Message
@onready var Error=$UI/Control/Login/VBoxContainer/Errors
@onready var achivements_label=preload("res://scenes/MainMenu/achivement.tscn")
@onready var achivements_grid=$UI/Control/Achivements/GridContainer
@onready var http_request=$HTTPRequest
@onready var email=$UI/Control/Login/VBoxContainer/Email_text
@onready var psw=$UI/Control/Login/VBoxContainer/Password_text

#Jelenetek importálása
@export var achivement = preload("res://scenes/Other/NewAchivement.tscn")

# szükséges változók
var errorText="Hibás felhasználó vagy jelszó!"
var megkeredezve=false
var hova=""
var keres=""
var tomb=""
var keresett=false
var betoltve=false
var adatok=false
var videopoused=false
var pressanikey=false
var stream=""

#Backend végpontok
var backend_url_login = "/api/auth/login"
var backend_url_user="/api/user/userprofile"
var backend_url_achivements="/api/achievements/userachievements"
var backend_url_all_achivements="/api/achievements/all"

func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	Video.stream=load("res://assets/videos/menu/LOGOK.ogv")
	Video.play()
	stream="LOGOK"
	if GameManeger.BetoltesVideo:
		stream=""
		Video.stream=load("res://assets/videos/menu/END.ogv")
		Video.play()
		Video.paused=true
		$UI/Control.visible=true
	option_load()
	betoltes()
	if GameManeger.WhereBack!="":
		if GameManeger.WhereBack=="user":
			megjelenites(user)
	if GameManeger.szerverIp=="":
		GameManeger.szerverIp="http://127.0.0.1:6000"
	backend_url_login=GameManeger.szerverIp+backend_url_login
	backend_url_user=GameManeger.szerverIp+backend_url_user
	backend_url_achivements=GameManeger.szerverIp+backend_url_achivements
	backend_url_all_achivements=GameManeger.szerverIp+backend_url_all_achivements
	megjelenites(lobby)
	if GameManeger.loggedin:
		megjelenites(user)
	if not http_request.request_completed.is_connected(_on_request_completed):
		http_request.request_completed.connect(_on_request_completed)

func _process(_delta: float) -> void:
	####################################################### Video skip
	if stream=="MENU" and Input.is_action_just_pressed("skip"):
		stream=""
		Video.stream=load("res://assets/videos/menu/END.ogv")
		Video.play()
		Video.paused=true
		$UI/Control.visible=true
	elif stream=="LOGOK" and Input.is_action_just_pressed("skip"):
		stream="LOOP"
		Video.stream=load("res://assets/videos/menu/LOOP.ogv")
		Video.play()
		Video.paused=true
		$UI/VideoStreamPlayer/pressanykey.visible=true
		GameManeger.BetoltesVideo=true
	elif stream=="LOOP" and Input.is_action_just_pressed("skip"):
		Video.paused=false
		Video.stream=load("res://assets/videos/menu/MENU.ogv")
		Video.play()
		stream="MENU"
		$UI/VideoStreamPlayer/pressanykey.visible=false
		$Timer.start()
		
	
	####################################################### Stat
	KilledEntity.text="Killed Entity: "+str(GameManeger.KilledEntity)
	DieCounts.text="Die Counts: "+str(GameManeger.DieCounts)
	######################################################## Teljesítmény megszerzése ha belép
	if user.visible and !megkeredezve and adatok:
		megkeredezve=true
	######################################################### Játékos adatainak lekérdezése
	if GameManeger.token!="" and GameManeger.uid==0 and keres!="jatekosadat":
		keres="jatekosadat"
		var headers = [
			"Content-Type: application/json",
			"Cookie: auth_token=" + GameManeger.token
		]  # JSON típusú adat
		var error = http_request.request(backend_url_user, headers)
		if error != OK:
			#print("Kérés hibája:", error)
			pass
		else:
			#print("kérés küldve")
			pass
	######################################################### Minden teljesítmény lekérdezése
	if keres=="mindenteljesitmeny" and !keresett:
		keresett=true
		var headers = [
			"Content-Type: application/json",
		]  # JSON típusú adat

		var error = http_request.request(backend_url_all_achivements, headers)
		if error != OK:
			#print("Kérés hibája:", error)
			pass
		else:
			#print("kérés küldve")
			pass
	######################################################### Játékos teljesitményének lekérdezése
	if keres=="teljesitmeny" and !keresett:
		var headers = [
			"Content-Type: application/json",
			"Cookie: auth_token=" + GameManeger.token
		]  # JSON típusú adat
		var error = http_request.request(backend_url_achivements, headers)
		if error != OK:
			match error:
				HTTPRequest.RESULT_CONNECTION_ERROR:
					#print("Kapcsolódási hiba!")
					pass
				HTTPRequest.RESULT_CANT_RESOLVE:
					#print("DNS nem található!")
					pass
				HTTPRequest.RESULT_CANT_CONNECT:
					#print("Nem lehet csatlakozni a szerverhez!")
					pass
		else:
			#print("kérés küldve")
			pass
	######################################################### Ha a Game manager whereback nem üres
	if GameManeger.WhereBack!="":
		if GameManeger.WhereBack=="user":
			GameManeger.WhereBack=""
			megjelenites(user)
		if GameManeger.WhereBack=="saves":
			GameManeger.WhereBack=""
			megjelenites(saves)

func _on_login_button_pressed() -> void:
	keres="login"	
	#print(email.text," ",psw.text)
	http_request.request_completed.connect(_on_request_completed)  # Csatlakoztatjuk az eseményt
	var login_data_to_send = {
		"email": email.text,
		"psw": psw.text
	}
	# JSON konvertálás
	var json_data = JSON.stringify(login_data_to_send)
	var headers = ["Content-Type: application/json"]  # JSON típusú adat
	# Kérés küldése a backend URL-re, JSON adatokkal
	var error = http_request.request(backend_url_login, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		#print("Kérés hibája:", error)
		pass
	else:
		#print("kérés küldve")
		pass

######################################################### Ha kérést kap a szerverre való csatlakozásra lefut
func _on_request_completed(result, response_code, headers, body):
	#print("kérés érkezett: ",keres)
	if response_code == 200:
		var response_data = JSON.parse_string(body.get_string_from_utf8())
		if response_data != null:
			#print("Sikeres válasz:", response_data)
			GameManeger.loggedin=true
			##################################
			if keres=="teljesitmeny":
				GameManeger.earenedachivements.clear()
				if response_data.size()!=0 and typeof(response_data)==TYPE_ARRAY:
					for i in response_data:
						#print("teljesitmenyeim")
						#print(response_data)
						GameManeger.localachivements[(i.aid-1)]=true
						GameManeger.earenedachivements.append(str(i.aid)+";"+i.achievement+";"+i.description)
				#print(GameManeger.earenedachivements)
				keresett=false
				keres=""
				if GameManeger.localachivements[0]==false:
					var new_achivement=achivement.instantiate()
					add_child(new_achivement)
					new_achivement.set_tooltip(1)
			##################################
			if keres=="mindenteljesitmeny":
				GameManeger.localachivements.clear()
				GameManeger.achivements.clear()
				for i in response_data:
					GameManeger.localachivements.append(false)
					GameManeger.achivements.append(str(i.aid)+";"+i.achievement+";"+i.description)
				#print(GameManeger.achivements)
				keres=""
				keresett=false
				adatok=true
				save_load()
				keres="teljesitmeny"
			####################################
			if response_data.has("token"):
				GameManeger.token=response_data.token
				#print(GameManeger.token,"\nElmentve!")
			####################################
			elif keres=="jatekosadat":
				if response_data.has("uid"):
					GameManeger.uid=response_data.uid
					#print(GameManeger.uid,"\nElmentve!")
				if response_data.has("username"):
					GameManeger.username=response_data.username
					#print(GameManeger.username,"\nElmentve!")
					megjelenites(user)
					keres="mindenteljesitmeny"
		else:
			#print("Válasz:", response_data)
			pass
	else:
		#print("HTTP hiba kód:", response_code)
		Error.text=errorText
		email.text=""
		psw.text=""

func _on_login_pressed() -> void:
	#print("megnyomtad")
	megjelenites(login)
	Error.text=""
	GameManeger.Guest=false

func megjelenites(megjelenitendo):
	login.visible=false
	user.visible=false
	lobby.visible=false
	saves.visible=false
	achivements.visible=false
	options.visible=false
	megjelenitendo.visible=true

func _on_back_login_pressed() -> void:
	#print("megnyomtad")
	megjelenites(lobby)

func _on_exit_pressed() -> void:
	email.text=""
	psw.text=""
	betoltve=false
	GameManeger.earenedachivements.clear()
	GameManeger.achivements.clear()
	GameManeger.token=""
	GameManeger.username=""
	GameManeger.uid=0
	megjelenites(lobby)

func _on_achivments_pressed() -> void:
	#print(GameManeger.localachivements)
	megjelenites(achivements)
	if GameManeger.Guest:
		achivement_message.visible=true
		for child in achivements_grid.get_children():
			achivements_grid.remove_child(child)
			child.queue_free()
	else:
		achivement_message.visible=false
		######################################################### szenvedés volt
		if !betoltve and GameManeger.achivements.size()!=0:
			#print(GameManeger.achivements)
			for child in achivements_grid.get_children():
				achivements_grid.remove_child(child)
				child.queue_free()
			for i in GameManeger.achivements:
				#print(i)
				var new_label=achivements_label.instantiate()
				achivements_grid.add_child(new_label)
				new_label.set_tooltip(str(i.split(";")[1]),str(i.split(";")[2]),int(i.split(";")[0]))
			betoltve=true
			#print(achivements_grid.get_child_count())

func _on_back_pressed() -> void:
	megjelenites(user)

func _on_game_pressed() -> void:
	megjelenites(saves)

func _on_registration_pressed() -> void:
	OS.shell_open("https://wrathhound.netlify.app/reg.html")

func _on_option_pressed() -> void:
	bealitas()
	megjelenites(options)

func _on_back_option_pressed() -> void:
	megjelenites(user)

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
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED) 
	if VSync.button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED) 
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) 
func bealitas():
	volume.value=GameManeger.volume
	VSync.button_pressed=GameManeger.VSync
	FullScreen.button_pressed=GameManeger.FullScreen
################################################################################################# Beállítások Vége

func _on_guest_pressed() -> void:
	save_load()
	GameManeger.Guest=true
	megjelenites(user)

func _on_close_pressed() -> void: 
	get_tree().quit()

################################################################################################# Mentés
func save_load():
	var savename = ""
	if GameManeger and GameManeger.uid != 0:
		savename = "user://saves/" + str(GameManeger.uid)
	else:
		savename = "user://saves/guest"

	#print("Mentési könyvtár elérési út:", savename)

	var dir = DirAccess.open("user://")

	
	
	# Ellenőrizzük és létrehozzuk a "saves" mappát, ha nem létezik
	if not dir.dir_exists("user://saves"):
		dir.make_dir("user://saves")
		#print("A 'saves' mappa létrehozva!")
	else:
		#print("A 'saves' mappa már létezik!")
		pass

	# Ellenőrizzük és létrehozzuk a játékos egyéni mentési mappáját
	if not dir.dir_exists(savename):
		dir.make_dir(savename)
		#print(savename, " mappa létrehozva!")
	else:
		#print(savename, " mappa már létezik!")
		pass
	
	if !FileAccess.file_exists(savename+"/stat.dat"):
		var file = FileAccess.open(savename+"/stat.dat", FileAccess.WRITE)
		var data = {
				"TalkedNpc":0,
				"KilledEntity": 0,
				"DieCounts": 0
			}
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		var file = FileAccess.open(savename+"/stat.dat", FileAccess.READ)
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
				#print(data)
				
				GameManeger.TalkedNpc=int(data["TalkedNpc"])
				GameManeger.KilledEntity = int(data["KilledEntity"])
				GameManeger.DieCounts = int(data["DieCounts"])
	
	
	GameManeger.savename=savename

func _on_saves_back_pressed() -> void:
	megjelenites(user)

func _on_timer_timeout() -> void:
	#print("szarok")
	if stream!="":
		stream=""
		Video.stream=load("res://assets/videos/menu/END.ogv")
		Video.play()
		Video.paused=true
		GameManeger.BetoltesVideo=true
		$UI/Control.visible=true


func _on_video_stream_player_finished() -> void:
	if stream=="LOGOK":
		stream="LOOP"
		Video.stream=load("res://assets/videos/menu/LOOP.ogv")
		Video.play()
		Video.paused=true
		$UI/VideoStreamPlayer/pressanykey.visible=true
		GameManeger.BetoltesVideo=true


func _on_web_pressed() -> void:
	OS.shell_open("https://wrathhound.netlify.app/index.html")
