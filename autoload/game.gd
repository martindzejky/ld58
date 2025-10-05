# Game autoload
extends Node

# type -> amount
var resources = {}
signal new_resource(type)
signal resource_changed(type)

var hive: Hive

@export var tasks: Array[Task] = []
signal task_completed

# world radius only ever increases
signal world_radius_changed
var world_radius: float = 100.0:
  get:
    return world_radius
  set(new_radius):
    world_radius = new_radius
    world_radius_changed.emit()

const WORLD_RADIUS_CHANGE_TIME = 2

func collect_resource(resource: ResourceItem):
  var type = resource.type
  if type in resources:
    resources[type] += resource.amount
    resource_changed.emit(type)
  else:
    resources[type] = resource.amount
    new_resource.emit(type)
  update_task_completion()

func update_task_completion():
  if tasks.size() == 0:
    return

  var current_task = tasks[0]
  if not check_resource(ResourceItem.Type.WOOD, current_task.wood):
    return
  if not check_resource(ResourceItem.Type.STONE, current_task.stone):
    return
  if not check_resource(ResourceItem.Type.FRUIT, current_task.fruit):
    return
  tasks.pop_front()
  task_completed.emit()

  if tasks.size() > 0:
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, 'world_radius', tasks[0].world_radius, WORLD_RADIUS_CHANGE_TIME)

func check_resource(type: ResourceItem.Type, required: int):
  if required <= 0: return true
  if type not in resources: return false
  return resources[type] >= required
