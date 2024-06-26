extends CharacterBody2D

@export var speed = 5
@export var max_speed = 150.0
@export var rotation_speed = 3

@onready var text = $RichTextLabel
@onready var bullet = preload("res://Players/Chris/bullet.tscn")


var rotation_direction = 0
var health := 100


func _enter_tree():
	set_multiplayer_authority(name.to_int())
	change_stocks(1)
	

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	if Input.get_axis("down", "up"):
		velocity += transform.x * Input.get_axis("down", "up") * speed
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		velocity.y = clamp(velocity.y, -max_speed, max_speed)
	if Input.is_action_just_pressed('kill'):
		death()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if health > 0:
		get_input()
		rotation += rotation_direction * rotation_speed * delta
		velocity = lerp(velocity, Vector2(0,0), 0.02)
		blast()
		if global_position.length() >= 3000:
			death()
	else: velocity.y += 9.8#just adding gravity if you die for lols, u can delete
	move_and_slide()
	
	text.text =  var_to_str(int(move_toward(str_to_var(text.text), health, 150 * delta)))

func blast():
	if Input.is_action_just_pressed('z'):
		Camera.add_trauma(.3, transform.x)
		velocity -= transform.x * 20
		var b = bullet.instantiate()
		#b.name = str(multiplayer.get_unique_id())
		$Spawn_marker.add_child(b, true)
		#b.add_to_group("bullets")
		b.global_position = $Spawn_marker.global_position
		b.rotation = $".".rotation
		b.velocity = transform.x * 200
	
func death():
	change_stocks(0)
	$CollisionShape2D.disabled = true
	health = 0
	
@rpc("any_peer")
func hurt(direction, damage_percent):
	velocity += direction
	health -= damage_percent
	if health <= 0:
		change_stocks(0)
@rpc("any_peer")
func set_stuff(pos, vel): #this is honestly kinda just for jesse, jank solution
	global_position = pos
	velocity = vel

@rpc("any_peer")
func change_stocks(stock):
	Director.players[name.to_int()]['stocks'] = stock
	if !multiplayer.is_server():
		set_stocks.rpc_id(1, name.to_int(), stock)
	
@rpc("any_peer", "reliable")
func set_stocks(id, stock):
	Director.players[id]['stocks'] = stock
