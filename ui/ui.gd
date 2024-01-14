extends CanvasLayer


@onready var active_weapon_label = $HUD/ActiveWeaponLabel


func _ready():
	EventBus.active_weapon_changed.connect(_on_active_weapon_changed)


func _on_active_weapon_changed(index):
	active_weapon_label.text = str(index)
