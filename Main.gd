extends Spatial

var arvrinterfacename = "none"
var arvrinterface = null

var ovr_init_config = null
var ovr_performance = null
var ovr_hand_tracking = null

var perform_runtime_config
export var enablenetworking = true
export var hostipnumber: String = ""
export var hostportnumber: int = 8004
export var enablevr: = true
var networkID = 0

func checkloadinterface(larvrinterfacename):
	var available_interfaces = ARVRServer.get_interfaces()
	for x in available_interfaces:
		if x["name"] == larvrinterfacename:
			arvrinterface = ARVRServer.find_interface(larvrinterfacename)
			if arvrinterface != null:
				arvrinterfacename = larvrinterfacename
				print("Found VR interface ", x)
				return true
	return false


func _ready():
	print("  Available Interfaces are %s: " % str(ARVRServer.get_interfaces()));
	print("Initializing VR");

	if checkloadinterface("OVRMobile"):
		print("found quest, initializing")
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns").new()
		ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns").new()
		ovr_hand_tracking = load("res://addons/godot_ovrmobile/OvrHandTracking.gdns").new();
		perform_runtime_config = false
		ovr_init_config.set_render_target_size_multiplier(1)
		if arvrinterface.initialize():
			get_viewport().arvr = true
			Engine.target_fps = 72
			Engine.iterations_per_second = 72
			print("  Success initializing Quest Interface.")
			$Players/PlayerMe.initovrhandtracking(ovr_hand_tracking)
		else:
			arvrinterface = null

	print("*-*-*-*  requesting permissions: ", OS.request_permissions())
	var perm = OS.get_granted_permissions()
	print("Granted permissions: ", perm)
	if enablenetworking:
		print("IP local addressess ", IP.get_local_addresses())
		print("IP local interfaces ", IP.get_local_interfaces())
		
		var networkedmultiplayerenet = NetworkedMultiplayerENet.new()
		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		if hostipnumber == "":
			networkedmultiplayerenet.create_server(hostportnumber, 5)
		else:
			networkedmultiplayerenet.create_client(hostipnumber, hostportnumber)
			get_tree().connect("connected_to_server", self, "_connected_to_server")
			get_tree().connect("connection_failed", self, "_connection_failed")
			get_tree().connect("server_disconnected", self, "_server_disconnected")
		get_tree().set_network_peer(networkedmultiplayerenet)
		networkID = get_tree().get_network_unique_id()
		print("networkID is ", networkID)

func _player_connected(id):
	print("NETWORK player_connected ", id)
func _player_disconnected(id):
	print("NETWORK player_disconnected ", id)
func _connected_to_server():
	print("NETWORK connected_to_server")
func _connection_failed():
	print("NETWORK connection_failed")
func _server_disconnected():
	print("NETWORK server_disconnected")





func _process(_delta):
	if !perform_runtime_config and ovr_performance != null:
		ovr_performance.set_clock_levels(1, 1)
		ovr_performance.set_extra_latency_mode(1)
		perform_runtime_config = true
	set_process(false)
