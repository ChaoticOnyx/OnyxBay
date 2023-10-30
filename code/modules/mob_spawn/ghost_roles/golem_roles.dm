
//reserved file just for golems since they're such a big thing, available on lavaland and from the station

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/ghost_role/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species =  SPECIES_GOLEM
	anchored = FALSE
	density = FALSE
	prompt_name = "a free golem"
	you_are_text = "You are a Free Golem. Your family worships The Liberator."
	flavour_text = "In his infinite and divine wisdom, he set your clan free to travel the stars with a single declaration: \"Yeah go do whatever.\""
	spawner_job_path = /datum/job/free_golem
	/// If TRUE, other golems can touch us to swap into this shell.
	var/can_transfer = TRUE
	/// Weakref to the creator of this golem shell.
	var/weakref/owner_ref
	outfit = null

/obj/effect/mob_spawn/ghost_role/human/golem/Initialize(mapload, datum/species/golem/species, mob/creator)
	if(creator)
		name = "inert servant golem shell"
		prompt_name = "servant golem"
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/init_area = get_area(src)
	if(!mapload && init_area)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [init_area.name].", source = src, action=NOTIFY_POSSES, flashwindow = FALSE)
	if(creator)
		you_are_text = "You are a golem."
		flavour_text = "You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools."
		important_text = "Serve [creator], and assist [creator] in completing [creator] goals at any cost."
		owner_ref = weakref(creator)
		spawner_job_path = /datum/job/servant_golem


/obj/effect/mob_spawn/ghost_role/human/golem/name_mob(mob/living/spawned_mob, forced_name)
	if(!forced_name)
		var/datum/species/golem/golem_species = all_species[mob_species]
		if(owner_ref?.resolve())
			forced_name =  "[initial(golem_species.prefix)] Golem ([rand(1,999)])"
		else
			forced_name =  golem_species.get_random_name()

	spawned_mob.fully_replace_character_name(forced_name)
	return
/obj/effect/mob_spawn/ghost_role/human/golem/create(mob/mob_possessor, newname)
	if(!LAZYLEN(GLOB.golems_resonator))
		mob_species = SPECIES_GOLEM_ADAMANTINE
	..()

/obj/effect/mob_spawn/ghost_role/human/golem/special(mob/living/new_spawn, mob/mob_possessor)
	. = ..()
	var/mob/living/real_owner = owner_ref?.resolve()
	var/mob/living/carbon/human/H = new_spawn
	var/datum/species/golem/golem_species = all_species[mob_species]
	to_chat(H, "[initial(golem_species.info_text)]")
	if(isnull(real_owner))
		if(!is_station_turf(get_turf(H)))
			to_chat(H, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! \
				You are generally a peaceful group unless provoked.")

	else if(H.mind)
		H.mind.store_memory(FONT_LARGE(SPAN_WARNING("YOU'RE SLAVE OF [real_owner]")))
		to_chat(H, FONT_LARGE(SPAN_WARNING("YOU'RE SLAVE OF [real_owner]")))

	else
		error("[type] created a golem without a mind.")

	H.set_species(mob_species)
	log_game(" [H] possessed a golem shell[real_owner ? " enslaved to [key_name(real_owner)]" : ""].")
	log_admin("[key_name(H)] possessed a golem shell[real_owner ? " enslaved to [key_name(real_owner)]" : ""].")

/obj/effect/mob_spawn/ghost_role/human/golem/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isgolem(user) || !can_transfer)
		return

	var/mob/living/carbon/human/golem = user
	var/transfer_choice = tgui_alert(usr, "Transfer your soul to [src]? (Warning, your old body will die!)",,list("Yes","No"))
	if(transfer_choice != "Yes")
		return
	if(QDELETED(src) || uses <= 0)
		return
	uses -= 1
	log_game("[golem] golem-swapped into [src].")
	golem.visible_message(
		SPAN_NOTICE("A faint light leaves [golem], moving to [src] and animating it!"),
		SPAN_NOTICE("You leave your old body behind, and transfer into [src]!"),
	)
	show_flavor = FALSE
	var/mob/living/carbon/human/newgolem = create(user, golem.real_name)
	newgolem.modifiers = golem.modifiers.Copy()
	golem.death()
	if(uses==0)
		return FALSE
	return TRUE

/obj/effect/mob_spawn/ghost_role/human/golem/servant
	name = "inert servant golem shell"
	prompt_name = "servant golem"
	you_are_text = "You are a Servant Golem."
	flavour_text = "You are highly resistant to heat and cold as well as blunt trauma. You must consume minerals to maintain motion. You are unable to wear clothes, but can still use most tools."

/obj/effect/mob_spawn/ghost_role/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	prompt_name = "free golem"
	can_transfer = FALSE
	mob_species = SPECIES_GOLEM_ADAMANTINE
