#define CHICKEN_WHITE   /datum/chicken_species/white
#define CHICKEN_BROWN   /datum/chicken_species/brown
#define CHICKEN_BLACK   /datum/chicken_species/black
#define CHICKEN_ROBOT   /datum/chicken_species/robot
#define CHICKEN_GOLDEN  /datum/chicken_species/golden
#define CHICKEN_PLASMA  /datum/chicken_species/plasma
#define CHICKEN_VEGAN   /datum/chicken_species/vegan
#define CHICKEN_RAINBOW /datum/chicken_species/rainbow

#define MAX_CHICKENS 50
#define MAX_EGGS_PER_CHICKEN 8
GLOBAL_VAR_INIT(chicken_count, 0) // Number of /mob/living/simple_animal/chicken's in the current world

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.", "Cherp?", "Chirrup.", "Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground", "flaps its tiny wings")
	speak_chance = 2
	turns_per_move = 2
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/chicken
	meat_amount = 1
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	attacktext = "kicked"
	maxHealth = 3
	health = 3
	var/amount_grown = 0
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE
	mob_size = MOB_MINISCULE
	renamable = TRUE

/mob/living/simple_animal/chick/Initialize()
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat)
		amount_grown++
		if(amount_grown >= 180)
			amount_grown = -1
			new /mob/living/simple_animal/chicken(loc)
			qdel(src)

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	item_state = "chicken"
	speak = list("Cluck!", "BWAAAAARK BWAK BWAK BWAK!", "Bwaak bwak.")
	speak_emote = list("clucks", "croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground", "flaps its wings viciously")
	speak_chance = 2
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/chicken
	meat_amount = 2
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm  = "kicks"
	attacktext = "kicked"
	maxHealth = 10
	health = 10
	var/eggsleft = 0
	var/egg_chance = 0
	var/datum/chicken_species/species = null
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_SMALL
	holder_type = /obj/item/weapon/holder/chicken
	renamable = TRUE

/mob/living/simple_animal/chicken/Initialize()
	. = ..()
	if(!species)
		change_species(pick(CHICKEN_WHITE, CHICKEN_BROWN, CHICKEN_BLACK))
	species.update_owner()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	GLOB.chicken_count++

/mob/living/simple_animal/chicken/Destroy()
	if(species)
		QDEL_NULL(species)
	return ..()

/mob/living/simple_animal/chicken/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	GLOB.chicken_count--

/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown)) //feedin' dem chickens
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
		feed_with(G, user)
	else
		..()

/mob/living/simple_animal/chicken/proc/feed_with(obj/item/weapon/reagent_containers/food/snacks/grown/G, mob/user)
	if(!G)
		return // To prevent the case of somebody clickspamming during lags
	if(stat)
		to_chat(user, SPAN("notice", "[name] doesn't seem capable of eating."))
		return
	if(!(G.seed?.kitchen_tag in list("wheat", "rice", "grass")))
		to_chat(user, SPAN("notice", "[name] doesn't seem interested in that."))
		return
	if(eggsleft >= MAX_EGGS_PER_CHICKEN)
		to_chat(user, SPAN("notice", "[name] doesn't seem hungry!"))
		return
	user.visible_message(SPAN("notice", "[user] feeds [G] to [name]! It clucks happily."), SPAN("notice", "You feed [G] to [name]! It clucks happily."))
	if(species.mutable)
		if(G.reagents.has_reagent(/datum/reagent/nanites))
			change_species(CHICKEN_ROBOT)
		else if(G.reagents.has_reagent(/datum/reagent/mutagen))
			var/new_species = pick(CHICKEN_WHITE, CHICKEN_BROWN, CHICKEN_BLACK)
			if(G.reagents.has_reagent(/datum/reagent/toxin/plasma))
				new_species = CHICKEN_PLASMA
			else if(G.reagents.has_reagent(/datum/reagent/gold))
				new_species = CHICKEN_GOLDEN
			else if(G.reagents.has_reagent(/datum/reagent/toxin/fertilizer/left4zed))
				new_species = CHICKEN_VEGAN
			else if(G.reagents.has_reagent(/datum/reagent/space_drugs))
				new_species = CHICKEN_RAINBOW
			change_species(new_species)
		user.drop_item()
		qdel(G)
		eggsleft = min((eggsleft + rand(1, 3)), MAX_EGGS_PER_CHICKEN)

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if(eggsleft)
		egg_chance++
		if(!stat && prob(Floor(egg_chance / 10)))
			visible_message("<b>[name]</b> [pick("lays an egg", "squats down and croons", "begins making a huge racket", "begins clucking raucously")].")
			eggsleft--
			egg_chance = 0
			var/egg_type = pickweight(species.egg_type)
			var/obj/egg = new egg_type(get_turf(src))
			egg.pixel_x = rand(-6, 6)
			egg.pixel_y = rand(-6, 6)
			if(species.fertile && istype(egg, /obj/item/weapon/reagent_containers/food/snacks/egg) && GLOB.chicken_count < MAX_CHICKENS)
				START_PROCESSING(SSobj, egg)
	else
		egg_chance = 0

/mob/living/simple_animal/chicken/proc/change_species(datum/chicken_species/CS)
	QDEL_NULL(species)
	species = new CS
	species.owner = src
	species.update_owner()

///////////////////////
/// Chicken presets ///
///////////////////////
/mob/living/simple_animal/chicken/white
	name = "white chicken"
	icon_state = "chicken_white"

