extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	var RopeSegment = preload("res://RopeSegment.tscn")
	for i in range(7):
		var lastnode = get_child(get_child_count() - 1)
		var rs = RopeSegment.instance()
		add_child(rs)
		rs.global_transform.origin = lastnode.get_node("Tail").global_transform.origin - (rs.get_node("PinJoint").global_transform.origin - rs.global_transform.origin)
		rs.get_node("PinJoint").set_node_a(lastnode.get_path())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
