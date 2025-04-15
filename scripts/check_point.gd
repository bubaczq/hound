extends Area2D

@export var GetAchivement=false
@export var Achivement=0

#Achivement jelent betöltése ha szükség lenne rá
@export var achivement = preload("res://scenes/Other/NewAchivement.tscn")

func _on_body_entered(body: Node2D) -> void:
	%RespawnPoint.position=position
	#print("láttam átraktam")
	if GetAchivement:
		var new_achivement=achivement.instantiate()
		add_child(new_achivement)
		new_achivement.set_tooltip(Achivement)
		$Sprite2D.visible=false
		await new_achivement.tree_exited
		
		queue_free()
	else:
		queue_free()
	
