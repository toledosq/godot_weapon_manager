class_name DebugPanel extends PanelContainer

var parent
@onready var property_stack = %PropertyStack

var display := false


func _ready():
	PlayerManager.player_ready.connect(_on_player_ready)


func _on_player_ready():
	parent = PlayerManager.player
	display = true


func _process(delta):
	if display:
		if visible:
			pass
		fps_counter()
		player_state()
		movement_speed()
		velocity_vector()


func add_property(title : String, value):
	var target
	target = property_stack.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_stack.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)


func fps_counter():
	add_property("FPS", Performance.get_monitor(Performance.TIME_FPS))


func player_state():
	var status : String = str(parent.state)
	if !parent.is_on_floor():
		status += " in the air"
	add_property("State", status)


func movement_speed():
	add_property("Movement Speed", parent.speed)


func velocity_vector():
	# Sample real velocity Vector3
	var cv : Vector3 = parent.get_real_velocity()
	var vd : Array[float] = [
			snappedf(cv.x, 0.001),
			snappedf(cv.y, 0.001),
			snappedf(cv.z, 0.001)
		]
	# Create real velocity string
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	add_property("Velocity", readable_velocity)
