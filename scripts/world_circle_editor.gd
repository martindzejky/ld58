@tool
class_name WorldCircleEditor extends Node2D

@export var radiuses: Array[float] = []:
  get:
    return radiuses
  set(new_radiuses):
    radiuses = new_radiuses
    if Engine.is_editor_hint():
      queue_redraw()

func _ready():
  if not Engine.is_editor_hint():
    assert(radiuses.size() == Game.tasks.size(), 'Radiuses must be the same size as tasks')
    Game.world_radius = radiuses[0]
    for i in Game.tasks.size():
      Game.tasks[i].world_radius = radiuses[i]

func _draw():
  if Engine.is_editor_hint():
    for radius in radiuses:
      draw_circle(Vector2.ZERO, radius, Color.BLACK, false)
