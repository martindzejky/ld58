extends VBoxContainer

@export var container: Control

func _ready():
  get_tree().paused = true

func add_upgrade(upgrade: Upgrade):
  container.add_child(upgrade)
  upgrade.gui_input.connect(Callable(self, '_on_upgrade_gui_input').bind(upgrade))

func _on_upgrade_gui_input(event: InputEvent, upgrade: Upgrade):
  if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
    get_tree().paused = false
    Game.choose_upgrade(upgrade)
    queue_free()
  elif event is InputEventScreenTouch and event.pressed:
    get_tree().paused = false
    Game.choose_upgrade(upgrade)
    queue_free()
