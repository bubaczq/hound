extends Node2D

#Animálcióhoz szükséges változók
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

#Node-ok változóba szervezése
@onready var control=$UI/Control
@onready var Achivement_name=$UI/Control/MarginContainer/Achivement/Achivement_name
@onready var Text=$UI/Control/MarginContainer/Achivement/Text
@onready var http_request=$HTTPRequest
@onready var icon=$UI/Control/MarginContainer/Achivement/icon

#Szükséges változók
var megvan=false
var van=false
@onready var ok=false
var nev=""
var kiiras=""
var ikon="ellenfel"

#Backend végpontok
var backend_url_achivement = "/api/achievements/addachievement"
var backend_url_melyachivement = "/api/achievements/achievement/"

#Könnyen változtatható változók
@export var lathato=true
@export var Achivement_Id=0 #amit megkap

func _ready() -> void:
	state_machine=anim_tree["parameters/playback"]
	if GameManeger.szerverIp=="":
		GameManeger.szerverIp="http://127.0.0.1:6000"
	backend_url_achivement=GameManeger.szerverIp+backend_url_achivement
	backend_url_melyachivement=GameManeger.szerverIp+backend_url_melyachivement
	if not http_request.request_completed.is_connected(_on_request_completed):
		http_request.request_completed.connect(_on_request_completed)
	

#A Kinézetének beállítása ha megvannak az adatok hozzá
func _process(delta: float) -> void:
	Achivement_name.text=nev
	Text.text=kiiras
	if ok:
		#print("Kérés küldve melyik achivement!")
		var headers1 = ["Content-Type: application/json"]
		var lekeresurl=backend_url_melyachivement+str(Achivement_Id)
		#print(lekeresurl)
		var error2 = http_request.request(lekeresurl, headers1)
		if error2 != OK:
			#print("Kérés hibája:", error2)
			pass
		else:
			#print("kérés küldve")
			pass
		ok=false
	if state_machine.get_current_node()=="End":
		queue_free()

#A kapott kérést a backendel lekomunikálja és a kapott adatokkal való szervezkedés
func _on_request_completed(result, response_code, headers, body):
	#print("Új achivement érkezett Id-je: ",Achivement_Id)
	if response_code == 200:
		var response_data = JSON.parse_string(body.get_string_from_utf8())
		#print("Sikeres válasz:", response_data)
		if response_data != null:
			if response_data.size()!=0 and typeof(response_data)==TYPE_ARRAY:
				GameManeger.earenedachivements.append(str(response_data[0].aid)+";"+response_data[0].achievement+";"+response_data[0].description)
				nev=response_data[0].achievement
				kiiras=response_data[0].description
				#print("név: ",nev)
				#print("kiirás: ",kiiras)
				state_machine.travel("Achivement_got")
				control.visible=true
			else:
				ok=true
		else:
			#print("Válasz:", response_data)
			pass
	else:
		#print("HTTP hiba kód:", response_code)
		pass
	
	
	if !lathato:
		queue_free()

#Ha meghívásra kerül akkor a backendel való komunikálás 
func set_tooltip(Id: int):
	if !GameManeger.Guest:
		#print("megérkezett id: "+str(Id))
		match Id:
			1:
				ikon="udv"
			2:
				ikon="kaland"
			3:
				ikon="lepesek"
			4:
				ikon="ellenfel"
			5:
				ikon="elsohalal"
			6:
				ikon="elsotalalkozas"
			7:
				ikon="gyozdle"
			8:
				ikon="KIZ"
			_:
				ikon=""
		var iconutvonal="res://assets/achivements/"
		Achivement_Id=Id
		if GameManeger.earenedachivements.size()!=0:
			for i in GameManeger.earenedachivements:
				if int(i.split(';')[0])==Achivement_Id:
					#print("ez már megvan!")
					megvan=true
					break
				else:
					for j in GameManeger.achivements:
						if Achivement_Id==int(j.split(';')[0]):
							van=true
							break;
						else:
							van=false
		else:
			for j in GameManeger.achivements:
				if Achivement_Id==int(j.split(';')[0]):
					van=true
					break;
				else:
					van=false
		if megvan:
			queue_free()
		if van:
			if ikon!="":
				icon.visible=true
				icon.texture=load(iconutvonal+"base/"+ikon+"_kor.png")
			else: 
				icon.visible=false
			
			##################################################
			var headers = [
				"Content-Type: application/json",
				"Cookie: auth_token=" + GameManeger.token
			]
			#print(GameManeger.uid," ",Achivement_Id)
			http_request.request_completed.connect(_on_request_completed)  # Csatlakoztatjuk az eseményt
			var achivement_data_to_send = {
				"aid": Achivement_Id
			}
			# JSON konvertálás
			var json_data = JSON.stringify(achivement_data_to_send)
			# Kérés küldése a backend URL-re, JSON adatokkal
			var error1 = http_request.request(backend_url_achivement, headers, HTTPClient.METHOD_POST, json_data)
			if error1 != OK:
				#print("Kérés hibája:", error1)
				pass
			else:
				#print("kérés küldve: ",achivement_data_to_send)
				pass
		else:
			#print("Nincs ilyen achivement vagy már megvan!")
			queue_free()
