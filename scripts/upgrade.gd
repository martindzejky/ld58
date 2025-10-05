class_name Upgrade extends CenterContainer

enum Type {
  SPEED,
  ATTACK,
  UNITS
}

@export var type: Type

var current_tween: Tween

func _ready() -> void:
  scale = Vector2.ONE
  pivot_offset = size / 2

func _on_mouse_entered() -> void:
  if current_tween:
    current_tween.kill()

  current_tween = create_tween()
  current_tween.tween_property(self, 'scale', Vector2.ONE * 1.1, 0.2)


func _on_mouse_exited() -> void:
  if current_tween:
    current_tween.kill()

  current_tween = create_tween()
  current_tween.tween_property(self, 'scale', Vector2.ONE, 0.2)
