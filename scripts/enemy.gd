extends CharacterBody2D

#Változóba szervezett Node-ok
@onready var enemy=$"."
@onready var hitbox=$HitBox
@onready var WallChecker=$WallChecker
@onready var GroundChecker=$GroundChecker
@onready var achivement=preload("res://scenes/Other/NewAchivement.tscn")

#könnyen változtatható változók
@export var hp_max = 100
@export var hp=hp_max

#Szükséges változók
const SPEED = 400.0
var movingRight = 1
var canSwitch = true
var saved_player:Node2D
var playerdistance=0
var stored_player:Area2D
var ellenorizve=false
var died=false


func _physics_process(delta: float) -> void:
	#Gravitálció
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Mozgás
	if (!GroundChecker.is_colliding() or WallChecker.is_colliding()) and canSwitch:
		movingRight *= -1
		canSwitch = false 
	else:
		canSwitch = true 
	if movingRight < 0:
		velocity.x = SPEED * -1.0
		WallChecker.target_position=Vector2(-200,0)
		GroundChecker.target_position = Vector2(-270,250)
	else:
		velocity.x = SPEED * 1.0
		WallChecker.target_position=Vector2(200,0)
		GroundChecker.target_position = Vector2(270,250)
	#Meghalás
	if hp<=0:
		die()
	move_and_slide()

#Támadás
func attack():
	$HitBox/CollisionShape2D.disabled=false
	await get_tree().create_timer(0.2).timeout
	$HitBox/CollisionShape2D.disabled=true

func die():
	if !died:
		GameManeger.KilledEntity=GameManeger.KilledEntity+1
		died=true
		hitbox.process_mode=Node.PROCESS_MODE_DISABLED
		enemy.visible=false
	if GameManeger.localachivements.size()>0:
		if GameManeger.localachivements[3]==false and !ellenorizve:
			ellenorizve=true
			#print("lefut gecc")
			var new_achivement=achivement.instantiate()
			add_child(new_achivement)
			new_achivement.set_tooltip(4)
			hitbox.process_mode=Node.PROCESS_MODE_DISABLED
			enemy.visible=false
	else:
		hitbox.process_mode=Node.PROCESS_MODE_DISABLED
		enemy.visible=false
		

#Sebződés
func _on_hurt_box_area_entered(hitbox: Area2D) -> void:
	var base_damage=hitbox.damage
	hp-=base_damage
	print(hitbox.get_parent().name+" sebzést adott "+ name+"-nek dmg: "+str(base_damage)+" igy az élete: "+str(hp))

#Sebzés
func _on_timer_timeout() -> void:
	if $HitBox/CollisionShape2D.disabled:
		$HitBox/CollisionShape2D.disabled=false
	else:
		$HitBox/CollisionShape2D.disabled=true
