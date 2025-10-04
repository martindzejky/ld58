class_name Unit extends Node2D

enum State {
  IDLE, # idle is a decision point
  WANDERING,
  MOVING_TO_COMMAND,
  MOVING_TO_HIVE,
  PERFORMING_JOB
}

var state: State = State.IDLE
var target: Node2D
var current_job: Command.Job

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

@export var attack_cooldown_timer: Timer
@export var haul_slot: Marker2D

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
    State.PERFORMING_JOB:
      debug_label.text = 'PERFORMING_JOB'
      performing_job_state(delta)

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
  if not target or not target is Command:
    state = State.IDLE
    return

  var reached = move_to_target(delta)
  if reached:
    var available = target.jobs.filter(func(job: Command.Job): return job.worker == null and is_instance_valid(job.target))

    if available.size() == 0:
      state = State.MOVING_TO_HIVE
      target = Game.hive
      return

    current_job = available.pick_random()
    current_job.worker = self
    current_job.started.emit()
    current_job.cancelled.connect(_on_job_cancelled)
    state = State.PERFORMING_JOB

func moving_to_hive_state(delta: float):
  if not target:
    state = State.IDLE
    return

  var reached = move_to_target(delta)
  if reached:
    if is_carrying_item():
      var item = haul_slot.get_child(0)
      Game.hive.collect_resource(item)
    state = State.IDLE

func performing_job_state(delta: float):
  if not current_job:
    state = State.IDLE
    return

  if not current_job.target:
    current_job.completed.emit()
    # find a new job from the same command
    # TODO: there's an edge case: if we just destroyed a resource which spawned resource items, these will not have jobs registered yet
    if current_job.command:
      var available = current_job.command.jobs.filter(func(job: Command.Job): return job.worker == null and is_instance_valid(job.target))
      if available.size() > 0:
        current_job = available.pick_random()
        current_job.worker = self
        current_job.started.emit()
        current_job.cancelled.connect(_on_job_cancelled)
      else:
        current_job = null
        state = State.MOVING_TO_HIVE
        target = Game.hive
        return
    else:
      current_job = null
      state = State.MOVING_TO_HIVE
      target = Game.hive
      return

  var reached = move_to_position(delta, current_job.target.global_position)
  if not reached:
    # keep moving
    return

  interact_with_job_target()

func is_carrying_item() -> bool:
  return haul_slot.get_child_count() > 0

func interact_with_job_target():
  if not current_job or not current_job.target:
    current_job = null
    state = State.MOVING_TO_HIVE
    target = Game.hive
    return

  if current_job.target is ResourceObject:
    if attack_cooldown_timer.is_stopped():
      attack_cooldown_timer.start()
      current_job.target.take_damage(1)
    return

  if current_job.target is ResourceItem and not is_carrying_item():
    current_job.target.pickup()
    current_job.target.reparent(haul_slot)
    current_job.target.position = Vector2.ZERO
    # complete the job immediately and remove it from command
    current_job.completed.emit()
    current_job = null
    target = Game.hive
    state = State.MOVING_TO_HIVE
    return

func _on_wander_timer_timeout():
  state = State.IDLE

func move_to_target(delta: float):
  return move_to_position(delta, target.global_position)

func move_to_position(delta: float, target_position: Vector2):
  var direction = target_position - global_position
  var distance = direction.length()
  if distance < REACHED_TARGET_DISTANCE:
    return true
  else:
    global_position += direction.normalized() * MOVE_SPEED * delta
    return false

func _on_wander_position_timer_timeout() -> void:
  wander_position = global_position + Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(0, MAX_WANDER_POSITION_DISTANCE)

func _on_job_cancelled():
  current_job = null
  state = State.MOVING_TO_HIVE
  target = Game.hive
