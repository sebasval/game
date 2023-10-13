extends Node2D

# Variables para controlar la animación y el sonido
var animated_sprite: AnimatedSprite
var audio_stream_player: AudioStreamPlayer

func _ready():
	# Inicializamos los nodos
	animated_sprite = $AnimatedSprite
	audio_stream_player = $AudioStreamPlayer

	# Nos aseguramos de que los nodos están correctamente asignados
	if animated_sprite == null or audio_stream_player == null:
		print("Error: Los nodos AnimatedSprite o AudioStreamPlayer no están asignados correctamente.")
		return

	# Conecta la señal para saber cuándo se ha completado la animación
	animated_sprite.connect("animation_finished", self, "_on_Animation_finished")
	
	# Inicia la animación y el sonido de la explosión
	animated_sprite.play("Explosion")
	audio_stream_player.play()

# Método para ajustar la escala de la explosión
func set_explosion_scale(scale: Vector2):
	self.scale = scale

# Método para ajustar la duración de la animación de la explosión
func set_explosion_duration(duration: float):
	# Asegúrate de que 'animated_sprite' no es 'nil' y que 'duration' no es cero
	if animated_sprite and duration > 0:
		animated_sprite.speed_scale = 1.0 / duration  # Reduce la velocidad de la animación para que dure más
	else:
		print("Error: 'animated_sprite' es 'nil' o 'duration' es cero.")

# Se llama cuando la animación de la explosión se ha completado
func _on_Animation_finished():
	queue_free()
