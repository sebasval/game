extends Node


export(PackedScene) var mob_scene
export(PackedScene) var mob_scene_alien
export(PackedScene) var explosion_scene
export(PackedScene) var bomb_scene
export(PackedScene) var boss_scene
export(PackedScene) var bullet_scene

var score

var mob_timer = 0  # Cuenta los segundos
var current_mob_scene = null  # La escena de mob actual
var boss_spawned = false 
var boss_instance = null

func _ready():
	randomize()
	current_mob_scene = mob_scene  # Inicia con el primer tipo de mob

var enemies_detonated = 0  # Contador para los enemigos eliminados por la bomba
var difficulty_level = 1  # Empieza en 1 y aumenta con cada jefe derrotado
var next_boss_score = 10 
const defaul_score_next_level = 10



func stop_all_timers():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$BombTimer.stop()
	$BulletTimer.stop()

func free_specific_children():
	for child in get_children():
		if (child is RigidBody2D or child is CanvasLayer) and child.has_method("is_boss") and child.is_boss():
			child.queue_free()

func game_over():
	stop_all_timers()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	free_specific_children()
	reset_game_state()

func reset_game_state():
	boss_spawned = false
	boss_instance = null

	

func new_game():
	score = 0
	boss_spawned = false
	next_boss_score = defaul_score_next_level
	difficulty_level = 1
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Preparate!")
	$Music.play()
	$BossMusic.stop()
	$BombTimer.start()


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = current_mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_ScoreTimer_timeout():
	score += 1
	mob_timer += 1  # Aumenta el contador de tiempo
	$HUD.update_score(score)
	if mob_timer % 10 == 0:  # Cada 20 segundos
		if current_mob_scene == mob_scene:
			current_mob_scene = mob_scene_alien
		else:
			current_mob_scene = mob_scene

	# Comprobar si el score ha llegado a 50 para hacer aparecer al jefe del juego
	if score >= next_boss_score and not boss_spawned:
		spawn_boss()
		boss_spawned = true  # Marca que el jefe ya ha sido creado



func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func detonate_bomb():
	$ExplosionSound.play()
	enemies_detonated = 0
	if boss_instance != null:
		boss_instance.take_damage(20)
	for child in get_children():
		if child is RigidBody2D:
			if not boss_spawned:
				enemies_detonated += 1
				var explosion = explosion_scene.instance()
				explosion.position = child.position
				add_child(explosion)
				child.queue_free()
			else:
				var explosion = explosion_scene.instance()
				var boss_animated_sprite = boss_instance.get_node("RigidBody2D/AnimatedSprite")
				
				var frame_size = boss_animated_sprite.get_sprite_frames().get_frame(boss_animated_sprite.animation, boss_animated_sprite.frame).get_size()
				var explosion_center = boss_instance.get_node("RigidBody2D").global_position + frame_size / 2
				
				explosion.position = explosion_center
				add_child(explosion)
				explosion.set_explosion_duration(2.0)
	score += enemies_detonated
	$HUD.update_score(score)


func _on_BombTimer_timeout():
	# Crear una nueva instancia de la escena de la bomba.
	var bomb = bomb_scene.instance()

	# Elegir una ubicación aleatoria en la pantalla (ajustar según las dimensiones de tu ventana)
	bomb.position = Vector2(randf() * 640, randf() * 480)

	# Añadir la bomba a la escena principal.
	add_child(bomb)

func spawn_boss():
	$Music.stop()
	$BossMusic.play()
	$ScoreTimer.stop()
	var boss = boss_scene.instance()
	boss_instance = boss
	
	#Ajusta la vida del jefe basado en la dificultada
	boss_instance.set_health(100 * difficulty_level)
	
	# Obtener el tamaño de la ventana para centrar el jefe
	var screen_size = OS.window_size
	
	# Acceder al nodo RigidBody2D dentro del CanvasLayer
	var boss_body = boss.get_node("RigidBody2D")
	
	# Configura la posición inicial del jefe en la parte superior de la pantalla.
	boss_body.position = Vector2(screen_size.x / 2, -20)  # X centrado, Y = 65
	
	# Configura la velocidad del jefe para que se mueva hacia abajo.
	var velocity = Vector2(0, 200)  # Velocidad en la dirección Y (hacia abajo)
	boss_body.linear_velocity = velocity
	
	# Añade el jefe a la escena.
	add_child(boss)
	boss.connect("boss_defeated", self, "on_boss_defeated")
	
	# Configura la velocidad de reproducción de la animación
	boss.get_node("RigidBody2D/AnimationPlayer").playback_speed = 0.5
	
	# Iniciar la animación de entrada del jefe
	boss.get_node("RigidBody2D/AnimationPlayer").connect("animation_finished", self, "_on_Boss_Animation_finished")
	boss.get_node("RigidBody2D/AnimationPlayer").play("Entering")
	
	# Eliminar mobs existentes y detener su generación
	for child in get_children():
		if child is RigidBody2D and child.has_method("is_mob") and child.is_mob():
			child.queue_free()
	$MobTimer.stop()
	$BombTimer.stop()

func _on_Boss_Animation_finished(anim_name):
	var boss = boss_scene.instance()
	if anim_name == "Entering" and boss != null:
		$BulletTimer.start()
		$BombTimer.start()

func shoot_bullet(base_position):
	var bullet = bullet_scene.instance()
	
	# Obtén el tamaño del jefe
	var boss = boss_scene.instance()
	var boss_size = boss.get_node("RigidBody2D/CollisionShape2D").shape.extents
	
	# Genera una posición aleatoria relativa a la posición del jefe
	var random_offset = Vector2(rand_range(-boss_size.x, boss_size.x), rand_range(-boss_size.y, boss_size.y))
	bullet.position = base_position + random_offset
	
	# Ajusta la velocidad de la bala según la dificultad 
	bullet.set_speed(bullet.speed * difficulty_level) 
	
	bullet.connect("hit", self, "game_over")
	add_child(bullet)

	
func _on_Timer_timeout():
	var boss = boss_scene.instance()
	var boss_body = boss.get_node("RigidBody2D")
	if boss_body != null:
		shoot_bullet(boss_body.position)
		
func on_boss_defeated():
	# Aquí puedes detener las bombas y manejar cualquier lógica de limpieza o reinicio.
	$ScoreTimer.start()
	boss_instance = null
	boss_spawned = false
	$BulletTimer.stop()
	$Music.play()
	$BossMusic.stop()
	$MobTimer.start()
	difficulty_level += 1
	next_boss_score = score + 50 * difficulty_level

	
