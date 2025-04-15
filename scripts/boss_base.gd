extends CharacterBody2D

#Animálcióhoz szükséges változók
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

#Könnyen változtatható változók
@export var hp_max = 1000
@export var hp=hp_max
@export var SPEED = 700
@export var attack=false
@export var type="boss"
@export var BossName="Mama"

#Szükséges változók
var movingRight = 1
var canSwitch = true
var playerdistance=0
var stored_player:Node2D
var wandering=true

#state_machine nevezetü változó beállitása
func _ready() -> void:
	state_machine=anim_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
	#Gravitálció a testre
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Test tipusának beállitása és a Game managerrel való komunikálása
	if type=="boss":
		GameManeger.BossHP=hp
		GameManeger.BossName=BossName
		GameManeger.BossMaxHP=hp_max
	#Mozgás
	if wandering:
		if !$RayCast2D.is_colliding() and canSwitch:
			movingRight *= -1
			canSwitch = false 
		else:
			canSwitch = true 
	else:
		SPEED=800
		if stored_player.position.x-position.x<(700*$".".scale.x) and stored_player.position.x-position.x>((700*$".".scale.x)*-1):
			state_machine.travel("EnemyAttack")
			attack=true
			if stored_player.position.x-position.x<=0:
				$Sprite2D.scale.x = -1
			else:
				$Sprite2D.scale.x = 1
		elif stored_player.position.x-position.x<=0:
			movingRight = -1
		else:
			movingRight = 1
	#Támadás mozgásának beállitásai és mozgás animálcióinak beállitásai
	if attack:
		velocity.x=0
	else:
		if movingRight < 0:
			state_machine.travel("Run")
			$Sprite2D.scale.x = -1
			velocity.x = SPEED * $Sprite2D.scale.x
			$RayCast2D.target_position = Vector2(-270,2000)
		else:
			state_machine.travel("Run")
			$Sprite2D.scale.x = 1
			velocity.x = SPEED * $Sprite2D.scale.x
			$RayCast2D.target_position = Vector2(270,2000)
	#Meghalás
	if hp<=0:
		die()
	move_and_slide()

func die():
	GameManeger.KilledEntity=GameManeger.KilledEntity+1
	GameManeger.BossHP=0
	#print("A karakter meghalt!")
	queue_free() 

#Sebzés
func _on_hurt_box_area_entered(hitbox: Area2D) -> void:
	var base_damage=hitbox.damage
	hp-=base_damage
	#print(hitbox.get_parent().name+" sebzést adott "+ name+"-nek dmg: "+str(base_damage)+" igy az élete: "+str(hp))

#Játékos észlelése
func _on_detect_area_body_entered(body: Node2D) -> void:
	stored_player=body
	wandering=false
	#print("látlak")

#Sebződés
func _on_hit_box_body_entered(body: Node2D) -> void:
	body.hp-=$Sprite2D/HitBox.damage
