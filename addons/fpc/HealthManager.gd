class_name HealthManager extends Node

@export var MAX_HEALTH: int = 100

var health: int:
	set(val):
		health = val
		EventBus.player_health_updated.emit(health)

func _ready():
	health = MAX_HEALTH


func hit(damage):
	health -= damage
	print("HealthManager: (HIT) Player Health = ", health)
	EventBus.player_health_updated.emit(health)
	
	if health <= 0:
		on_death()


func on_death():
	print("Player died")


func heal(amount):
	if health < MAX_HEALTH:
		var heal_amount = min(MAX_HEALTH - health, 
							  amount, 
							  MAX_HEALTH)
		
		health += heal_amount
		print("HealthManager: (HEAL) Amount = ", heal_amount)
		
