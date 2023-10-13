extends CanvasLayer

signal boss_defeated

var linear_velocity_boss = Vector2(0, 0) # Velocidad inicial, se puede modificar más tarde

# En el script del jefe
func is_boss():
	return true  

func _ready():
	var boss_body = get_node("RigidBody2D")  # Asume que el nodo hijo se llama "RigidBody2D"
	boss_body.gravity_scale = 0  # Detiene la gravedad
	boss_body.linear_velocity = Vector2(0, 0)  # Detiene el movimiento

var health = null


func take_damage(damage_amount):
	health -= damage_amount  # reduce la salud
	if health <= 0:
		die()  # Si la salud llega a 0, el jefe muere

func die():
	emit_signal("boss_defeated")
	queue_free() 
	
func set_health(health_comming):
	health = health_comming
	
