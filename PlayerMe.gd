extends ARVROrigin

var ovr_hand_tracking = null

var t = 0.0;
onready var Laser = get_node("/root/Main/BodyObjects/Laser")
onready var doppelganger = get_node("../Doppelganger")

func initovrhandtracking(lovr_hand_tracking):
	ovr_hand_tracking = lovr_hand_tracking
	$HandLeft.initovrhandtracking(ovr_hand_tracking, $HandLeftController)
	$HandRight.initovrhandtracking(ovr_hand_tracking, $HandRightController)
	$HandLeft.addremotetransform("thumb_null", get_node("/root/Main/BodyObjects/Finger1"))
	$HandLeft.addremotetransform("index_null", get_node("/root/Main/BodyObjects/Finger3"))
	$HandLeft.addremotetransform("pinky_null", get_node("/root/Main/BodyObjects/Finger4"))
		
func _process(delta):
	if ovr_hand_tracking != null:
		$HandLeft.process_ovrhandtracking(delta)
		$HandRight.process_ovrhandtracking(delta)
	var dhandright = doppelganger.get_node("HandRight")
	dhandright.handvalid = $HandRight.handvalid
	dhandright.handmodel.transform = $HandRight.handmodel.transform
	dhandright.hand_boneorientations = $HandRight.hand_boneorientations.duplicate()
	dhandright.update_handpose(delta)
	
