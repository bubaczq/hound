extends CharacterBody2D

#Animálciókhoz szükséges változók
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

@onready var achivement=preload("res://scenes/Other/NewAchivement.tscn")

#Képek
@export var lifeFull=Texture2D
@export var lifeEmpty=Texture2D

#Importált nodeok
@onready var DeathHud=$UI/Control/Death
@onready var Life1=$UI/Control/CharacterInfo/Life/Life1
@onready var Life2=$UI/Control/CharacterInfo/Life/Life2
@onready var Life3=$UI/Control/CharacterInfo/Life/Life3
@onready var HealthBar=$UI/Control/CharacterInfo/HealthBar

#Könnyen változtatható változók
@export var JUMP_VELOCITY = -3200.0
@export var maxhp=100
@export var hp=maxhp
@export var attack=false
@export var attackcountinue=true
@export var run_speed=2000
@export var default_speed=1300
@export var DASH_SPEED = 4000.0 # A dash sebessége
@export var DASH_DURATION = 0.4 # A dash időtartama másodpercekben
@export var DASH_COOLDOWN = 1.0 # Időkorlát a dash-olások között (másodpercben)

#szükséges változók
var SPEED = 0
var run=false
var walk=false
var timer=0
var stored_enemy:Area2D
var getting_damage=false
var chainedattack=false
var life=3
var lastDirection=1
var knockback = Vector2(3000, -500)
var knockback_timer = 0.0
var knocked_timer=0.0
#DASH
var is_dashing = false      
var dash_time = 0.0
var dash_direction = 1 # 1 jobbra, -1 balra
var can_dash_in_air = true # Csak egy dash ugrás közben
var dash_cooldown_timer = 0.0 # Visszaszámlálás a dash-ek között

func _ready() -> void:
	#print("Chained Attack kezdeti értéke: ", chainedattack)
	HealthBar.max_value=maxhp
	state_machine=anim_tree["parameters/playback"]

func _process(delta: float) -> void:
	if GameManeger.cutSceene:
		state_machine.start("Idle")
	
	var direction:=Input.get_axis("left","right")
	if knocked_timer<=0.0:
		Move(direction)
		Gravity(delta)
	else:
		velocity=knockback
		
	
	Cursor()
	Camera()
	Life()
	Resets(delta)
	killPlayer()
	UI()
	move_and_slide()

#Sebződés
func GetDamage(hitbox):
	if !GameManeger.dialog:
		var base_damage = hitbox.damage
		hp -= base_damage
		#print(hitbox.get_parent().name+" sebzést adott "+ name+"-nek dmg: "+str(base_damage)+" igy az élete: "+str(hp))

#Sebződés
func _on_hurt_box_area_entered(hitbox: Area2D) -> void:
	if !GameManeger.dialog:
		hp-=hitbox.damage
		
		if knockback_timer<=0.0:
			# Lökés irányának meghatározása
			if hitbox.name!="DeathArea":
				if hitbox.get_parent().global_position.x > $Sprite2D.global_position.x:
					knockback = Vector2(-3000, -500)
				else:
					knockback = Vector2(3000, -500)
				velocity=Vector2(0,0)
				chainedattack=false
				attack=false
				state_machine.start("Idle")
				knockback_timer=1.0
				knocked_timer=0.2

#Animálciók egyéb beállításai
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#print("Animáció befejeződött:", anim_name)
	if str(anim_name)=="Attack_Begin" and chainedattack:
		state_machine.start("Attack_End")
	if str(anim_name)=="Attack_End":
		chainedattack=false
		attack=false
		state_machine.travel("idle")
	if walk and !run:
		state_machine.travel("walk")
	if str(anim_name)=="Attack_Air":
		attack=false
	#print("Chained Attack:", chainedattack)
	#print("Attack:",attack)

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	#print("Animáció elkezdődött:", anim_name)
	if str(anim_name)=="Attack_Begin" or str(anim_name)=="Attack_End":
		attack=true
	if (attack and !chainedattack) or (!attack and chainedattack):
		attack=false
		chainedattack=false

#Meghalás
func killPlayer():
	if hp<=0:
		life=life-1
		if life==0:
			GameManeger.GamePoused=true
			DeathHud.visible=true
			$UI/Control/PouseOption.visible=false
			$UI/Control/Pouse.visible=false
			$UI/Control/BossBar.visible=false
			$UI/Control/CharacterInfo.visible=false
		if GameManeger.localachivements.size()>0:
			if GameManeger.localachivements[4]==false:
				#print("lefut gecc")
				var new_achivement=achivement.instantiate()
				add_child(new_achivement)
				new_achivement.set_tooltip(5)
		GameManeger.DieCounts=GameManeger.DieCounts+1
		position = %RespawnPoint.position
		hp=maxhp
		knocked_timer=0.0
		velocity=Vector2.ZERO

func Camera():
	if Input.is_action_just_pressed("zoom") and GameManeger.zoom==0.2:
		GameManeger.zoom=0.3
	elif Input.is_action_just_pressed("zoom"):
		GameManeger.zoom=0.2

