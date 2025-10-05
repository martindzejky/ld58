# Commands autoload
extends Node2D

@export var command_scene: PackedScene

const CLICK_MAX_DRAG_PX = 10
const DELETE_COMMAND_DISTANCE = 140

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
        click_command()

  # touch
  if event is InputEventScreenTouch:
    if event.pressed and not pressing:
      pressing = true
      press_position = event.position
    elif not event.pressed and pressing:
      pressing = false
      if event.position.distance_to(press_position) < CLICK_MAX_DRAG_PX:
        click_command()

func click_command():
  var click_position = get_global_mouse_position()
  for cmd in get_tree().get_nodes_in_group('command'):
    if cmd.global_position.distance_to(click_position) < DELETE_COMMAND_DISTANCE:
      cmd.remove_command()
      return

  if click_position.length() > Game.world_radius:
    return

  var command = command_scene.instantiate()
  get_tree().call_group('world', 'add_child', command)
  command.position = click_position
