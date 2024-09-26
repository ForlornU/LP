extends Node2D

class_name LSystemManager

@export var axiom: String = "F"
@export var rules: Dictionary = {"F": "F[+F]F[-F]F"}
@export var angle: float = 25.0
@export var length: float = 10.0
@export var iterations: int = 4

# Lifecycle stages define how the plant evolves, including visual aspects like color and size
@export var lifecycle_stages: Array = [
	{ "name": "Seedling", "color": Color(0, 1, 0), "size": 5 },
	{ "name": "Mature", "color": Color(0, 1, 0), "size": 10 },
	{ "name": "Fruiting", "color": Color(0, 1, 0), "size": 10, "fruit_color": Color(1, 0, 0) },
	{ "name": "Withering", "color": Color(0.5, 0.25, 0), "size": 5 }
]

@export var timer_interval: float = 5.0  # Interval for lifecycle transitions

# Internal variables
var l_system: LSystem
var current_stage_index: int = 0

@onready var timer: Timer = Timer.new()

# Signal emitted when the L-System is updated
signal l_system_changed(l_system: LSystem)

func _ready() -> void:
	_initialize_system()

# Initialization function: generate the L-System and set up the timer for lifecycle management
func _initialize_system() -> void:
	_generate_l_system()
	_setup_timer()

# Timer setup with adjustable intervals
func _setup_timer() -> void:
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_stage_transition"))
	timer.start(timer_interval)

# Generate the L-System with the current parameters and emit the signal
func _generate_l_system() -> void:
	l_system = LSystem.new(axiom, rules, angle, length, iterations)
	emit_signal("l_system_changed", l_system)
	print("Generated L-System with length:", l_system.generate().length())

# Handles the transition between lifecycle stages
func _on_stage_transition() -> void:
	advance_stage()

# Advance to the next lifecycle stage and notify the renderer
func advance_stage() -> void:
	current_stage_index = (current_stage_index + 1) % lifecycle_stages.size()
	var stage = lifecycle_stages[current_stage_index]
	var renderer = get_parent().get_node("LSystemRenderer")

	if is_instance_valid(renderer):
		renderer.change_stage(current_stage_index)
		print("Transitioned to stage:", stage["name"])
	else:
		print("Renderer node missing or invalid")

# Adds a new L-System instance and emits a signal
func add_l_system() -> void:
	_generate_l_system()
	print("New L-System instance added")

# Modifies the L-System parameters dynamically and regenerates the system
func modify_l_system(new_axiom: String, new_rules: Dictionary, new_angle: float, new_length: float, new_iterations: int, new_lifecycle_stages: Array) -> void:
	axiom = new_axiom
	rules = new_rules
	angle = new_angle
	length = new_length
	iterations = new_iterations
	lifecycle_stages = new_lifecycle_stages
	_generate_l_system()
	print("L-System parameters modified")

# Setters and Getters with validation
# These methods ensure the L-System regenerates only when there are valid changes
func set_axiom(value: String) -> void:
	if value != axiom:
		axiom = value
		_generate_l_system()

func set_rules(value: Dictionary) -> void:
	if value != rules:
		rules = value
		_generate_l_system()

func set_angle(value: float) -> void:
	if value != angle:
		angle = value
		_generate_l_system()

func set_length(value: float) -> void:
	if value != length:
		length = value
		_generate_l_system()

func set_iterations(value: int) -> void:
	if value != iterations:
		iterations = value
		_generate_l_system()

func set_lifecycle_stages(value: Array) -> void:
	if value.size() > 0 and value != lifecycle_stages:
		lifecycle_stages = value
		_generate_l_system()
	else:
		print("Invalid or duplicate lifecycle stages provided.")

func get_lifecycle_stages() -> Array:
	return lifecycle_stages

# Timer interval setter with validation
func set_timer_interval(value: float) -> void:
	if value > 0:
		timer_interval = value
		timer.start(timer_interval)
		print("Timer interval updated to:", timer_interval)
	else:
		print("Invalid timer interval")

# Optional: method to restart lifecycle stages
func reset_lifecycle() -> void:
	current_stage_index = 0
	timer.start(timer_interval)
	print("Lifecycle reset to initial stage: Seedling")