/mob/living/simple_animal/chicken/white/Initialize()
	. = ..()
	change_species(CHICKEN_WHITE)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/brown
	name = "brown chicken"
	icon_state = "chicken_brown"

/mob/living/simple_animal/chicken/brown/Initialize()
	. = ..()
	change_species(CHICKEN_BROWN)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/black
	name = "black chicken"
	icon_state = "chicken_black"

/mob/living/simple_animal/chicken/black/Initialize()
	. = ..()
	change_species(CHICKEN_BLACK)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/robot
	name = "robot chicken"
	icon_state = "chicken_robot"

/mob/living/simple_animal/chicken/robot/Initialize()
	. = ..()
	change_species(CHICKEN_ROBOT)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/golden
	name = "golden chicken"
	icon_state = "chicken_golden"

/mob/living/simple_animal/chicken/golden/Initialize()
	. = ..()
	change_species(CHICKEN_GOLDEN)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/plasma
	name = "plasma chicken"
	icon_state = "chicken_plasma"

/mob/living/simple_animal/chicken/plasma/Initialize()
	. = ..()
	change_species(CHICKEN_PLASMA)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/vegan
	name = "vegan chicken"
	icon_state = "chicken_vegan"

/mob/living/simple_animal/chicken/vegan/Initialize()
	. = ..()
	change_species(CHICKEN_VEGAN)

///////////////////////////////////////////////////////
/mob/living/simple_animal/chicken/rainbow
	name = "rainbow chicken"
	icon_state = "chicken_rainbow"

/mob/living/simple_animal/chicken/rainbow/Initialize()
	. = ..()
	change_species(CHICKEN_RAINBOW)

///////////////////////
/// Chicken species ///
///////////////////////
/datum/chicken_species
	var/description = "Hopefully the eggs are good this season."
	var/update_message = null
	var/body_color = null

	var/maxHealth = 10
	var/meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/chicken
	var/egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/egg)
	var/fertile = TRUE
	var/mutable = TRUE
	var/mob/living/simple_animal/chicken/owner = null

/datum/chicken_species/Destroy()
	owner = null
	. = ..()

/datum/chicken_species/proc/update_owner()
	if(!owner)
		qdel(src) // Something's went wrong, time to quit
		return
	if(update_message)
		owner.visible_message("<b>[owner.name]</b> [update_message]")
	owner.name = "[body_color] chicken"
	owner.desc = description
	owner.icon_state = "chicken_[body_color]"
	owner.icon_living = "chicken_[body_color]"
	owner.icon_dead = "chicken_[body_color]_dead"
	owner.item_state = "chicken_[body_color]"
	owner.meat_type = meat_type
	owner.maxHealth = maxHealth
	owner.health = maxHealth

///////////////////////////////////////////////////////
/datum/chicken_species/white
	body_color = "white"
	mutable = TRUE

///////////////////////////////////////////////////////
/datum/chicken_species/brown
	body_color = "brown"
	mutable = TRUE

///////////////////////////////////////////////////////
/datum/chicken_species/black
	body_color = "black"
	mutable = TRUE

///////////////////////////////////////////////////////
/datum/chicken_species/robot
	body_color = "robot"
	description = "Does it like to watch sketches?"
	update_message = "flaps its wings as some twisted metal grows through its body!"

	maxHealth = 20
	egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/egg/robot)
	fertile = FALSE
	mutable = FALSE

///////////////////////////////////////////////////////
/datum/chicken_species/golden
	body_color = "golden"
	description = "Must be conductive."
	update_message = "flaps its wings as its feathers suddenly turn golden!"

	egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/egg/golden)
	fertile = FALSE
	mutable = FALSE

///////////////////////////////////////////////////////
/datum/chicken_species/plasma
	body_color = "plasma"
	description = "Jack Trasen would be proud."
	update_message = "flaps its wings as its body heats up!"

	egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/egg/plasma)
	fertile = FALSE
	mutable = FALSE

///////////////////////////////////////////////////////
/datum/chicken_species/vegan
	body_color = "vegan"
	description = "Must taste like chickpeas."
	update_message = "flaps its wings as its feathers turn into bark!"

	maxHealth = 20
	egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/vegg = 17,
					/obj/item/weapon/reagent_containers/food/snacks/grown/potato = 1,
					/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1,
					/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1)
	fertile = FALSE
	mutable = FALSE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/tomatomeat

///////////////////////////////////////////////////////
/datum/chicken_species/rainbow
	body_color = "rainbow"
	description = "Full of pride, isn't it?"
	update_message = "clucks cheerfully!"

	egg_type = list(/obj/item/weapon/reagent_containers/food/snacks/egg/randomcolor = 3,
					/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow = 2)
	fertile = FALSE
	mutable = FALSE

///////////////////////
/// Some eggs stuff ///
///////////////////////
/obj/item/weapon/reagent_containers/food/snacks/egg
	var/amount_grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/Destroy()
	if(amount_grown)
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/Process()
	if(isturf(loc) || ismob(loc))
		amount_grown++
		if(amount_grown >= 300)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		return PROCESS_KILL

#undef CHICKEN_WHITE
#undef CHICKEN_BROWN
#undef CHICKEN_BLACK
#undef CHICKEN_ROBOT
#undef CHICKEN_GOLDEN
#undef CHICKEN_PLASMA
#undef CHICKEN_VEGAN
#undef CHICKEN_RAINBOW

#undef MAX_CHICKENS
