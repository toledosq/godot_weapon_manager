class_name HealthManager extends Node

@export var MAX_HEALTH: int = 100

var health

func _ready():
	health = MAX_HEALTH


func hit(damage):
	health -= damage
	print("HealthManager: Player Health = ", health)
	EventBus.player_health_updated.emit(health)
	
	if health <= 0:
		on_death()


func on_death():
	print("Player died")
