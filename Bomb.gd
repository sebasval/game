extends RigidBody2D

# Asumiendo que tienes la escena de explosión definida en tu script principal
# y la has exportado como 'explosion_scene', puedes acceder a ella de la siguiente manera:
var main_script = null

func is_bomb():
	return true

func _ready():
	# Asegúrate de conectar la bomba al script principal en algún momento
	main_script = get_node("/root/Main")  # Ajusta este camino al nodo que contiene tu script principal
	connect("body_entered", self, "_on_Body_entered")

# Conectar esto a la señal 'body_entered' de tu bomba RigidBody2D
func _on_Body_entered(body):
	if body.name == "Player":  # Cambia esto para que coincida con el nombre de tu nodo de jugador
		main_script.detonate_bomb()  # Llama a la función `detonate_bomb` en tu script principal
		queue_free()  # Elimina la bomba
