extends Node3D

@onready var timer = $Timer

@export var cooldown_time: float = 5

@onready var audio_stream_player = $AudioStreamPlayer

var can_interact := true

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = cooldown_time


func interact():
	if can_interact:
		PlayerManager.refill_ammo_reserve()
		
		# Play sound effect
		audio_stream_player.play()
		
		# Start cooldown
		can_interact = false
		timer.start()
	else:
		# If crate interacted with recently, alert player of cooldown
		EventBus.display_alert_text.emit("Ammo Crate on cooldown: %s seconds" % str(ceil(timer.time_left)))


func _on_timer_timeout():
	can_interact = true
