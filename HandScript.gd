extends Spatial

const handmodelfile1 = "res://addons/godot_ovrmobile/example_scenes/left_hand_model.glb"
const handmodelfile2 = "res://addons/godot_ovrmobile/example_scenes/right_hand_model.glb"

const hand_bone_mappings = [0, 23,  1, 2, 3, 4,  6, 7, 8,  10, 11, 12,  14, 15, 16, 18, 19, 20, 21];
var ovr_hand_tracking = null
var islefthand = false
var handcontroller = null
var controller_id = 0
var handmodel = null
var handskeleton = null
var meshnode = null
var handmaterial = null


var handscale = 0.0
var handconfidence = 0
var handvalid = 0
var hand_boneorientations = [ null,null,null,null,null,null,null,null, 
							  null,null,null,null,null,null,null,null, 
							  null,null,null,null,null,null,null,null  ];
var pointermodel = null
var pointervalid = false
var pointerpose = null
var pointermaterial = null

const fadetimevalidity = 1/0.2
var handtranslucentvalidity = 0.0
var pointertranslucentvalidity = 0.0

var handpositionstack = [ ]  # [ [ timestamp, validity, transform, boneorientations ] 

func _ready():
	islefthand = (get_name() == "HandLeft")
	var handmodelfile = handmodelfile1 if islefthand else handmodelfile2
	var handmodelres = load(handmodelfile)
	handmodel = handmodelres.instance()
	add_child(handmodel)
	handmodel.translation = Vector3(-0.2 if islefthand else 0.2, 0.8, 0)
	handskeleton = handmodel.get_child(0).get_node("Skeleton")
	for i in range(0, handskeleton.get_bone_count()):
		var bone_rest = handskeleton.get_bone_rest(i);
		handskeleton.set_bone_pose(i, Transform(bone_rest.basis)); # use the original rest as pose
		bone_rest.basis = Basis();
		handskeleton.set_bone_rest(i, bone_rest)
	meshnode = handskeleton.get_node("l_handMeshNode" if islefthand else "r_handMeshNode")
	handmaterial = load("shinyhandmesh.material").duplicate()
	handmaterial.albedo_color = "#21db2c" if islefthand else "#db212c"
	meshnode.set_surface_material(0, handmaterial)
	pointermodel = load("LaserPointer.tscn").instance()
	pointermaterial = pointermodel.get_node("Length/MeshInstance").get_surface_material(0).duplicate()
	pointermodel.get_node("Length/MeshInstance").set_surface_material(0, pointermaterial)
	add_child(pointermodel)
	set_process(false)
	
func initovrhandtracking(lovr_hand_tracking, lhandcontroller):
	ovr_hand_tracking = lovr_hand_tracking
	handcontroller = lhandcontroller
	controller_id = handcontroller.controller_id
	handscale = ovr_hand_tracking.get_hand_scale(controller_id)
	if handscale > 0:
		handmodel.scale = Vector3(handscale, handscale, handscale)
	handmaterial.albedo_color.a = 0.4
	handmodel.visible = false
	handmaterial.flags_transparent = true
	set_process(true)

func process_ovrhandtracking(delta):
	handconfidence = ovr_hand_tracking.get_hand_pose(controller_id, hand_boneorientations)
	handvalid = handconfidence != null and handconfidence == 1
	pointervalid = handvalid and ovr_hand_tracking.is_pointer_pose_valid(controller_id)
	if pointervalid:
		pointerpose = ovr_hand_tracking.get_pointer_pose(controller_id)
	if handvalid:
		handmodel.transform = handcontroller.transform
	update_handpose(delta)

func update_handpose(delta):
	if handvalid:
		for i in range(hand_bone_mappings.size()):
			handskeleton.set_bone_pose(hand_bone_mappings[i], Transform(hand_boneorientations[i]))
	handtranslucentvalidity = update_fademode(delta, handvalid, handtranslucentvalidity, handmodel, handmaterial)
	if pointervalid:
		pointermodel.transform = pointerpose
	pointertranslucentvalidity = update_fademode(delta, pointervalid, pointertranslucentvalidity, pointermodel, pointermaterial)

func update_fademode(delta, valid, translucentvalidity, model, material):
	if valid:
		if translucentvalidity == 0:
			model.visible = true
		if translucentvalidity < 1:
			translucentvalidity += delta*fadetimevalidity
			if translucentvalidity < 1:
				material.albedo_color.a = translucentvalidity
			else:
				translucentvalidity = 1
				material.flags_transparent = false
	else:
		if translucentvalidity == 1:
			material.flags_transparent = true
		if translucentvalidity > 0:
			translucentvalidity -= delta*fadetimevalidity
			if translucentvalidity > 0:
				material.albedo_color.a = translucentvalidity
			else:
				translucentvalidity = 0
				model.visible = false
	return translucentvalidity
	
func addremotetransform(bname, node):
	var boneattachment = BoneAttachment.new()
	boneattachment.bone_name = ("b_l_" if islefthand else "b_r_") + bname
	handskeleton.add_child(boneattachment)
	var remotetransform = RemoteTransform.new()
	remotetransform.update_scale = false
	boneattachment.add_child(remotetransform)
	remotetransform.remote_path = remotetransform.get_path_to(node)

# do pinches get released when out of sight?
# does pinches need to be moderated as to whether the hand is valid?
