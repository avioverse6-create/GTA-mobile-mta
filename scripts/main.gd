extends Node3D

var car
var camera: Camera3D
var speed_label: Label

func _ready() -> void:
	_setup_input()
	_build_world()
	_spawn_player_car()
	_build_camera()
	_build_hud()

func _process(delta: float) -> void:
	if car and camera:
		var target := car.global_position + car.global_transform.basis * Vector3(0, 4.2, 9.5)
		camera.global_position = camera.global_position.lerp(target, 1.0 - exp(-4.5 * delta))
		camera.look_at(car.global_position + Vector3(0, 0.8, 0), Vector3.UP)
	if speed_label and car:
		speed_label.text = "%03d KM/H" % int(absf(car.speed) * 3.6)

func _setup_input() -> void:
	_add_key_action("accelerate", [KEY_W, KEY_UP])
	_add_key_action("brake", [KEY_S, KEY_DOWN, KEY_SPACE])
	_add_key_action("steer_left", [KEY_A, KEY_LEFT])
	_add_key_action("steer_right", [KEY_D, KEY_RIGHT])

func _add_key_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.34, 0.66)
	sky_material.sky_horizon_color = Color(0.72, 0.82, 0.91)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.88)
	environment.ambient_light_energy = 0.8
	world_env.environment = environment
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(160, 160)
	ground.mesh = ground_mesh
	ground.material_override = _material(Color(0.16, 0.34, 0.2), 0.0, 1.0)
	ground.position.y = -0.12
	add_child(ground)

	var road := MeshInstance3D.new()
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(12, 0.12, 120)
	road.mesh = road_mesh
	road.material_override = _material(Color(0.075, 0.085, 0.1), 0.0, 0.95)
	road.position.y = -0.035
	add_child(road)

	for z in range(-55, 60, 8):
		var stripe := MeshInstance3D.new()
		var stripe_mesh := BoxMesh.new()
		stripe_mesh.size = Vector3(0.16, 0.025, 3.4)
		stripe.mesh = stripe_mesh
		stripe.material_override = _material(Color(0.92, 0.83, 0.52))
		stripe.position = Vector3(0, 0.035, z)
		add_child(stripe)

	# Simple low-poly city blocks to give the first build an open-world feel.
	for i in range(18):
		var side := -1.0 if i % 2 == 0 else 1.0
		var h := 5.0 + float((i * 7) % 13)
		var building := MeshInstance3D.new()
		var block := BoxMesh.new()
		block.size = Vector3(5.0, h, 5.5)
		building.mesh = block
		building.material_override = _material(Color(0.28 + float(i % 3) * 0.06, 0.31, 0.35 + float(i % 4) * 0.035), 0.05, 0.85)
		building.position = Vector3(side * (11.0 + float(i % 3) * 3.0), h / 2.0 - 0.1, -48.0 + float(i) * 5.6)
		add_child(building)

	var floor_body := StaticBody3D.new()
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(160, 0.2, 160)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.12
	floor_body.add_child(floor_collision)
	add_child(floor_body)

func _spawn_player_car() -> void:
	car = CharacterBody3D.new()
	car.set_script(load("res://scripts/player_car.gd"))
	car.position = Vector3(0, 0.2, 5)
	add_child(car)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 72
	camera.position = Vector3(0, 5, 14)
	add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var title := Label.new()
	title.text = "SAN ANDREAS STYLE  •  MOBILE OPEN WORLD"
	title.position = Vector2(24, 20)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	layer.add_child(title)

	speed_label = Label.new()
	speed_label.text = "000 KM/H"
	speed_label.anchor_left = 1.0
	speed_label.anchor_right = 1.0
	speed_label.offset_left = -210
	speed_label.offset_right = -24
	speed_label.offset_top = 24
	speed_label.offset_bottom = 68
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	speed_label.add_theme_font_size_override("font_size", 28)
	speed_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	layer.add_child(speed_label)

	_add_touch_button(layer, "◀", Vector2(28, -122), Vector2(88, 88), "steer_left")
	_add_touch_button(layer, "▶", Vector2(124, -122), Vector2(88, 88), "steer_right")
	_add_touch_button(layer, "GAS", Vector2(-122, -132), Vector2(100, 100), "accelerate", true)
	_add_touch_button(layer, "BRAKE", Vector2(-232, -108), Vector2(92, 76), "brake", true)

	var hint := Label.new()
	hint.text = "WASD / ARROWS  •  TOUCH CONTROLS"
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.offset_left = 24
	hint.offset_top = -34
	hint.offset_bottom = -10
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.88, 0.91, 0.95, 0.8))
	layer.add_child(hint)

func _add_touch_button(layer: CanvasLayer, caption: String, offset: Vector2, size: Vector2, action: String, from_right := false) -> void:
	var button := Button.new()
	button.text = caption
	button.size = size
	button.add_theme_font_size_override("font_size", 20)
	button.modulate = Color(1, 1, 1, 0.82)
	if from_right:
		button.anchor_left = 1.0
		button.anchor_right = 1.0
		button.anchor_top = 1.0
		button.anchor_bottom = 1.0
		button.position = offset
	else:
		button.anchor_top = 1.0
		button.anchor_bottom = 1.0
		button.position = Vector2(offset.x, offset.y)
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	layer.add_child(button)

func _material(color: Color, metallic := 0.0, roughness := 0.7) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	return mat
