class_name VisibilityByWorldRadius extends Node2D

@export var is_static: bool = true

const REVEAL_DELAY = 1.2
const REVEAL_TIME = 0.5

var revealed: bool = false

func _ready():
  get_parent().visible = is_inside_world_radius()
  revealed = get_parent().visible
  Game.world_radius_changed.connect(_on_world_radius_changed)

func _process(_delta: float):
  if not is_static:
    if is_inside_world_radius(): reveal()

func _on_world_radius_changed():
  if is_inside_world_radius(): reveal()

func is_inside_world_radius():
  return get_parent().global_position.length() <= Game.world_radius

func reveal():
  if revealed: return
  revealed = true
  await get_tree().create_timer(REVEAL_DELAY).timeout

  var parent = get_parent()
  if parent.has_method('reveal'):
    parent.visible = true
    parent.reveal()
    return

  # default reveal
  parent.modulate.a = 0
  parent.visible = true
  var tween = create_tween()
  tween.tween_property(get_parent(), 'modulate:a', 1.0, REVEAL_TIME)

  var sound_player = AudioStreamPlayer2D.new()
  get_parent().add_child(sound_player)
  sound_player.stream = Game.reveal_sound
  sound_player.global_position = parent.global_position
  sound_player.play()
  sound_player.finished.connect(sound_player.queue_free)

  # ugly but whatever
  var camera = get_viewport().get_camera_2d()
  var viewport_size = get_viewport_rect().size
  var max_dim = max(viewport_size.x, viewport_size.y)
  sound_player.max_distance = max_dim
  if camera.zoom.x < 1.0:
    sound_player.volume_db -= 2.0 / camera.zoom.x
