extends Control

@export var resource_display: PackedScene

const LOOKUP = {
  'wood': ResourceItem.Type.WOOD,
  'stone': ResourceItem.Type.STONE,
  'fruit': ResourceItem.Type.FRUIT,
}

func _ready():
  Game.new_resource.connect(_on_new_resource)
  Game.task_completed.connect(_on_task_completed)
  force_display_required_resources()

func _on_new_resource(type: ResourceItem.Type):
  for child in get_children():
    if child.resource_type == type:
      return

  var display = resource_display.instantiate()
  display.resource_type = type
  add_child(display)

func _on_task_completed():
  force_display_required_resources()

func force_display_required_resources():
  # force display required resources for the task
  var current_task = Game.tasks[0] as Task
  for resource_name in LOOKUP:
    var resource_type = LOOKUP[resource_name]
    if current_task[resource_name] > 0:
      var exists = false
      for child in get_children():
        if child.resource_type == resource_type:
          exists = true
          break

      if exists:
        continue

      var display = resource_display.instantiate()
      display.resource_type = resource_type
      add_child(display)
