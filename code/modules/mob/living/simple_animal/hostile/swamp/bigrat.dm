/mob/living/simple_animal/hostile/retaliate/bigrat
	name = "rat"
	icon = 'icons/mob/swamp/bigrat.dmi'
	icon_state = "rat"
	icon_living = "rat"
	icon_dead = "rat1"
	emote_hear = list("squeaks.")
	emote_see = list("cleans its nose.")
	meat_amount = 6
	turns_per_move = 10
	can_escape = TRUE
	health = 65
	maxHealth = 65
	pixel_x = -16
	pixel_y = -8
	melee_damage_lower = 17
	melee_damage_upper = 21
	mob_size = MOB_LARGE
	var/static/image/eyes = image(icon = 'icons/mob/swamp/bigrat.dmi', icon_state = "bigrat-eyes")

/mob/living/simple_animal/hostile/retaliate/bigrat/Initialize()
	. = ..()
	gender = MALE
	if(prob(33))
		gender = FEMALE
	if(gender == FEMALE)
		icon_state = "Frat"
		icon_living = "Frat"
		icon_dead = "Frat1"
	update_icon()

/mob/living/simple_animal/hostile/retaliate/bigrat/on_update_icon()
	CutOverlays(eyes)
	if(stat != DEAD)
		AddOverlays(eyes)
		AddOverlays(emissive_appearance(icon, "bigrat-eyes"))
		set_light(0.8, 0.5, 2, 3, COLOR_RED)
