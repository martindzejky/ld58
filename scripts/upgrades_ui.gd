extends VBoxContainer

@export var container: Control
var has_selected: bool = false

func _ready():
  get_tree().paused = true
  modulate.a = 0
  call_deferred('reveal')

func reveal():
  pivot_offset = size / 2
  modulate.a = 0
  scale = Vector2.ONE * 0.5
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_parallel(true)
  tween.set_trans(Tween.TRANS_QUAD)
  tween.set_ease(Tween.EASE_OUT)
  tween.tween_property(self, 'modulate:a', 1, 0.3)
  tween.tween_property(self, 'scale', Vector2.ONE, 0.3)

func add_upgrade(upgrade: Upgrade):
  container.add_child(upgrade)
  upgrade.gui_input.connect(Callable(self, '_on_upgrade_gui_input').bind(upgrade))

func _on_upgrade_gui_input(event: InputEvent, upgrade: Upgrade):
  if has_selected:
    return

  if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
    get_tree().paused = false
    Game.choose_upgrade(upgrade)
    hide_and_free()
  elif event is InputEventScreenTouch and event.pressed:
    get_tree().paused = false
    Game.choose_upgrade(upgrade)
    hide_and_free()

func hide_and_free():
  has_selected = true
  pivot_offset = size / 2
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_parallel(true)
  tween.set_trans(Tween.TRANS_QUAD)
  tween.set_ease(Tween.EASE_IN)
  tween.tween_property(self, 'modulate:a', 0, 0.2)
  tween.tween_property(self, 'scale', Vector2.ONE * 0.5, 0.2)
  tween.tween_callback(end)

func end():
  get_tree().paused = false
  queue_free()
