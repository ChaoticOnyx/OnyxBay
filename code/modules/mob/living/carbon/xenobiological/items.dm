/obj/item/metroid_extract
	name = "metroid extract"
	desc = "Goo extracted from a metroid. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "green metroid extract"
	force = 1.0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	origin_tech = list(TECH_BIO = 4)
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

	attackby(obj/item/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/metroidsteroid2))
			if(enhanced == 1)
				to_chat(user, "<span class='warning'> This extract has already been enhanced!</span>")
				return ..()
			if(Uses == 0)
				to_chat(user, "<span class='warning'> You can't enhance a used extract!</span>")
				return ..()
			to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
			Uses = 3
			enhanced = 1
			qdel(O)

/obj/item/metroid_extract/New()
	..()
	create_reagents(100)
	reagents.add_reagent(/datum/reagent/metroidjelly, 30)

/obj/item/metroid_extract/grey
	name = "grey metroid extract"
	icon_state = "grey metroid extract"

/obj/item/metroid_extract/gold
	name = "gold metroid extract"
	icon_state = "gold metroid extract"

/obj/item/metroid_extract/silver
	name = "silver metroid extract"
	icon_state = "silver metroid extract"

/obj/item/metroid_extract/metal
	name = "metal metroid extract"
	icon_state = "metal metroid extract"

/obj/item/metroid_extract/purple
	name = "purple metroid extract"
	icon_state = "purple metroid extract"

/obj/item/metroid_extract/darkpurple
	name = "dark purple metroid extract"
	icon_state = "dark purple metroid extract"

/obj/item/metroid_extract/orange
	name = "orange metroid extract"
	icon_state = "orange metroid extract"

/obj/item/metroid_extract/yellow
	name = "yellow metroid extract"
	icon_state = "yellow metroid extract"

/obj/item/metroid_extract/red
	name = "red metroid extract"
	icon_state = "red metroid extract"

/obj/item/metroid_extract/blue
	name = "blue metroid extract"
	icon_state = "blue metroid extract"

/obj/item/metroid_extract/darkblue
	name = "dark blue metroid extract"
	icon_state = "dark blue metroid extract"

/obj/item/metroid_extract/pink
	name = "pink metroid extract"
	icon_state = "pink metroid extract"

/obj/item/metroid_extract/green
	name = "green metroid extract"
	icon_state = "green metroid extract"

/obj/item/metroid_extract/lightpink
	name = "light pink metroid extract"
	icon_state = "light pink metroid extract"

/obj/item/metroid_extract/black
	name = "black metroid extract"
	icon_state = "black metroid extract"

/obj/item/metroid_extract/oil
	name = "oil metroid extract"
	icon_state = "oil metroid extract"

/obj/item/metroid_extract/adamantine
	name = "adamantine metroid extract"
	icon_state = "adamantine metroid extract"

/obj/item/metroid_extract/bluespace
	name = "bluespace metroid extract"
	icon_state = "bluespace metroid extract"

/obj/item/metroid_extract/pyrite
	name = "pyrite metroid extract"
	icon_state = "pyrite metroid extract"

/obj/item/metroid_extract/cerulean
	name = "cerulean metroid extract"
	icon_state = "cerulean metroid extract"

/obj/item/metroid_extract/sepia
	name = "sepia metroid extract"
	icon_state = "sepia metroid extract"

/obj/item/metroid_extract/rainbow
	name = "rainbow metroid extract"
	icon_state = "rainbow metroid extract"

////Pet metroid Creation///

/obj/item/weapon/metroidpotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"

	attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
			to_chat(user, "<span class='warning'> The potion only works on baby metroids!</span>")
			return ..()
		if(M.is_adult) //Can't tame adults
			to_chat(user, "<span class='warning'> Only baby metroids can be tamed!</span>")
			return..()
		if(M.stat)
			to_chat(user, "<span class='warning'> The metroid is dead!</span>")
			return..()
		if(M.mind)
			to_chat(user, "<span class='warning'> The metroid resists!</span>")
			return ..()
		var/mob/living/simple_animal/metroid/pet = new /mob/living/simple_animal/metroid(M.loc)
		pet.icon_state = "[M.colour] baby metroid"
		pet.icon_living = "[M.colour] baby metroid"
		pet.icon_dead = "[M.colour] baby metroid dead"
		pet.colour = "[M.colour]"
		to_chat(user, "You feed the metroid the potion, removing it's powers and calming it.")
		qdel(M)
		var/newname = sanitize(input(user, "Would you like to give the metroid a name?", "Name your new pet", "pet metroid") as null|text, MAX_NAME_LEN)

		if (!newname)
			newname = "pet metroid"
		pet.SetName(newname)
		pet.real_name = newname
		qdel(src)

