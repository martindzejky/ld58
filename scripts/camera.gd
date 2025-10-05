class_name MainCamera extends Camera2D

var dragging = false

const MIN_ZOOM = 0.25
const MAX_ZOOM = 4.0

@export var ambience_player: AudioStreamPlayer

signal zoom_changed

func _ready():
  zoom = Vector2(1.5, 1.5)
  update_sounds()

func clamp_zoom():
  var z = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
  zoom = Vector2(z, z)
  update_sounds()
  zoom_changed.emit()

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

func update_sounds():
  var viewport_size = get_viewport_rect().size
  var max_dim = max(viewport_size.x, viewport_size.y)
  var sounds = get_tree().get_nodes_in_group('world_sound') as Array[AudioStreamPlayer2D]
  for sound in sounds:
    sound.max_distance = max_dim / zoom.x
    sound.volume_db = 0.0
    if zoom.x < 1.0:
      sound.volume_db -= 2.0 / zoom.x

  ambience_player.volume_db = -3.0 - 2.0 / zoom.x
