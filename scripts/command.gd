class_name Command extends Node2D

@export var animation_player: AnimationPlayer

class Job: # TODO: should extend RefCounted?
  var target: Node2D
  var workers: Array[Node2D] = []
  var command: Command
  signal completed
  signal cancelled

var jobs: Array[Job] = []

func _on_job_area_area_entered(area: Area2D) -> void:
  if area.global_position.length() > Game.world_radius:
    return

  var job = Job.new()
  job.target = area.get_parent()
  job.command = self
  jobs.append(job)
  job.completed.connect(_on_job_completed.bind(job))
  job.cancelled.connect(_on_job_cancelled.bind(job))

func _on_job_area_area_exited(area: Area2D) -> void:
  var job_index = jobs.find_custom(func(job: Job): return job.target == area.get_parent())
  if job_index != -1:
    jobs.remove_at(job_index)

func remove_command():
  animation_player.play('delete')
  for job in jobs:
    job.cancelled.emit()

func _on_job_completed(job: Job):
  jobs.erase(job)

func _on_job_cancelled(job: Job):
  jobs.erase(job)

func get_available_jobs() -> Array[Job]:
  if jobs.size() == 0:
    return []

  var least_workers = jobs[0].workers.size()
  for i in jobs.size():
    var count = jobs[i].workers.size()
    if count < least_workers:
      least_workers = count

  return jobs.filter(func(job: Job): return job.workers.size() == least_workers)
