extends Node3D

## Procedural low-poly city generator.
## The repeated blocks keep the Android prototype light and make expansion simple.

const CITY_RADIUS := 5
const BLOCK_SIZE := 28.0
const ROAD_WIDTH := 8.0
var materials: Dictionary = {}

func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_roads()
	_build_buildings()
	_build_landmarks()
	_build_ambience()

func _mat(color: Color, emission := Color.BLACK, energy := 0.0) -> StandardMaterial3D:
	var key := str(color) + str(emission)
	if materials.has(key):
		return materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	if energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = energy
	materials[key] = material
	return material

func _box(parent: Node3D, size: Vector3, location: Vector3, color: Color, emission := Color.BLACK) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var object := MeshInstance3D.new()
	object.mesh = mesh
	object.position = location
	object.material_override = _mat(color, emission, 2.2 if emission != Color.BLACK else 0.0)
	parent.add_child(object)
	return object

func _build_environment() -> void:
	var environment := WorldEnvironment.new()
	var data := Environment.new()
	data.background_mode = Environment.BG_COLOR
	data.background_color = Color("#071329")
	data.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	data.ambient_light_color = Color("#8ab3d4")
	data.ambient_light_energy = 0.55
	data.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = data
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_color = Color("#ffd8ae")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)

func _build_ground() -> void:
	_box(self, Vector3(320, 0.5, 320), Vector3(0, -0.25, 0), Color("#101d2e"))
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(320, 0.5, 320)
	floor_shape.shape = floor_box
	floor_shape.position = Vector3(0, -0.25, 0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)

func _build_roads() -> void:
	for i in range(-CITY_RADIUS, CITY_RADIUS + 1):
		var offset := i * BLOCK_SIZE
		_box(self, Vector3(320, 0.06, ROAD_WIDTH), Vector3(0, 0.03, offset), Color("#1d2b3c"))
		_box(self, Vector3(ROAD_WIDTH, 0.07, 320), Vector3(offset, 0.035, 0), Color("#1d2b3c"))
		for j in range(-CITY_RADIUS * 2, CITY_RADIUS * 2):
			var dash_offset := j * 14.0
			_box(self, Vector3(4.0, 0.08, 0.22), Vector3(dash_offset, 0.09, offset), Color("#e5bd61"), Color("#e5bd61"))
			_box(self, Vector3(0.22, 0.08, 4.0), Vector3(offset, 0.09, dash_offset), Color("#e5bd61"), Color("#e5bd61"))

func _build_buildings() -> void:
	var palette := [Color("#243651"), Color("#2e4263"), Color("#394b6d"), Color("#1d4960"), Color("#453d68")]
	for x in range(-CITY_RADIUS, CITY_RADIUS):
		for z in range(-CITY_RADIUS, CITY_RADIUS):
			var center := Vector3((x + 0.5) * BLOCK_SIZE, 0, (z + 0.5) * BLOCK_SIZE)
			var rng := RandomNumberGenerator.new()
			rng.seed = abs(x * 9176 + z * 13171 + 404)
			var footprint := Vector2(10.0 + rng.randf_range(0, 8), 10.0 + rng.randf_range(0, 8))
			var height := rng.randf_range(7.0, 25.0)
			_box(self, Vector3(footprint.x, height, footprint.y), center + Vector3(0, height / 2.0, 0), palette[rng.randi_range(0, palette.size() - 1)])
			for floor in range(1, int(height / 3.0)):
				if rng.randf() > 0.35:
					_box(self, Vector3(footprint.x * 0.72, 0.12, 0.18), center + Vector3(0, floor * 3.0, footprint.y / 2.0 + 0.1), Color("#e6bd75"), Color("#e6bd75"))
				if rng.randf() > 0.45:
					_box(self, Vector3(0.18, 0.12, footprint.y * 0.72), center + Vector3(footprint.x / 2.0 + 0.1, floor * 3.0, 0), Color("#73d1de"), Color("#73d1de"))

func _build_landmarks() -> void:
	_box(self, Vector3(18, 0.4, 18), Vector3(0, 0.22, 0), Color("#22344e"))
	for level in range(5):
		var size := 14.0 - level * 2.2
		_box(self, Vector3(size, 2.5, size), Vector3(0, 1.5 + level * 2.5, 0), Color("#2f6e86"))
	var tower := _box(self, Vector3(1.6, 34, 1.6), Vector3(0, 21, 0), Color("#a8eaff"), Color("#a8eaff"))
	var tower_material := tower.material_override as StandardMaterial3D
	tower_material.albedo_texture = load("res://assets/city_surface.png")
	tower_material.emission_texture = load("res://assets/window_glow.png")
	_box(self, Vector3(10, 0.18, 0.3), Vector3(0, 34, 0), Color("#e6bd75"), Color("#e6bd75"))
	_box(self, Vector3(0.3, 0.18, 10), Vector3(0, 34, 0), Color("#e6bd75"), Color("#e6bd75"))

func _build_ambience() -> void:
	var ambience := AudioStreamPlayer.new()
	ambience.stream = load("res://assets/aurora_ambience.wav")
	ambience.volume_db = -22.0
	ambience.autoplay = true
	add_child(ambience)
