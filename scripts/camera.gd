class_name MainCamera extends Camera2D

var dragging = false

const MIN_ZOOM = 0.5
const MAX_ZOOM = 2.0

func clamp_zoom():
  var z = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
  zoom = Vector2(z, z)

func clamp_position():
  var r = Game.world_radius
  if position.length() > r:
    position = position.normalized() * r

func _unhandled_input(event):
  # mouse input
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
    if event.pressed and not dragging:
      dragging = true
    elif not event.pressed and dragging:
      dragging = false

  if event is InputEventMouseMotion and dragging:
    position -= event.relative / zoom
    clamp_position()

  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
    zoom *= 1.05
    clamp_zoom()
  elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
    zoom /= 1.05
    clamp_zoom()

  # touch input
  if event is InputEventScreenTouch and event.pressed:
    dragging = true
  elif event is InputEventScreenTouch and not event.pressed:
    dragging = false

  if event is InputEventScreenDrag and dragging:
    position -= event.relative / zoom
    clamp_position()

  # TODO: pinch to zoom and test on mobile
