extends Node

signal add_weapon(index)
signal remove_weapon(index)
signal set_active_player(active_player)

signal active_weapon_changed(index)
signal weapon_fired()
signal weapon_reloaded()
signal weapon_ammo_changed(amount)
signal reserve_ammo_changed(amount)

signal player_health_updated(health)
signal player_died()

signal display_alert_text(text)
