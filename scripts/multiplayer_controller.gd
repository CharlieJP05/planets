extends Node
class_name NakamaMultiplayer

var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var device_id = OS.get_unique_id()

var online = true # if server connect to others?
var server = false # is server or client?
var running = false
var Match = null

var players = {} # username : [data idk]
var joined = false # fix to stop self from joining
const opcode = preload("res://scripts/opcode.gd")
#ensure last snet as same length as amount of enums
var last_sent = [null,null,null,null]
var time_since_state = 0
var Level = preload("res://scenes/main/level.tscn")
var level = null
var OtherPlayer = load("res://scenes/secondary/OtherPlayer.tscn")
var player = null

var join_code = null
var username = null
var NakamaIP = "127.0.0.1"
var NakamaPort = 7350
var NakamaProtocol = "http"
var NakamaKey = "defaultkey"
var NakamaTimeout = 10

func _ready() -> void:
	player = get_node("Level")
	username = "wideDaniel"
	ClientConnect()

func ClientConnect(): # connect to nakama # NOT SERVER #
	client = Nakama.create_client(NakamaKey, NakamaIP, NakamaPort, NakamaProtocol)
	client.timeout = NakamaTimeout
	session = await client.authenticate_device_async(device_id,username) # TODO add accounts?
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	print("Successfully authenticated: %s" % session)
	
	socket = Nakama.create_socket_from(client)
	
	await socket.connect_async(session)
	
	socket.connected.connect(onSocketConnected)
	socket.closed.connect(onSocketClosed)
	socket.received_error.connect(onSocketRecievedError)
	
	socket.received_match_presence.connect(onMatchPresence)
	socket.received_match_state.connect(onMatchState)
	

func updateNakamaDetails():
	pass

func onMatchPresence(presence : NakamaRTAPI.MatchPresenceEvent): #ON PLAYER JOIN MATCH
	if !joined:
		joined = true
		return
	for join in presence.joins:
		#var username = join.username
		#if players.has(join.username): # if already in use
			#print("exists")
			#username = join.username+"_1"
			#var longest_num = 0
			#for i in players:
				#if i.left(i.rfind("_")) != join.username:##if differnt username
					#continue
				#var index = i.rfind("_") # find the last underscore
				#if index != -1: # if it has underscore
					#var after = i.substr(index + 1)#chars after underscore
					#if int(after) != 0: # if they are numbers
						#if longest_num < int(after):#if this is bigger than all saved
							#longest_num = int(after)#set this as largest
							#username = join.username+"_"+str(int(after)+1)
		
		var other = OtherPlayer.instantiate()
		get_parent().get_node("Level").add_child(other)
		other.name = join.username
		players[join] = other
	print(players)
	if server:
		var op_code = opcode.state  # your defined opcode for state update
		var data = fill_game_data(opcode.state)
		var json_data = JSON.new()
		json_data = JSON.stringify(data)
		await socket.send_match_state_async(Match.match_id, op_code, json_data)

func onMatchState(state : NakamaRTAPI.MatchData): #RECIEVE DATA WHEN CHANGED
	var op_code = state.op_code
	var result = JSON.parse_string(state.data)
	result = fix_json_types(result)
	extract_game_data(result,op_code)

func extract_game_data(data,op):
	if op == opcode.delta or op == opcode.state:
		level.get_node("Ship").linear_velocity = data["linear_velocity"]
		level.get_node("Ship").angular_velocity = data["angular_velocity"]
	if op == opcode.state:
		level.get_node("Ship").position = data["position"]
		level.get_node("Ship").rotation = data["rotation"]
		print("recieving")
	if server and op == opcode.input:
		players[data.presence].direction = data["direction"]
	else:
		pass

func fill_game_data(op) -> Dictionary:
	var data = {}
	if op == opcode.delta or op == opcode.state:
		data["linear_velocity"] = level.get_node("Ship").linear_velocity
		data["angular_velocity"] = level.get_node("Ship").angular_velocity  # your current game state here
		data["world"] = {}
	if op == opcode.state:
		data["position"] = level.get_node("Ship").position
		data["rotation"] = level.get_node("Ship").rotation
		print("sending")
	if client and op == opcode.input:
		data["direction"] = player.direction
		
	return data
	
func onSocketConnected():
	print("socket connected")
	
	
func onSocketClosed():
	print("Socket Closed")

func onSocketRecievedError(err):
	print("Socket Error:"+str(err))


func _process(delta: float) -> void:
	if !running:
		return
	if server and online:
		server_process(delta)
	else:
		client_process(delta)

func server_process(delta) -> void:
	time_since_state += delta
	var op_code = opcode.delta
	if time_since_state > 1:
		op_code = opcode.state
		time_since_state = 0
	var data = fill_game_data(op_code)
	if data != last_sent[op_code]: # do a more complex compare operation
		var json_data = JSON.new()
		json_data = JSON.stringify(data)
		await socket.send_match_state_async(Match.match_id, op_code, json_data)
		last_sent[op_code] = data
	
func client_process(delta) -> void:
	var op_code = opcode.input
	var data = fill_game_data(op_code)
	if 1:
		var json_data = JSON.new()
		json_data = JSON.stringify(fill_game_data)
		await socket.send_match_state_async(Match.match_id, op_code, json_data)
		last_sent[op_code] = data
	
func fix_json_types(data: Dictionary) -> Dictionary:
	for key in data.keys():
		var value = data[key]
		if typeof(value) == TYPE_STRING and value.begins_with("(") and value.ends_with(")"):
			var vec = _parse_vector2_from_string(value)
			if vec != null:
				data[key] = vec
				continue
		if typeof(value) == TYPE_DICTIONARY:
			data[key] = fix_json_types(value)
	return data

func _parse_vector2_from_string(s: String) -> Vector2:
	s = s.replace("(", "").replace(")", "")
	var parts = s.split(",")
	if parts.size() != 2:
		return Vector2(0,0)
	var x = parts[0].to_float()
	var y = parts[1].to_float()
	return Vector2(x, y)




func _on_username_text_changed(name: String) -> void:
	if name == "":
		username = null
	else: # TODO add check for long usernames
		username = name


func _on_host_button_down() -> void:
	if !online:
		return # add logic for solo play here
	var createdMatch = await socket.create_match_async("game")
	if createdMatch.is_exception():
		print("failed to create match" + str(createdMatch))
		return
	print("created match: " + str(createdMatch.match_id))
	Match = createdMatch
	server = true
	running = true
	level = Level.instantiate()
	get_parent().add_child(level)
	%Main.visible = false


func _on_join_button_down() -> void:
	if !online:
		return # add logic for solo play here
	var createdMatch = await socket.create_match_async("game")
	if createdMatch.is_exception():
		print("failed to create match" + str(createdMatch))
		return
	print("created match: " + str(createdMatch.match_id))
	Match = createdMatch
	running = true
	level = Level.instantiate()
	get_parent().add_child(level)
	
	%Main.visible = false

func _on_join_code_text_changed(new_text: String) -> void:
	join_code = new_text
