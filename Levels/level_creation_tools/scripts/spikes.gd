extends Area2D

func _on_body_entered(body):
	if body.has_method('hurt') and body is CharacterBody2D:
		body.hurt.rpc(transform.x * 300, 10)
		$Sprite2D.scale.y = 2
		$Sprite2D.scale.x = .5

func _process(delta):
	if $Sprite2D.scale.y >= 1.05:
		$Sprite2D.scale.y = lerp($Sprite2D.scale.y, 1.0, delta * 10)
		$Sprite2D.scale.x = lerp($Sprite2D.scale.x, 1.0, delta * 10)

