extends RigidBody3D

@export_range (1000.0, 3500.0) var thurst: float = 1000.0
@export_range (100.0, 300.00) var torque: float = 100.0
@onready var audio_explosion: AudioStreamPlayer3D = $AudioExplosion
@onready var audio_landing: AudioStreamPlayer3D = $AudioLanding
@onready var audio_rocket: AudioStreamPlayer3D = $AudioRocket
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_right: GPUParticles3D = $BoosterParticlesRight
@onready var booster_particles_left: GPUParticles3D = $BoosterParticlesLeft
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

@export var gravity: float = 0.8

var is_transitioning: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Hello World!")
	
y = gravit


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_pressed("moon_boost"):
		apply_central_force(basis.y * delta * thurst)
		booster_particles.emitting = true
		if audio_rocket.playing == false:
			audio_rocket.play()
	else:
		booster_particles.emitting = false
		audio_rocket.stop()
		
	if Input.is_action_pressed("moon_rotate_left"):
		apply_torque(Vector3(0.0,0.0,torque * delta))
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
	if Input.is_action_pressed("moon_rotate_right"):
		apply_torque(Vector3(0.0,0.0,-torque * delta))
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false
	#var y_position = position.y
	#print(y_position)


func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			
			crash_sequence()

func crash_sequence() -> void:
	set_process(false)
	explosion_particles.emitting = true
	booster_particles.emitting = false
	supress_nonplay()
	Input.start_joy_vibration(0,0.5,0.5,0.08)
	audio_explosion.play()
	print("KABOOOM!!!!")
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
	
func complete_level(next_level_file: String) -> void:
	set_process(false)
	success_particles.emitting = true
	supress_nonplay()
	Input.start_joy_vibration(0,0.02,0.02,0.4)
	audio_landing.play()
	print("Level Complete!!!")
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	

func supress_nonplay() -> void:
	booster_particles.emitting = false
	booster_particles_left.emitting = false
	booster_particles_right.emitting = false
	audio_rocket.stop()
	
