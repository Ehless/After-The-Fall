extends Control

# Appelé quand on clique sur le bouton "Talents"
func _on_talents_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Talents.tscn")

# Appelé quand on clique sur le bouton "Quitter"
func _on_quitter_pressed() -> void:
	get_tree().quit()


func _on_talent_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Talents.tscn")


func _on_leave_button_pressed() -> void:
	get_tree().quit()
