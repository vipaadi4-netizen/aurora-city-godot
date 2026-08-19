extends Node

## Main game coordinator.
## It owns the menu/loading/game flow and creates the 3D world on demand.

const City := preload("res://scripts/city.gd")
const Player := preload("res://scripts/player.gd")
const TouchJoystick := preload("res://scripts/touch_joystick.gd")
const CityScene := preload("res://scenes/city.tscn")
const PlayerScene := preload("res://scenes/player.tscn")

var world: Node3D
var ui: CanvasLayer
var menu_panel: Control
var loading_panel: Control
var hud_panel: Control
var loading_bar: ProgressBar
var status_label: Label

func _ready() -> void:
	_configure_input()
	_build_interface()
	_show_menu()

func _configure_input() -> void:
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_left", KEY_LEFT)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_right", KEY_RIGHT)
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_forward", KEY_UP)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_back", KEY_DOWN)
	_add_key_action("pause_game", KEY_ESCAPE)

func _add_key_action(action_name: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var key := InputEventKey.new()
	key.physical_keycode = keycode
	InputMap.action_add_event(action_name, key)

func _build_interface() -> void:
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)

	menu_panel = _make_full_panel(Color("#071329"))
	ui.add_child(menu_panel)
	var menu_content := VBoxContainer.new()
	menu_content.set_anchors_preset(Control.PRESET_CENTER)
	menu_content.position = Vector2(-190, -155)
	menu_content.size = Vector2(380, 310)
	menu_content.add_theme_constant_override("separation", 18)
	menu_panel.add_child(menu_content)

	var title := Label.new()
	title.text = "AURORA CITY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color("#d9f2ff"))
	menu_content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A living city beyond the horizon"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#7ea3c7"))
	menu_content.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 18
	menu_content.add_child(spacer)

	var start_button := Button.new()
	start_button.text = "ENTER THE CITY"
	start_button.custom_minimum_size = Vector2(380, 62)
	start_button.add_theme_font_size_override("font_size", 18)
	start_button.pressed.connect(_start_game)
	menu_content.add_child(start_button)

	var hint := Label.new()
	hint.text = "WASD / arrow keys on desktop  •  touch joystick on Android"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("#62809e"))
	menu_content.add_child(hint)

	loading_panel = _make_full_panel(Color("#071329"))
	loading_panel.visible = false
	ui.add_child(loading_panel)
	var loading_content := VBoxContainer.new()
	loading_content.set_anchors_preset(Control.PRESET_CENTER)
	loading_content.position = Vector2(-240, -60)
	loading_content.size = Vector2(480, 120)
	loading_content.add_theme_constant_override("separation", 14)
	loading_panel.add_child(loading_content)
	var loading_title := Label.new()
	loading_title.text = "BUILDING AURORA CITY"
	loading_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_title.add_theme_font_size_override("font_size", 24)
	loading_content.add_child(loading_title)
	status_label = Label.new()
	status_label.text = "Preparing the streets..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_content.add_child(status_label)
	loading_bar = ProgressBar.new()
	loading_bar.custom_minimum_size.y = 18
	loading_bar.show_percentage = false
	loading_content.add_child(loading_bar)

	hud_panel = Control.new()
	hud_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_panel.visible = false
	ui.add_child(hud_panel)
	var hud_title := Label.new()
	hud_title.position = Vector2(28, 22)
	hud_title.text = "AURORA CITY  /  SECTOR 01"
	hud_title.add_theme_font_size_override("font_size", 14)
	hud_title.add_theme_color_override("font_color", Color("#d9f2ff"))
	hud_panel.add_child(hud_title)
	var objective := Label.new()
	objective.position = Vector2(28, 48)
	objective.text = "Explore the neon district"
	objective.add_theme_font_size_override("font_size", 13)
	objective.add_theme_color_override("font_color", Color("#78a3c7"))
	hud_panel.add_child(objective)
	var pause := Button.new()
	pause.position = Vector2(1130, 24)
	pause.size = Vector2(120, 44)
	pause.text = "PAUSE"
	pause.mouse_filter = Control.MOUSE_FILTER_STOP
	pause.pressed.connect(_toggle_pause)
	hud_panel.add_child(pause)

func _make_full_panel(color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.color = color
	return panel

func _show_menu() -> void:
	menu_panel.visible = true
	loading_panel.visible = false
	hud_panel.visible = false

func _start_game() -> void:
	menu_panel.visible = false
	loading_panel.visible = true
	loading_bar.value = 5
	status_label.text = "Laying out the city grid..."
	await get_tree().create_timer(0.18).timeout
	world = Node3D.new()
	world.name = "CityWorld"
	add_child(world)
	var city := CityScene.instantiate()
	world.add_child(city)
	loading_bar.value = 55
	status_label.text = "Wiring the explorer..."
	await get_tree().create_timer(0.18).timeout
	var player := PlayerScene.instantiate()
	player.position = Vector3(0, 1.3, 12)
	world.add_child(player)
	loading_bar.value = 88
	status_label.text = "Opening the gates..."
	await get_tree().create_timer(0.2).timeout
	var joystick := TouchJoystick.new()
	joystick.name = "MoveJoystick"
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(28, -218)
	joystick.size = Vector2(190, 190)
	ui.add_child(joystick)
	player.joystick = joystick
	loading_bar.value = 100
	loading_panel.visible = false
	hud_panel.visible = true

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	var pause_button := hud_panel.get_child(2) as Button
	pause_button.text = "RESUME" if get_tree().paused else "PAUSE"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") and world:
		_toggle_pause()