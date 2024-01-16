extends CanvasLayer

@onready var weapon_name_label = %WeaponNameLabel
@onready var ammo_counter_label = %AmmoCounterLabel
@onready var ammo_reserve_counter_label = %AmmoReserveCounterLabel

@onready var health_progress_bar = %HealthProgressBar

@onready var alert_label = %AlertLabel
@onready var animation_player = $HUD/AnimationPlayer


func _ready():
	EventBus.active_weapon_changed.connect(_on_active_weapon_changed)
	EventBus.weapon_ammo_changed.connect(update_ammo_counter)
	EventBus.reserve_ammo_changed.connect(update_ammo_reserve_counter)
	EventBus.display_alert_text.connect(display_alert_text)
	EventBus.player_health_updated.connect(update_health_bar)


func _on_active_weapon_changed(index):
	weapon_name_label.text = str(index)


func update_ammo_counter(amount):
	ammo_counter_label.text = str(amount)


func update_ammo_reserve_counter(amount):
	ammo_reserve_counter_label.text = str(amount)


func update_health_bar(amount):
	health_progress_bar.value = amount


func display_alert_text(text):
	alert_label.text = text
	if animation_player.is_playing():
		animation_player.seek(0)
	animation_player.play("display_alert_text")
