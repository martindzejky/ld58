class_name MainCamera extends Camera2D

var dragging = false

func _unhandled_input(event):
  # mouse input
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
    if event.pressed and not dragging:
      dragging = true
    elif not event.pressed and dragging:
      dragging = false

  if event is InputEventMouseMotion and dragging:
    position -= event.relative / zoom

  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
    zoom *= 1.1
  elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
    zoom /= 1.1

  # touch input
  if event is InputEventScreenTouch and event.pressed:
    dragging = true
  elif event is InputEventScreenTouch and not event.pressed:
    dragging = false

  if event is InputEventScreenDrag and dragging:
    position -= event.relative / zoom

  # TODO: pinch to zoom and test on mobile
