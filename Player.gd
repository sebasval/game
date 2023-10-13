extends Area2D
signal hit
signal explosion


export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size
onready var joystick = get_node("../VirtualJoystick")# Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Añadir la dirección del joystick al cálculo de la velocidad
	var direction = joystick.get_input_direction()
	if direction.length() > 0:
		velocity += direction

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Determinar la dirección de la animación basándose en la velocidad
	if velocity.x > 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_h = false
	


func _on_Player_body_entered(body):
	if body.has_method("is_bomb") and body.is_bomb():  # Asumiendo que la bomba tiene una variable booleana is_bomb
		body.queue_free()  # Esto eliminará la bomba de la escena
		emit_signal("explosion")
	else:
		hide() # El jugador desaparece después de ser golpeado.
		emit_signal("hit")
		# Debe diferirse ya que no podemos cambiar las propiedades físicas en un callback de física.
		$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
