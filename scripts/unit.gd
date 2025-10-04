class_name Unit extends Node2D

enum State {
  IDLE, # idle is a decision point
  WANDERING,
  MOVING_TO_COMMAND,
  MOVING_TO_HIVE
}

var state: State = State.IDLE
var target: Node2D
@export var debug_label: Label

@export var wander_timer: Timer
const MIN_WANDER_TIME = 1.0
const MAX_WANDER_TIME = 2.0
@export var wander_position_timer: Timer
@onready var wander_position: Vector2 = global_position
const MIN_WANDER_POSITION_TIME = 2.0
const MAX_WANDER_POSITION_TIME = 4.0
const MAX_WANDER_POSITION_DISTANCE = 30.0

const MOVE_SPEED = 100.0
const REACHED_TARGET_DISTANCE = 10.0

func _process(delta: float) -> void:
  match state:
    State.IDLE:
      debug_label.text = 'IDLE'
      idle_state()
    State.WANDERING:
      debug_label.text = 'WANDERING'
      wandering_state(delta)
    State.MOVING_TO_COMMAND:
      debug_label.text = 'MOVING_TO_COMMAND'
      moving_to_command_state(delta)
    State.MOVING_TO_HIVE:
      debug_label.text = 'MOVING_TO_HIVE'
      moving_to_hive_state(delta)

func idle_state():
  var available_commands = get_tree().get_nodes_in_group('command')
  if available_commands.size() == 0:
    state = State.WANDERING
    wander_timer.start(randf_range(MIN_WANDER_TIME, MAX_WANDER_TIME))
    return
  target = available_commands.pick_random()
  state = State.MOVING_TO_COMMAND

func wandering_state(delta: float):
  move_to_position(delta, wander_position)

func moving_to_command_state(delta: float):
  if not target:
    state = State.IDLE
    return

  var reached = move_to_target(delta)
  if reached:
    state = State.MOVING_TO_HIVE
    target = Game.hive

func moving_to_hive_state(delta: float):
  if not target:
    state = State.IDLE
    return

  var reached = move_to_target(delta)
  if reached:
    state = State.IDLE

func _on_wander_timer_timeout():
  state = State.IDLE

func move_to_target(delta: float):
  return move_to_position(delta, target.global_position)

func move_to_position(delta: float, position: Vector2):
  var direction = position - global_position
  var distance = direction.length()
  if distance < REACHED_TARGET_DISTANCE:
    return true
  else:
    global_position += direction.normalized() * MOVE_SPEED * delta
    return false

func _on_wander_position_timer_timeout() -> void:
  wander_position = global_position + Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(0, MAX_WANDER_POSITION_DISTANCE)
