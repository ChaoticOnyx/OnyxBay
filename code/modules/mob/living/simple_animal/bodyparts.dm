// Fake bodyparts

/decl/simple_animal_bodyparts
	var/list/hit_zones = list()

/decl/simple_animal_bodyparts/humanoid // No need to specify bodyparts, uses default names.

/decl/simple_animal_bodyparts/quadruped // Most subtypes have this basic body layout.
	hit_zones = list("head", "torso", "left foreleg", "right foreleg", "left hind leg", "right hind leg", "tail")

/decl/simple_animal_bodyparts/bird
	hit_zones = list("head", "body", "right wing", "left wing", "right leg", "left leg")

/decl/simple_animal_bodyparts/fish
	hit_zones = list("head", "body", "dorsal fin", "left pectoral fin", "right pectoral fin", "tail fin")

/decl/simple_animal_bodyparts/legless
	hit_zones = list("head", "body", "right arm", "right hand", "left arm", "left hand")