func Cursor():
	if GameManeger.GamePoused:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	else:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func Life():
	if life>=3:
		Life3.texture=lifeFull
	else:
		Life3.texture=lifeEmpty
	if life>=2:
		Life2.texture=lifeFull
	else:
		Life2.texture=lifeEmpty
	if life>=1:
		Life1.texture=lifeFull
	else:
		Life1.texture=lifeEmpty

func Dash():
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0 and !is_on_floor() and can_dash_in_air:
		#print("Dash")
		is_dashing = true
		dash_time = DASH_DURATION
		# A dash iránya az alapján dől el, amerre a karakter néz (flip_h)
		if $Sprite2D.scale.x < 0:
			dash_direction = -1 # Balra dash
		else:
			dash_direction = 1 # Jobbra dash
		velocity.x = dash_direction * DASH_SPEED
		state_machine.travel("Dash")

		# Ha a levegőben dash-elünk, tiltsuk le a további levegőbeli dash-t
		can_dash_in_air = false

		# Dash cooldown aktiválása
		dash_cooldown_timer = DASH_COOLDOWN

func Gravity(delta):
	if !is_on_floor() and !is_dashing:
		velocity += get_gravity() * (delta*1.5)

func Move(direction):
	if direction!=0:
		lastDirection=direction
	
	if !is_on_floor() and Input.is_action_just_pressed("Attack"):
		state_machine.start("Attack_Air")
	
	if attack and Input.is_action_just_pressed("Attack") and str(state_machine.get_current_node()) == "Attack_Begin":
		chainedattack = true
		
	if !attack:
		if !is_on_floor():  # Ha nem a földön van
			if velocity.x > SPEED and direction != 0:
				velocity.x -= 40
			elif velocity.x < -SPEED and direction != 0:
				velocity.x += 40
			elif velocity.x > 0 and direction == 0:
				velocity.x -= 30
			elif velocity.x < 0 and direction == 0:
				velocity.x += 30
		else:
			velocity.x=lastDirection * 100 #Támadásmozgás
		
	if !GameManeger.dialog:
		if direction != 0 and !is_dashing:
			if direction==1:
				if is_on_floor():
					if velocity.x<SPEED:
						velocity.x = direction * SPEED
					if velocity.x>SPEED:
						velocity.x = direction * SPEED
				else:
					if velocity.x<SPEED:
						velocity.x = direction * SPEED
				$Sprite2D.scale.x = 1.5
			else:
				if is_on_floor():
					if velocity.x<SPEED:
						velocity.x = direction * SPEED
				else:
					if velocity.x>-SPEED: 
						velocity.x = direction * SPEED
				$Sprite2D.scale.x = -1.5
				
		elif !is_dashing and is_on_floor() and !attack:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		if Input.is_action_pressed("run"):
			run=true
			walk=false
		else:
			run=false
	# Handle dash - csak ugrás közben
		Dash()
		if Input.is_action_just_pressed("Attack") and is_on_floor() and !attack and !chainedattack:
			state_machine.travel("Attack_Begin")
			attack=true

		if !attack and !chainedattack:
			if velocity.x > 1 and is_on_floor() and !walk and !run:
				state_machine.travel("walk_begin")
				walk=true
			if velocity.x < 1 and is_on_floor() and !walk and !run:
				state_machine.travel("walk_begin")
				walk=true
			if  run and is_on_floor():
				state_machine.travel("Run")
				SPEED=run_speed
			else:
				SPEED=default_speed
			if velocity.x == 0 and is_on_floor():
				state_machine.travel("Idle")
				walk=false

			if Input.is_action_just_pressed("jump") and is_on_floor() and !is_dashing:
				velocity.y = JUMP_VELOCITY
				state_machine.travel("Jump")
			
			if not is_on_floor() and !is_dashing:
				state_machine.travel("Jump")
				walk=false
	

func Resets(delta):
	if knocked_timer>0.0:
		knocked_timer -= delta
	if knockback_timer > 0.0:
		knockback_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if is_dashing:
		velocity.y=0
	if GameManeger.dialog:
		velocity.x=0
		state_machine.travel("Idle")
	if is_on_floor():
		can_dash_in_air=true
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0: 
			is_dashing = false # Véget ér a dash, visszatérünk a normál mozgáshoz

func UI():
	HealthBar.value=hp
	if GameManeger.message!="":
		$UI/Control/CharacterInfo/Message.show()
		$UI/Control/CharacterInfo/Message/MessageText.text=GameManeger.message
	else:
		$UI/Control/CharacterInfo/Message.hide()
	if GameManeger.BossHP!=0:
		$UI/Control/BossBar.show()
		$UI/Control/BossBar/MarginContainer/HealthBar/HealthBarText.text=GameManeger.BossName
		$UI/Control/BossBar/MarginContainer/HealthBar.max_value=GameManeger.BossMaxHP
		$UI/Control/BossBar/MarginContainer/HealthBar.value=GameManeger.BossHP
	else:
		$UI/Control/BossBar.hide()
