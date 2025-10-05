class_name ResourceItem extends Node2D

enum Type {
  WOOD,
  STONE,
  FRUIT,
}

@export var type: Type
@export var amount: int = 1
@export var job_target_area: Area2D
@export var pickup_sound: AudioStreamPlayer2D

@onready var initial_collision_layer: int = job_target_area.collision_layer

func pickup():
  # disable from becoming a job target while carried
  job_target_area.collision_layer = 1
  pickup_sound.play()

func drop():
  job_target_area.collision_layer = initial_collision_layer
