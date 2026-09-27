extends Control

func _ready() -> void:
	# Connecte automatiquement TOUS les boutons du conteneur de talents,
	# pas besoin de le faire à la main un par un vu le nombre de spécialisations.
	# Récursif : va chercher les boutons même s'ils sont nichés dans des
	# sous-groupes de catégories, pas seulement les enfants directs.
	_connect_talent_buttons($TalentScreen/TreeViewport/TalentsContainer)
 
func _connect_talent_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(_on_talent_pressed.bind(child.name))
		# Continue à descendre dans l'arbre même si ce n'est pas un bouton
		# (utile pour les sous-groupes de catégories qui contiennent d'autres noeuds)
		_connect_talent_buttons(child)


# Appelé quand on clique sur n'importe quel noeud de talent
func _on_talent_pressed(talent_name: String) -> void:
	var image_path := "res://images/%s.jpg" % talent_name

	if ResourceLoader.exists(image_path):
		$ImageViewport/ImageDisplay.texture = load(image_path)
		$ImageViewport.visible = true
		$TalentScreen.visible = false
		$ImageViewport.reset_view()
		
	else:
		# Utile pendant le développement : te dit exactement quel fichier
		# il cherchait, si jamais le nom du bouton et de l'image ne matchent pas.
		print("Image introuvable : ", image_path)

# Appelé par le bouton "Fermer" pour cacher l'image affichée
func _on_fermer_pressed() -> void:
	$ImageViewport.visible = false
	$TalentScreen.visible = true

# Appelé par le bouton "Retour" pour revenir au menu principal
func _on_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
