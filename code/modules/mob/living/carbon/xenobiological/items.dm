///Pet metroid Creation///

/obj/item/metroidpotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a metroid's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

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
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

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
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

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


//GOLEM SHELLS

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	w_class = ITEM_SIZE_HUGE
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

	var/shell_type = /obj/effect/mob_spawn/ghost_role/human/golem

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/material/adamantine = SPECIES_GOLEM_ADAMANTINE,
		/obj/item/stack/material/iron = SPECIES_GOLEM,
		/obj/item/stack/material/steel = SPECIES_GOLEM,
		/obj/item/stack/material/glass = SPECIES_GOLEM_GLASS,
		/obj/item/stack/material/plasteel = SPECIES_GOLEM_PLASTEEL,
		/obj/item/stack/material/sandstone = SPECIES_GOLEM_SAND,
		/obj/item/stack/material/plasma = SPECIES_GOLEM_PLASMA,
		/obj/item/stack/material/diamond = SPECIES_GOLEM_DIAMOND,
		/obj/item/stack/material/gold = SPECIES_GOLEM_GOLD,
		/obj/item/stack/material/silver = SPECIES_GOLEM_SILVER,
		/obj/item/stack/material/uranium = SPECIES_GOLEM_URANIUM,
		/obj/item/stack/material/plasteel/titanium = SPECIES_GOLEM_TITANIUM,
		/obj/item/stack/material/ocp = SPECIES_GOLEM_PLASTITANIUM,
		/obj/item/stack/material/wood = SPECIES_GOLEM_WOOD,
		/obj/item/stack/telecrystal/bluespace_crystal = SPECIES_GOLEM_BLUESPACE,
		/obj/item/device/soulstone = SPECIES_GOLEM_CULT,
		/obj/item/stack/medical/bruise_pack = SPECIES_GOLEM_CLOTH,
		/obj/item/stack/material/cloth = SPECIES_GOLEM_CLOTH,
		/obj/item/stack/material/plastic = SPECIES_GOLEM_PLASTIC,
		/obj/item/stack/material/cardboard = SPECIES_GOLEM_CARDBOARD,
		/obj/item/stack/material/leather = SPECIES_GOLEM_LEATHER,
		/obj/item/stack/material/mhydrogen = SPECIES_GOLEM_HYDROGEN,
	)

	if(istype(I,/obj/item/stack/material/adamantine))
		var/obj/item/stack/stuff_stack = I

		if(!stuff_stack.use(2))
			to_chat(user, SPAN_WARNING("You need at least two ingots to finish a golem!"))
			return

		qdel(I)
		to_chat(user, SPAN_NOTICE("You feel some magic pulse from shell."))
		to_chat(user, SPAN_NOTICE("You finish up the golem shell with adamantine?!"))
		new shell_type(get_turf(src), SPECIES_GOLEM_ADAMANTINE, user)
		qdel(src)
		return

	if(istype(I,/obj/item/device/soulstone))
		qdel(I)
		to_chat(user, SPAN_NOTICE("You finish up the golem shell with [I]."))
		new shell_type(get_turf(src), golem_shell_species_types[I.type], user)
		qdel(src)
		return

	if(!isstack(I))
		return

	var/obj/item/stack/stuff_stack = I
	var/species = golem_shell_species_types[stuff_stack.stacktype]

	if(!species)
		to_chat(user, SPAN_WARNING("You can't build a golem out of this kind of material!"))
		return
	if(!stuff_stack.use(10))
		to_chat(user, SPAN_WARNING("You need at least ten sheets to finish a golem!"))
		return
	to_chat(user, SPAN_NOTICE("You finish up the golem shell with ten sheets of [stuff_stack]."))
	new shell_type(get_turf(src), species, user)
	qdel(src)

///made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/ghost_role/human/golem/servant

/obj/item/metroid_transference
	name = "consciousness transference potion"
	desc = "A strange slime-based chemical that, when used, allows the user to transfer their consciousness to a lesser being."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potorange"
	var/prompted = FALSE
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

/obj/item/metroid_transference/attack(mob/living/carbon/metroid/M, mob/user)
	..()

/obj/item/metroid_transference/afterattack(mob/living/switchy_mob, mob/living/user, proximity)
	if(!proximity)
		return
	if(prompted || !isliving(switchy_mob))
		return
	if(switchy_mob.ckey) //much like sentience, these will not work on something that is already player controlled
		to_chat(user, SPAN_NOTICE("Already sentient!"))
		return ..()
	if(switchy_mob.is_ooc_dead())
		to_chat(user, SPAN_NOTICE("it's dead!"))
		return ..()
	if(!istype(switchy_mob, /mob/living/simple_animal))
		to_chat(user, SPAN_NOTICE("invalid creature!"))
		return ..()

	if(QDELETED(src) || QDELETED(switchy_mob) || QDELETED(user))
		return

	prompted = TRUE
	if(alert(usr, "This will permanently transfer your consciousness to [switchy_mob]. Are you sure you want to do this?",,list("Yes","No")) == "No")
		prompted = FALSE
		return

	to_chat(user, SPAN_NOTICE("You drink the potion then place your hands on [switchy_mob]..."))

	user.mind.transfer_to(switchy_mob)
	switchy_mob.languages = user.languages
	switchy_mob.name = "[user.real_name]"
	user.death()
	to_chat(switchy_mob, SPAN_NOTICE("In a quick flash, you feel your consciousness flow into [switchy_mob]!"))
	to_chat(switchy_mob, SPAN_WARNING("You are now [switchy_mob]. Your allegiances, alliances, and role is still the same as it was prior to consciousness transfer!"))
	qdel(src)

/obj/item/grenade/clusterbang/metroid
	desc = "Blorble Blorble"
	name = "Blorble Blorble"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "metroidbang"
	has_pin = FALSE

/obj/item/grenade/clusterbang/metroid/detonate()
	var/numspawned = rand(4,8)

	for(,numspawned > 0, numspawned--)
		new /obj/item/grenade/clusterbang/metroid/segment(get_turf(src.loc))//Launches flashbangs
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)
	return

/obj/item/grenade/clusterbang/metroid/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon_state = "metroidbang_segment"

/obj/item/grenade/clusterbang/metroid/segment/New()//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	..()
	icon_state = "metroidbang_segment_active"
	active = TRUE
	var/stepdist = rand(1, 4)
	var/temploc = loc
	walk_away(src, temploc, stepdist)
	var/dettime = rand(15, 60)
	spawn(dettime)
		detonate()


/obj/item/grenade/clusterbang/metroid/segment/detonate()
	var/numspawned = rand(2,4)
	for(var/_ in 1 to numspawned)
		var/chosen = pick(subtypesof(/obj/item/metroid_extract))
		var/obj/item/metroid_extract/metroid_extract = new chosen(get_turf(src))
		var/reagentselect = pick(metroid_extract.activate_reagents)
		if(reagentselect == "Plasma")
			reagentselect = /datum/reagent/toxin/plasma
		if(reagentselect == "Water")
			reagentselect = /datum/reagent/water
		if(reagentselect == "Blood")
			reagentselect = /datum/reagent/blood
		if(reagentselect == "Metroid Jelly")
			reagentselect = /datum/reagent/metroidjelly

		metroid_extract.reagents?.try_add_think_ctx("delayed_add_reagents", CALLBACK(src, nameof(/datum/reagents.proc/_delayed_add_reagents)), world.time + rand(1.5 SECONDS, 6 SECONDS), reagentselect, 5)
		var/steps = rand(1, 4)
		for(var/step in 1 to steps)
			step_away(src, loc)
	qdel(src)
