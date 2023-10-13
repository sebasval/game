extends RigidBody2D

signal hit

var speed = 20  # velocidad base para la bala; puedes ajustar esto como quieras

func _ready():
	connect("body_entered", self, "_on_Body_entered")
	# Ajuste de la velocidad lineal de la bala para que se mueva hacia abajo.
	linear_velocity = Vector2(0, speed)  # Esto la hará moverse hacia abajo

func _on_Body_entered(body):
	if body.name == "Player":
		emit_signal("hit")
		queue_free()

func set_speed(new_speed):
	speed = new_speed
	# Aquí también necesitamos actualizar la linear_velocity con la nueva velocidad
	linear_velocity = Vector2(0, speed)  # Esto sigue moviéndola hacia abajo
