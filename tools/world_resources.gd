@tool
extends EditorScript

func _run():
  var radius_editor = get_scene().get_node('radius_editor')
  if not radius_editor:
    print('radius editor not found')
    return

  var world = get_scene().get_node('world_layer/world_sort')
  if not world:
    print('world not found')
    return

  var resources = world.get_children()
  var resources_couter = {}
  for resource in resources:
    print(resource.type)
    if not resource is ResourceObject: continue
    var resource_type = resource.resource_item.resource_type
    var amount = resource.amount_min
    if resource_type in resources_couter:
      resources_couter[resource_type] += amount
    else:
      resources_couter[resource_type] = amount

  for resource_type in resources_couter:
    print(resource_type, resources_couter[resource_type])
