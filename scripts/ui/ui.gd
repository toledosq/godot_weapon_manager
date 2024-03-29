extends CanvasLayer

@onready var HUD = $HUD
@onready var INGAME_INTERFACE: InventoryInterface = $IngameInterface

@onready var weapon_name_label = %WeaponNameLabel
@onready var ammo_counter_label = %AmmoCounterLabel
@onready var ammo_reserve_counter_label = %AmmoReserveCounterLabel
@onready var grenade_counter_label = %GrenadeCounterLabel

@onready var health_progress_bar = %HealthProgressBar
@onready var armor_progress_bar = %ArmorProgressBar

@onready var interact_alert_box = %InteractAlertBox
@onready var alert_label = %AlertLabel
@onready var animation_player = $HUD/AnimationPlayer


func _ready():
	EventBus.weapon_equipped.connect(_on_weapon_equipped)
	EventBus.weapon_ammo_changed.connect(update_ammo_counter)
	EventBus.grenade_ammo_changed.connect(update_grenade_counter)
	EventBus.reserve_ammo_changed.connect(update_ammo_reserve_counter)

	EventBus.player_health_updated.connect(update_health_bar)
	EventBus.player_armor_updated.connect(update_armor_bar)
	
	EventBus.display_alert_text.connect(display_alert_text)
	EventBus.interact_ray_colliding.connect(show_interact_alert)
	EventBus.interact_ray_stopped_colliding.connect(hide_interact_alert)


func _on_weapon_equipped(name_):
	weapon_name_label.text = name_


func update_ammo_counter(amount):
	ammo_counter_label.text = str(amount)


func update_grenade_counter(amount):
	grenade_counter_label.text = str(amount)


func update_ammo_reserve_counter(ammo_reserve):
	var weapon_type = PlayerManager.get_ammo_type()
	var amount = ammo_reserve[weapon_type][0]
	ammo_reserve_counter_label.text = str(amount)


func update_health_bar(amount):
	health_progress_bar.value = amount


func update_armor_bar(amount):
	armor_progress_bar.value = amount


func display_alert_text(text):
	alert_label.text = text
	if animation_player.is_playing():
		animation_player.seek(0)
	animation_player.play("display_alert_text")


func show_interact_alert():
	interact_alert_box.show()


func hide_interact_alert():
	interact_alert_box.hide()
