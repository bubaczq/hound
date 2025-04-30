extends Panel

#A node-ok változóba helyezése
@onready var tooltip_label =$Text
@onready var panel=$"."
@onready var icon=$icon

#Gomb stílusainak betöltése
@onready var default=preload("res://tres/achivement.tres")
@onready var ok=preload("res://tres/achivement_ok.tres")

#Könnyen változtatható adatok
@export var cim="Teszt"
@export var szoveg="Teszt"
@export var ikon="ellenfel"

func _ready():
	tooltip_label.text=cim.to_upper()+"\n\n\t"+szoveg
	tooltip_label.visible = false
	

func _on_mouse_entered():
	tooltip_label.visible = true
	update_tooltip_position()

func _on_mouse_exited():
	tooltip_label.visible = false

#Szöveg mutatása ha a tooptip látható
func _process(delta):
	if tooltip_label.visible:
		update_tooltip_position()

func update_tooltip_position():
	tooltip_label.position = get_local_mouse_position() + Vector2(55, 85)

func update_tooltip_text():
	tooltip_label.text = cim.to_upper() + "\n\n\t" + szoveg

func set_tooltip(cim_new: String, szoveg_new: String, AID_new: int):
	#szükséges változók
	cim = cim_new
	szoveg = szoveg_new
	var found=false
	
	#Ellenőrzi hogy megvan-e
	for i in GameManeger.earenedachivements:
		if int(i.split(';')[0])==AID_new:
			found=true
			break

	#Ha megvan az achivement akkor zöld
	match AID_new:
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
	#"res://assets/achivements/active/ellenfel_aktiv.png"
	if found:
		panel.theme=ok
		panel.add_theme_stylebox_override("panel",ok)
		if ikon!="":
			icon.visible=true
			icon.texture=load(iconutvonal+"active/"+ikon+"_aktiv.png")
		else: 
			icon.visible=false
	else:
		panel.theme=default
		panel.add_theme_stylebox_override("panel",default)
		if ikon!="":
			icon.visible=true
			icon.texture=load(iconutvonal+"inactive/"+ikon+"_inaktiv.png")
		else: 
			icon.visible=false
	update_tooltip_text()
