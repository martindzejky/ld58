extends CenterContainer

@export var panel: PanelContainer

func _ready() -> void:
  get_tree().paused = true
  panel.pivot_offset = panel.size / 2
  panel.modulate.a = 0
  panel.scale = Vector2.ONE * 0.5
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_trans(Tween.TRANS_QUAD)
  tween.set_ease(Tween.EASE_OUT)
  tween.set_parallel(true)
  tween.tween_property(panel, 'modulate:a', 1, 0.5)
  tween.tween_property(panel, 'scale', Vector2.ONE, 0.5)

func _on_confirm_pressed() -> void:
  var tween = get_tree().create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.set_trans(Tween.TRANS_QUAD)
  tween.set_ease(Tween.EASE_IN)
  tween.set_parallel(true)
  tween.tween_property(panel, 'modulate:a', 0, 0.5)
  tween.tween_property(panel, 'scale', Vector2.ONE * 0.5, 0.5)
  tween.tween_callback(end)

func end():
  get_tree().paused = false
  queue_free()

