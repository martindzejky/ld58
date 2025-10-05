class_name ResourceObject extends Node2D

@export var resource_item: PackedScene
@export var amount_min: int
@export var amount_max: int
@export var health = 2 # units deal 1 damage per hit by default
@export var animation_player: AnimationPlayer
@export var sounds: AudioStreamPlayer2D
@export var hit_sound: AudioStream
@export var destroy_sound: AudioStream

const RESOURCE_ITEM_MIN_SPAWN_DISTANCE = 4.0
const RESOURCE_ITEM_MAX_SPAWN_DISTANCE = 12.0

func reveal():
  animation_player.play('reveal')

func take_damage(amount: int):
  health -= amount
  if health > 0:
    animation_player.play('squish')
    sounds.stream = hit_sound
    sounds.play()
  else:
    animation_player.play('destroy')
    var amount_to_spawn = randi_range(amount_min, amount_max)
    for i in amount_to_spawn:
      var item = resource_item.instantiate()
      get_parent().add_child(item)
      var angle = randf_range(0.0, 2.0 * PI)
      var distance = randf_range(RESOURCE_ITEM_MIN_SPAWN_DISTANCE, RESOURCE_ITEM_MAX_SPAWN_DISTANCE)
      item.global_position = global_position + Vector2.UP.rotated(angle) * distance
      if item.global_position.length() > Game.world_radius:
        item.global_position = item.global_position.normalized() * Game.world_radius - 0.5

    sounds.reparent(get_parent())
    sounds.stream = destroy_sound
    sounds.play()
    sounds.finished.connect(sounds.queue_free)
