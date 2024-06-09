class_name WeatherModule
extends Node2D

@export var particle_spawn_interval: float = 0.5
@export var particle_limit: int = 100
@export var spawn_area_padding: Vector2 = Vector2(15, 100)
@export var atlas_texture: Texture2D

var spawn_timer: float = 0
var particles: Array[Node2D] = []
var camera: Camera2D = null
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var weather_manager: WeatherManager

func _ready():
	camera = get_viewport().get_camera_2d()
	spawn_timer = particle_spawn_interval

	# Connect to the weather manager signal
	weather_manager = get_node("/root/WeatherSystem/WeatherManager")
	weather_manager.connect("weather_parameters_updated", Callable(self, "_on_weather_parameters_updated"))
	_on_weather_parameters_updated(weather_manager.humidity, weather_manager.moisture, weather_manager.heat, weather_manager.wind)

func _process(delta: float):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = particle_spawn_interval
		spawn_particles()
	update_particles(delta)

func spawn_particles():
	if particles.size() >= particle_limit:
		return

	var particle = create_particle()
	particle.global_position = generate_random_pos()
	add_child(particle)
	particles.append(particle)

func update_particles(delta: float):
	for particle in particles:
		if particle.position.y > get_viewport().get_visible_rect().size.y:
			particles.erase(particle)
			particle.queue_free()

func create_particle() -> Node2D:
	var particle = GPUParticles2D.new()
	return particle

func generate_random_pos() -> Vector2:
	var x_pos = rng.randf_range(spawn_area_padding.x, get_viewport().get_visible_rect().size.x - spawn_area_padding.x)
	var y_pos = rng.randf_range(-spawn_area_padding.y, -10)
	return Vector2(x_pos, y_pos)

# Function to update weather parameters (called by WeatherManager)
func _on_weather_parameters_updated(new_humidity: float, new_moisture: float, new_heat: float, new_wind: float):
	# Override in specific weather modules to adjust particle behavior based on weather parameters
	pass
