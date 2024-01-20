extends InventoryInterface

@onready var armor_bar = %ArmorBar
@onready var health_bar = %HealthBar
@onready var stamina_bar = %StaminaBar


func _ready():
	EventBus.player_health_updated.connect(update_player_health_bar)
	EventBus.player_armor_updated.connect(update_player_armor_bar)


func update_player_armor_bar(amount):
	armor_bar.value = amount


func update_player_health_bar(amount):
	health_bar.value = amount


func update_player_stamina_bar(amount):
	stamina_bar.value = amount
