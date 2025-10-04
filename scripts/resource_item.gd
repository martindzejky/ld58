class_name ResourceItem extends Node2D

enum Type {
  WOOD,
  STONE,
  FRUIT,
}

@export var type: Type
@export var amount: int = 1