/obj/item/weapon/metroidpotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame. This one is meant for adult metroids."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

	attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
		if(!istype(M, /mob/living/carbon/metroid/))//If target is not a metroid.
			to_chat(user, "<span class='warning'> The potion only works on metroids!</span>")
			return ..()
		if(M.stat)
			to_chat(user, "<span class='warning'> The metroid is dead!</span>")
			return..()
		if(M.mind)
			to_chat(user, "<span class='warning'> The metroid resists!</span>")
			return ..()
		var/mob/living/simple_animal/adultmetroid/pet = new /mob/living/simple_animal/adultmetroid(M.loc)
		pet.icon_state = "[M.colour] adult metroid"
		pet.icon_living = "[M.colour] adult metroid"
		pet.icon_dead = "[M.colour] baby metroid dead"
		pet.colour = "[M.colour]"
		to_chat(user, "You feed the metroid the potion, removing it's powers and calming it.")
		qdel(M)
		var/newname = sanitize(input(user, "Would you like to give the metroid a name?", "Name your new pet", "pet metroid") as null|text, MAX_NAME_LEN)

		if (!newname)
			newname = "pet metroid"
		pet.SetName(newname)
		pet.real_name = newname
		qdel(src)


/obj/item/weapon/metroidsteroid
	name = "metroid steroid"
	desc = "A potent chemical mix that will cause a metroid to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/weapon/metroidsteroid/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
		to_chat(user, "<span class='warning'> The steroid only works on baby metroids!</span>")
		return ..()
	if(M.is_adult) //Can't tame adults
		to_chat(user, "<span class='warning'> Only baby metroids can use the steroid!</span>")
		return..()
	if(M.stat)
		to_chat(user, "<span class='warning'> The metroid is dead!</span>")
		return..()
	if(M.cores == 3)
		to_chat(user, "<span class='warning'> The metroid already has the maximum amount of extract!</span>")
		return..()

	to_chat(user, "You feed the metroid the steroid. It now has triple the amount of extract.")
	M.cores = 3
	qdel(src)

/obj/item/weapon/metroidsteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a metroid extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"

/obj/item/weapon/metroidsteroid2/afterattack(obj/target, mob/user , flag)
	if(istype(target, /obj/item/metroid_extract))
		var/obj/item/metroid_extract/extract = target
		if(extract.enhanced == 1)
			to_chat(user, "<span class='warning'> This extract has already been enhanced!</span>")
			return ..()
		if(extract.Uses == 0)
			to_chat(user, "<span class='warning'> You can't enhance a used extract!</span>")
			return ..()
		to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
		extract.Uses = 3
		extract.enhanced = 1
		qdel(src)

/obj/item/weapon/metroid_stabilizer
	name = "metroid stabilizer"
	desc = "A potent chemical mix that will reduce a metroid's mutation chance."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/weapon/metroid_stabilizer/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
		to_chat(user, "<span class='warning'> The stabilizer only works on metroids!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'> The metroid is dead!</span>")
		return..()
	to_chat(user, "You feed the metroid the stabilizer.")
	M.mutation_chance -= 15
	if(M.mutation_chance < 0)
		M.mutation_chance = 0
	qdel(src)

/obj/item/weapon/chill_potion
	name = "metroid chill potion"
	desc = "A potent chemical mix that will fireproofs anything it's used on."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 3

/obj/item/weapon/chill_potion/afterattack(obj/target, mob/user, flag)
	if(istype(target, /obj/item/clothing))
		var/obj/item/clothing/clothing = target
		if(clothing.max_heat_protection_temperature == FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
			to_chat(user, SPAN("warning", "This clothing has already been protected!"))
			return ..()
		to_chat(user, "You apply the potion.")
		clothing.max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
		uses -= 1
		if(!uses)
			qdel(src)

/obj/item/weapon/metroid_mutation
	name = "metroid mutation potion"
	desc = "A potent chemical mix that will increase a metroid's mutation chance."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"

/obj/item/weapon/metroid_stabilizer/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/metroid))//If target is not a metroid.
		to_chat(user, "<span class='warning'> The mutation potion only works on metroids!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'> The metroid is dead!</span>")
		return..()
	to_chat(user, "You feed the metroid the mutation potion.")
	M.mutation_chance += 15
	if(M.mutation_chance > 100)
		M.mutation_chance = 100
	qdel(src)

/obj/effect/golemrune
	anchored = 1
	desc = "A strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	unacidable = 1
	layer = RUNE_LAYER

/obj/effect/golemrune/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/golemrune/Process()
	var/mob/observer/ghost/ghost
	for(var/mob/observer/ghost/O in src.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		ghost = O
		break
	if(ghost)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golemrune/attack_hand(mob/living/user as mob)
	var/mob/observer/ghost/ghost
	for(var/mob/observer/ghost/O in src.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "The rune fizzles uselessly. There is no spirit nearby.")
		return
	var/mob/living/carbon/human/G = new(src.loc)
	G.set_species("Golem")
	G.key = ghost.key
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as blunt trauma. Serve [user], and assist them in completing their goals at any cost.")
	qdel(src)


/obj/effect/golemrune/proc/announce_to_ghosts()
	for(var/mob/observer/ghost/G in GLOB.player_list)
		if(G.client)
			var/area/A = get_area(src)
			if(A)
				to_chat(G, "Golem rune created in [A.name].")

