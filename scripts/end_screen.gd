extends CenterContainer

@export var panel: PanelContainer

func _ready() -> void:
  get_tree().paused = true
  panel.modulate.a = 0
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(panel, 'modulate:a', 1, 0.5)

func _on_confirm_pressed() -> void:
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(panel, 'modulate:a', 0, 0.5)
  tween.tween_callback(end)

func end():
  get_tree().paused = false
  queue_free()

