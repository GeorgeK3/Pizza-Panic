extends VBoxContainer

@onready var confirmation_dialog = get_parent().get_parent().get_node("ConfirmationDialog") # Reference to the confirmation dialog
@onready var controls_window = get_parent().get_parent().get_node("ControlsWindow")  # Reference to the Controls window
@onready var controls_label = controls_window.get_node("Label")  # Reference to the RichTextLabel inside ControlsWindow
@onready var controls_close_button = controls_window.get_node("Button") # Close button inside the window

# Original JSON data structure
const ORIGINAL_FILE_DATA = {
	"score": 0,
	"guns": [],
	"levels_beaten": []
}

const CONTROLS_TEXT = """
[center][b][color=yellow]Controls[/color][/b][/center]

[color=orange]Movement:[/color]
  [color=lightblue]- Press D or →[/color]                 : Move Right
  [color=lightblue]- Press A or ←[/color]                 : Move Left

[color=orange]Actions:[/color]
  [color=lightgreen]- Press Space Bar[/color]              : Jump
  [color=lightgreen]- Press Space Bar (falling)[/color]    : Double Jump
  [color=lightgreen]- Press Enter[/color]                  : Dash
  [color=lightgreen]- Press R[/color]                      : Reload
  [color=lightgreen]- Press Right Click[/color]            : Shoot (Hold for Bow to shoot further)
  [color=lightgreen]- Press F[/color]                     : Melee Attack
  [color=lightgreen]- Aim[/color]                          : Use the Mouse

[color=orange]Weapons:[/color]
  [color=lightcoral]- Press 1[/color]                      : Pizza Bow
  [color=lightcoral]- Press 2[/color]                      : Pizza Gun
  [color=lightcoral]- Press 3[/color]                      : Pizza Bazooka

[color=gray](Weapons must be unlocked first)[/color]

[color=orange]Map Movement:[/color]
  [color=lightblue]- Use Arrow Keys[/color]                : Move Around the Map
  [color=lightgreen]- Press Enter[/color]                  : Enter a Level
"""



func _ready():
	# Connect the confirmation dialog signals
	confirmation_dialog.confirmed.connect(_on_reset_confirmed)

	# Dynamically connect signals for all buttons under "Buttons"
	for button in get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

	# Connect the close button on the Controls window
	controls_close_button.pressed.connect(_on_controls_close_pressed)

	# Set up the Controls window (hidden by default)
	controls_window.visible = false
	controls_label.bbcode_enabled = true  # Enable BBCode for RichTextLabel
	controls_label.text = CONTROLS_TEXT

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_reset_pressed() -> void:
	# Show the confirmation dialog
	confirmation_dialog.popup_centered()

func _on_reset_confirmed() -> void:
	# Reset the JSON file to its original data
	var file = FileAccess.open("user://save_file.json", FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(ORIGINAL_FILE_DATA, "\t"))  # Pretty-printed JSON
		file.close()
		print("Game data reset to original state.")
	else:
		push_error("Failed to reset game data. Could not open file.")

func _on_controls_pressed() -> void:
	# Show the controls window
	controls_window.visible = true

func _on_controls_close_pressed() -> void:
	# Hide the controls window
	controls_window.visible = false

func _on_button_mouse_entered(button: Button) -> void:
	# Add a "> " prefix if not already present
	if button.text.find("> ") == -1:
		button.text = button.text.insert(0, "> ")

func _on_button_mouse_exited(button: Button) -> void:
	# Remove the "> " prefix if present
	button.text = button.text.replace("> ", "")
