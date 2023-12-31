extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	show_message("You lose!")
	# Wait until the MessageTimer has counted down.
	yield($MessageTimer, "timeout")
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_StartButton_pressed():
	showLablelsElements()
	$StartButton.hide()
	var main_node = get_node("/root/Main")  
	main_node.new_game()
	
func showLablelsElements():
	$ScoreLabel.show()
	$ScoreTitle.show()
	$Message.show()
	$StartButton.show()
	
func hideLableElements():
	$ScoreLabel.hide()
	$ScoreTitle.hide()
	$Message.hide()
