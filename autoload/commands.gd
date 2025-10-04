# Commands autoload
extends Node

@export var command_scene: PackedScene

const CLICK_MAX_DRAG_PX = 10.0

var pressing = false
var press_position = Vector2.ZERO

func _unhandled_input(event):
  # mouse
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
    if event.pressed and not pressing:
      pressing = true
      press_position = event.position
    elif not event.pressed and pressing:
      pressing = false
      if event.position.distance_to(press_position) < CLICK_MAX_DRAG_PX:
        spawn_command()

  # touch
  if event is InputEventScreenTouch:
    if event.pressed and not pressing:
      pressing = true
      press_position = event.position
    elif not event.pressed and pressing:
      pressing = false
      if event.position.distance_to(press_position) < CLICK_MAX_DRAG_PX:
        spawn_command()

func spawn_command():
  var command = command_scene.instantiate()
  get_tree().current_scene.add_child(command)
  command.position = command.get_global_mouse_position()
