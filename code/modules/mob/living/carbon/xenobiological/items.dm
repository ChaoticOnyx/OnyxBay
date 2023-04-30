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

	var/shell_type = /obj/effect/mob_spawn/ghost_role/human/golem

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/material/iron = /datum/species/golem,
		/obj/item/stack/material/steel = /datum/species/golem,
		/obj/item/stack/material/glass = /datum/species/golem/glass,
		/obj/item/stack/material/plasteel = /datum/species/golem/plasteel,
		/obj/item/stack/material/sandstone = /datum/species/golem/sand,
		/obj/item/stack/material/plasma = /datum/species/golem/plasma,
		/obj/item/stack/material/diamond = /datum/species/golem/diamond,
		/obj/item/stack/material/gold = /datum/species/golem/gold,
		/obj/item/stack/material/silver = /datum/species/golem/silver,
		/obj/item/stack/material/uranium = /datum/species/golem/uranium,
		/obj/item/stack/material/plasteel/titanium = /datum/species/golem/titanium,
		/obj/item/stack/material/ocp = /datum/species/golem/plastitanium,
		/obj/item/stack/material/wood = /datum/species/golem/wood,
		/obj/item/stack/telecrystal/bluespace_crystal = /datum/species/golem/bluespace,
		/obj/item/device/soulstone = /datum/species/golem/runic,
		/obj/item/stack/medical/bruise_pack = /datum/species/golem/cloth,
		/obj/item/stack/material/cloth = /datum/species/golem/cloth,
		/obj/item/stack/material/plastic = /datum/species/golem/plastic,
		/obj/item/stack/material/cardboard = /datum/species/golem/cardboard,
		/obj/item/stack/material/leather = /datum/species/golem/leather,
		/obj/item/stack/material/mhydrogen = /datum/species/golem/mhydrogen,
	)

	if(istype(I,/obj/item/device/soulstone))
		qdel(I)
		to_chat(user, SPAN_NOTICE("You finish up the golem shell with [I]."))
		new shell_type(get_turf(src), golem_shell_species_types[I.type], user)
		qdel(src)
		return

	if(!isstack(I))
		return

	var/obj/item/stack/stuff_stack = I
	var/species = golem_shell_species_types[I.type]

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
