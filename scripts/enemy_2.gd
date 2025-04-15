extends CharacterBody2D

#Változóba szervezett Node-ok
@onready var WallChecker=$WallChecker
@onready var GroundChecker=$GroundChecker
@onready var JumpChecker=$JumpChecker

#Animálcióhoz szükséges változók
@onready var anim_tree: AnimationTree = $AnimationTree
var state_machine

#Könnyen változtathato változók
@export var hp_max = 80
@export var hp=hp_max
@export var SPEED = 1600 
@export var attack= false

#Szükséges változók
var death=false
var movingRight = 1
var canSwitch = true
var playerdistance=0
var stored_player:Node2D
var wandering=true

#Animálció változó beállítása
func _ready() -> void:
	state_machine=anim_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
	#Meghalás
	if hp<=0 and !death:
		death=true
		state_machine.start("death")
	elif !death:
		#Gravitálció a testre
		if not is_on_floor():
			velocity += get_gravity() * delta
		#Mozgás
		if wandering:
			if (!GroundChecker.is_colliding() or WallChecker.is_colliding()) and canSwitch:
				movingRight *= -1
				canSwitch = false 
			else:
				canSwitch = true 
		else: #Ha a játékost észlelte akkor felé megxy és megtámadja
			if stored_player.position.x-position.x<500 and stored_player.position.x-position.x>-500:
				state_machine.travel("attack")
				attack=true
				if stored_player.position.x-position.x<=0:
					$Sprite2D.scale.x = -74
				else:
					$Sprite2D.scale.x = 74
			elif stored_player.position.x-position.x<=0:
				movingRight = -1
			else:
				movingRight = 1
		#Animálciók és egyébb mozgások
		if attack:
			velocity.x=0
		else:
			if !wandering and WallChecker.is_colliding() and !JumpChecker.is_colliding():
				velocity.y=-2000
			elif !wandering and WallChecker.is_colliding() and JumpChecker.is_colliding():
				wandering=true
			if movingRight < 0:
				state_machine.travel("run")
				$Sprite2D.scale.x = -74
				velocity.x = -SPEED
				JumpChecker.target_position=Vector2(-3500,-2500)
				WallChecker.target_position=Vector2(-2500,0)
				GroundChecker.target_position = Vector2(-2000,2000)
			else:
				state_machine.travel("run")
				$Sprite2D.scale.x = 74
				velocity.x = SPEED
				JumpChecker.target_position=Vector2(3500,-2500)
				WallChecker.target_position=Vector2(2500,0)
				GroundChecker.target_position = Vector2(2000,2000)
		move_and_slide()

func die():
	GameManeger.KilledEntity=GameManeger.KilledEntity+1
	#print("A karakter meghalt!")
	queue_free() 

#Sebződés
func _on_hurt_box_area_entered(hitbox: Area2D) -> void:
	var base_damage=hitbox.damage
	hp-=base_damage
	if hp>0:
		state_machine.start("gethit")
	#print(hitbox.get_parent().name+" sebzést adott "+ name+"-nek dmg: "+str(base_damage)+" igy az élete: "+str(hp))

#Játékos észlelése
func _on_detect_area_body_entered(body: Node2D) -> void:
	stored_player=body
	wandering=false
	#print("látlak")

#Sebzés
func _on_hit_box_body_entered(body: Node2D) -> void:
	body.hp-=$Sprite2D/HitBox.damage


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if str(anim_name)=="death":
		queue_free()
