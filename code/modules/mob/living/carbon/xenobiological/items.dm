///Pet metroid Creation///

/obj/item/metroidpotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"

/obj/item/metroidpotion/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
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

/obj/item/metroidpotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame. This one is meant for adult metroids."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/metroidpotion2/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
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


/obj/item/metroidsteroid
	name = "metroid steroid"
	desc = "A potent chemical mix that will cause a metroid to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/metroidsteroid/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
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

/obj/item/metroidsteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a metroid extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcaeruleum"

/obj/item/metroidsteroid2/afterattack(obj/target, mob/user , flag)
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

/obj/item/metroid_stabilizer
	name = "metroid stabilizer"
	desc = "A potent chemical mix that will reduce a metroid's mutation chance."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/metroid_stabilizer/attack(mob/living/carbon/metroid/M as mob, mob/user as mob)
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

/obj/item/chill_potion
	name = "metroid chill potion"
	desc = "A potent chemical mix that will fireproofs anything it's used on."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 3

/obj/item/chill_potion/afterattack(obj/target, mob/user, flag)
	if(istype(target, /obj/item/clothing))
		var/obj/item/clothing/clothing = target
		if(clothing.max_heat_protection_temperature == FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE)
			to_chat(user, SPAN_WARNING("This clothing has already been protected!"))
			return ..()
		to_chat(user, "You apply the potion.")
		clothing.max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
		uses -= 1
		if(!uses)
			qdel(src)

/obj/item/metroid_mutation
	name = "metroid mutation potion"
	desc = "A potent chemical mix that will increase a metroid's mutation chance."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"

/obj/item/metroid_mutation/attack(mob/living/carbon/metroid/M, mob/user)
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
	set_next_think(world.time + 1 SECOND)

/obj/effect/golemrune/think()
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

	set_next_think(world.time + 1 SECOND)

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

/obj/item/metroidpotion/renaming
	name = "renaming potion"
	desc = "A potion that allows a self-aware being to change what name it subconciously presents to the world."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potgreen"
	var/being_used = FALSE

/obj/item/metroidpotion/renaming/attack(mob/living/M as mob, mob/user as mob)
	if(being_used || !ismob(M))
		return

	if(!M.ckey) //only works on animals that aren't player controlled
		to_chat(user, SPAN_WARNING("[M] is not self aware, and cannot pick its own name."))
		return

	being_used = TRUE
	to_chat(user, SPAN_NOTICE("You offer [src] to [user]..."))

	var/newname = sanitize(input(M, "Would you like to change your name?", "Name yourself") as null|text, MAX_NAME_LEN)
	if (!newname)
		being_used = FALSE
		return

	M.SetName(newname)
	M.real_name = newname
	qdel(src)
