extends CanvasLayer

var shader_material: ShaderMaterial

func _ready():
  visible = true
  var node := get_node_or_null('color_rect')
  if node and node is CanvasItem:
    shader_material = node.material
  _update_uniforms()
  Game.world_radius_changed.connect(_on_world_radius_changed)

func _process(_delta: float):
  _update_uniforms()

func _on_world_radius_changed():
  _update_uniforms()

func _update_uniforms():
  if shader_material == null:
    return
  var cam := get_viewport().get_camera_2d()
  if cam == null:
    return
  var vp_size: Vector2 = get_viewport().get_visible_rect().size
  shader_material.set_shader_parameter('viewport_size', vp_size)
  shader_material.set_shader_parameter('camera_pos', cam.global_position)
  shader_material.set_shader_parameter('camera_zoom', cam.zoom)
  shader_material.set_shader_parameter('world_center', Vector2.ZERO)
  shader_material.set_shader_parameter('world_radius', Game.world_radius)
