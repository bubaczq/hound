extends Camera2D

@export var player: Node2D  # Játékos referenciája
@export var follow_speed: float = 5.0  # Követési sebesség
@export var camera_offset_y: float = -400  # Kamera eltolás Y tengelyen
@export var look_ahead_distance: float = 1000  # Mennyivel nézzen előre a kamera
@export var zoom_speed=5.0

var direction=0
var lookdown=false
var zooming=false

func _process(delta: float) -> void:
	if player.name == "Player":
		# Nézési irány meghatározása (ha van velocity, akkor abból számoljuk)
		var look_ahead_x = 0  # Alapértelmezett érték (ha a karakter áll, ne mozduljon a kamera előre)
		if player.velocity.x > 0:  # Jobbra néz
			direction=1
		elif player.velocity.x < 0:  # Balra néz
			direction=-1
			
		look_ahead_x=look_ahead_distance*direction
		
		if Input.is_action_pressed("lookdown"):
			camera_offset_y=200
		else:
			camera_offset_y=-600

		# Kiszámoljuk a célpozíciót: a játékos felett és nézési irányában
		var target_position = player.global_position + Vector2(look_ahead_x, camera_offset_y)

		# Simán interpoláljuk a kamerát a célpozícióhoz
		global_position = global_position.lerp(target_position, 1 - exp(-follow_speed * delta))
		
	elif GameManeger.cutSceene:
		var target_position = player.global_position
		# Simán interpoláljuk a kamerát a célpozícióhoz
		global_position = global_position.lerp(target_position, 1 - exp(-follow_speed * delta))
		
	if Vector2(GameManeger.zoom, GameManeger.zoom) != $".".zoom:
		$".".zoom = $".".zoom.lerp(Vector2(GameManeger.zoom, GameManeger.zoom), zoom_speed * delta)
