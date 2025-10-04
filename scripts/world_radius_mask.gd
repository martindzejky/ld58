class_name WorldRadiusMask extends Polygon2D

const SEGMENTS = 96

func _ready():
  Game.world_radius_changed.connect(_on_world_radius_changed)
  update_polygon(Game.world_radius)

func _on_world_radius_changed():
  update_polygon(Game.world_radius)

func update_polygon(radius: float):
  var points: PackedVector2Array = []
  points.resize(SEGMENTS)
  var step = TAU / float(SEGMENTS)
  var angle = 0.0
  for i in SEGMENTS:
    var x = cos(angle) * radius
    var y = sin(angle) * radius
    points[i] = Vector2(x, y)
    angle += step
  polygon = points
