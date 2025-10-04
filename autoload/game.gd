# Game autoload
extends Node

var hive: Node2D

# world radius only ever increases
signal world_radius_changed
var world_radius: float = 100.0:
  get:
    return world_radius
  set(new_radius):
    world_radius = new_radius
    world_radius_changed.emit()
