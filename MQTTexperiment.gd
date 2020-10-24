extends Node

# mosquitto_pub -h sensorcity.io -t "doesliverpool/mastheight" -m "12"
# mosquitto_pub -h sensorcity.io -t "doesliverpool/mastcolour" -m "ff0000"

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$mqttnode.server = "sensorcity.io"
	$mqttnode.client_id = "client%d" % rng.randi_range(10000, 99999)
	$mqttnode.connect_to_server()
	$mqttnode.subscribe("doesliverpool/#")
	$mqttnode.connect("received_message", self, "received_message")
	
var coffeemsg = ""

func received_message(topic, message):
	print("RRRRR: ", topic, ": ", message)
	if topic == "doesliverpool/coffeedesc":
		coffeemsg = "DoESLiverpool "+message
	elif topic == "doesliverpool/mastheight":
		get_node("/root/Main/Environment/Boat/mastheight").scale.y = float(message)
	elif topic == "doesliverpool/mastcolour":
		var mast = get_node("/root/Main/Environment/Boat/mastheight/MeshInstance")
		var mat = mast.get_surface_material(0)
		mat.albedo_color = Color(message)
		
	
var d = 5
var d2 = 1
func _process(delta):
	d -= delta
	if d < 0:
		$mqttnode.publish("hi", "there")
		d = 5
	d2 =- delta
	if d2 < 0:
		$mqttnode.check_msg()
		d2 = 1
