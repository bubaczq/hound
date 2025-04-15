extends CanvasLayer

#Szükséges változók
var skip=false
var dialog=false
var parbeszedek=0
var kapottparbeszedek=[]
var speek=false

#Könnyen változtatható változók
@export var display_time = 3.0
@export var text_speed = 0.05  

#Achivement jelent betöltése ha szükség lenne rá
@export var achivement = preload("res://scenes/Other/NewAchivement.tscn")

#Node-ok változóba szervezése
@onready var dialog_control = $Control

var dialog_label=null
var character_sprite=null
var name_panel=null
var name_label=null

# A dialógus megjelenítése
func show_dialog(character_texture: Texture2D, text: String, character_name: String, direction: int) -> void:
	$Control/Left.visible=false
	$Control/Right.visible=false
	if direction==0:
		$Control/Right.visible=true
		dialog_label = $Control/Right/PanelContainer/dialog/Text
		character_sprite = $Control/Right/AspectRatioContainer/Caracter
		name_panel = $Control/Right/PanelContainer/dialog 
		name_label = $Control/Right/PanelContainer/dialog/Name
	else:
		$Control/Left.visible=true
		dialog_label = $Control/Left/PanelContainer/dialog/Text
		character_sprite = $Control/Left/AspectRatioContainer/Caracter
		name_panel = $Control/Left/PanelContainer/dialog 
		name_label = $Control/Left/PanelContainer/dialog/Name
	GameManeger.dialog=true
	skip=false
	dialog=true
	speek=true
	#print("show_dialog hívva")  # Debug üzenet
	
	if dialog_control == null:
		#print("dialog_control nem található!")
		return
	
	if character_texture!=null:
		character_sprite.texture = character_texture
		character_sprite.visible=true
	else:
		character_sprite.visible=false
	
	# Karakter neve megjelenítése
	name_label.text = character_name

	dialog_label.text = ""
	var i = 0
	
	while i < text.length():
		if skip:
			dialog_label.text=text
			skip=false
			break
		else:
			dialog_label.text += text[i]
			i += 1
			await get_tree().create_timer(text_speed).timeout 

	if text!=dialog_label.text:
		speek=true;
	else:
		speek=false


#Skipelhetőség
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		skip=true
	if !dialog and kapottparbeszedek.size()>parbeszedek:
		str(kapottparbeszedek[parbeszedek].split(":")[0])
		show_dialog(load("res://assets/pngs/"+str(kapottparbeszedek[parbeszedek].split(":")[1])+".png") as Texture2D, str(kapottparbeszedek[parbeszedek].split(":")[3]), str(kapottparbeszedek[parbeszedek].split(":")[2]), int(kapottparbeszedek[parbeszedek].split(":")[0]))
		parbeszedek=parbeszedek+1
	if parbeszedek>kapottparbeszedek.size():
		dialog=false
		dialog_control.visible=false
		#print("Eltuntek a kiirások")
	if !speek and Input.is_action_just_pressed("skip"):
		dialog=false
		if kapottparbeszedek.size()==parbeszedek:
			GameManeger.dialog=false
			queue_free()
			

#Ha meghivják egy jelenetbe a kaott paraméterek alapján jeleneti meg
func set_tooltip(Parbeszedek: Array,GetAchivement: bool,Achivement:int):
	dialog_control.visible = true
	if Parbeszedek.size()<1:
		#print("Nem kaptam semilyen adatot")
		return
	kapottparbeszedek=Parbeszedek
	if GetAchivement:
		var new_achivement=achivement.instantiate()
		add_child(new_achivement)
		new_achivement.set_tooltip(Achivement)
	
