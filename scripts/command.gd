class_name Command extends Node2D

class Job: # TODO: should extend RefCounted?
  var target: Node2D
  var worker: Node2D
  var command: Command
  signal started
  signal completed
  signal cancelled

var jobs: Array[Job] = []

func _on_job_area_area_entered(area: Area2D) -> void:
  if jobs.any(func(job: Job): return job.target == area.get_parent()):
    return

  var job = Job.new()
  job.target = area.get_parent()
  job.worker = null
  job.command = self
  jobs.append(job)
  print('Added job for ', job.target.name)
  job.completed.connect(_on_job_completed.bind(job))
  job.cancelled.connect(_on_job_cancelled.bind(job))

func _on_job_area_area_exited(area: Area2D) -> void:
  var job_index = jobs.find_custom(func(job: Job): return job.target == area.get_parent())
  if job_index != -1:
    jobs.remove_at(job_index)

func remove_command():
  queue_free()
  for job in jobs:
    job.cancelled.emit()

func _on_job_completed(job: Job):
  var job_index = jobs.find(job)
  if job_index != -1:
    jobs.remove_at(job_index)

func _on_job_cancelled(job: Job):
  var job_index = jobs.find(job)
  if job_index != -1:
    jobs.remove_at(job_index)
