# Game autoload
extends Node

# type -> amount
var resources = {}
var hive: Hive

# world radius only ever increases
signal world_radius_changed
var world_radius: float = 100.0:
  get:
    return world_radius
  set(new_radius):
    world_radius = new_radius
    world_radius_changed.emit()

func collect_resource(resource: ResourceItem):
  var type = resource.type
  if type in resources:
    resources[type] += resource.amount
  else:
    resources[type] = resource.amount

