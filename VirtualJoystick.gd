extends Node2D

onready var stick = $Stick
onready var base = $Base
signal show_joystick

var active = false
var initial_position = Vector2()
var stick_radius = 100  # La distancia máxima que el stick puede moverse desde el centro

func _ready():
	stick.hide()
	base.hide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			active = true
			initial_position = event.position
			base.position = initial_position
			stick.position = initial_position
			stick.show()
			base.show()
		else:
			active = false
			stick.hide()
			base.hide()
	
	if event is InputEventScreenDrag and active:
		var direction = event.position - initial_position
		var distance = direction.length()

		if distance > stick_radius:
			direction = direction.normalized() * stick_radius

		stick.position = initial_position + direction

func get_input_direction():
	if active:
		return (stick.position - base.position).normalized()
	return Vector2()

