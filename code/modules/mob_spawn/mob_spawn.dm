GLOBAL_LIST_EMPTY(mob_spawners)
/obj/effect/mob_spawn
	name = "Mob Spawner"
	density = TRUE
	anchored = TRUE
	//So it shows up in the map editor
	icon = 'icons/effects/mob_spawners.dmi'
	icon_state = "mobspawner"
	///A forced name of the mob, though can be overridden if a special name is passed as an argument
	var/mob_name
	///the type of the mob, you best inherit this
	var/mob_type = /mob/living/simple_animal/lizard
	///Lazy string list of factions that the spawned mob will be in upon spawn
	var/list/faction

	////Human specific stuff. Don't set these if you aren't using a human, the unit tests will put a stop to your sinful hand.

	///sets the human as a species, use a typepath (example: /datum/species/skeleton)
	var/mob_species
	///equips the human with an outfit.
	var/decl/hierarchy/outfit/outfit
	///for mappers to override parts of the outfit. really only in here for secret away missions, please try to refrain from using this out of laziness
	var/list/outfit_override
	///sets a human's hairstyle
	var/hairstyle
	///sets a human's facial hair
	var/facial_hairstyle
	///sets a human's hair color (use special for gradients, sorry)
	var/haircolor
	///sets a human's facial hair color
	var/facial_haircolor
	///sets a human's skin tone
	var/skin_tone

/obj/effect/mob_spawn/proc/create(mob/mob_possessor, newname)
	var/mob/living/spawned_mob = new mob_type(get_turf(src)) //living mobs only
	name_mob(spawned_mob, newname)
	special(spawned_mob, mob_possessor)
	equip(spawned_mob)
	return spawned_mob

/obj/effect/mob_spawn/proc/special(mob/living/spawned_mob)
	SHOULD_CALL_PARENT(TRUE)
	if(faction)
		spawned_mob.faction = faction
	if(ishuman(spawned_mob))
		var/mob/living/carbon/human/spawned_human = spawned_mob
		if(mob_species)
			spawned_human.set_species(mob_species)
		spawned_human.worn_underwear = null
		if(hairstyle)
			spawned_human.change_hair(hairstyle)
		else
			spawned_human.change_hair(random_hair_style(spawned_human.gender, spawned_human.species))
		if(facial_hairstyle)
			spawned_human.change_facial_hair(facial_hairstyle)
		else
			spawned_human.change_facial_hair(random_facial_hair_style(spawned_human.gender, spawned_human.species))
		if(haircolor)
			spawned_human.change_hair_color(hex2rgb_r(haircolor),hex2rgb_g(haircolor),hex2rgb_b(haircolor))
		else
			spawned_human.change_hair_color(rand(0,255),rand(0,255),rand(0,255))
		if(facial_haircolor)
			spawned_human.change_facial_hair_color(hex2rgb_r(facial_haircolor),hex2rgb_g(facial_haircolor),hex2rgb_b(facial_haircolor))
		else
			spawned_human.change_facial_hair_color(rand(0,255),rand(0,255),rand(0,255))
		if(skin_tone)
			spawned_human.change_skin_tone(skin_tone)
		else
			spawned_human.change_skin_tone(random_skin_tone(spawned_human.species))
		spawned_human.update_hair()
		spawned_human.update_body()

/obj/effect/mob_spawn/proc/name_mob(mob/living/spawned_mob, forced_name)
	var/chosen_name
	//passed arguments on mob spawns are number one priority
	if(forced_name)
		chosen_name = forced_name
	//then the mob name var
	else if(mob_name)
		chosen_name = mob_name
	//then if no name was chosen the one the mob has by default works great
	if(!chosen_name)
		return
	//not using an old name doesn't update records- but ghost roles don't have records so who cares
	spawned_mob.fully_replace_character_name(null, chosen_name)

/obj/effect/mob_spawn/proc/equip(mob/living/spawned_mob)
	if(!istype(spawned_mob, /mob/living/carbon/human))
		return FALSE

	if(outfit)
		var/mob/living/carbon/human/spawned_human = spawned_mob
		if(outfit_override)
			outfit = new outfit //create it now to apply vars
			for(var/outfit_var in outfit_override)
				if(!ispath(outfit_override[outfit_var]) && !isnull(outfit_override[outfit_var]))
					CRASH("outfit_override var on [mob_name] spawner has incorrect values! it must be an assoc list with outfit \"var\" = path | null")
				outfit.vars[outfit_var] = outfit_override[outfit_var]

		var/decl/hierarchy/outfit/O = outfit_by_type(outfit)

		O.equip(spawned_human)

///these mob spawn subtypes do not trigger until attacked by a ghost.
/obj/effect/mob_spawn/ghost_role
	///a short, lowercase name for the mob used in possession prompt that pops up on ghost attacks. must be set.
	var/prompt_name = ""
	///if false, you won't prompt for this role. best used for replacing the prompt system with something else like a radial, or something.
	var/prompt_ghost = TRUE
	///how many times this spawner can be used (it won't delete unless it's out of uses)
	var/uses = 1

	////descriptions

	///This should be the declaration of what the ghost role is, and maybe a short blurb after if you want. Shown in the spawner menu and after spawning first.
	var/you_are_text = ""
	///This should be the actual instructions/description/context to the ghost role. This should be the really long explainy bit, basically.
	var/flavour_text = ""
	///This is critical non-policy information about the ghost role. Shown in the spawner menu and after spawning last.
	var/important_text = ""

	///Show these on spawn? Usually used for hardcoded special flavor
	var/show_flavor = TRUE

	////bans and policy

	///which role to check for a job ban
	var/role_ban = null
	/// Typepath indicating the kind of job datum this ghost role will have. PLEASE inherit this with a new job datum, it's not hard. jobs come with policy configs.
	var/spawner_job_path = /datum/job/ghost_role

/obj/effect/mob_spawn/ghost_role/Initialize(mapload)
	. = ..()
	LAZYADD(GLOB.mob_spawners[name], src)

/obj/effect/mob_spawn/Destroy()
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= name
	return ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/ghost_role/attack_ghost(mob/user)
	if(GAME_STATE < RUNLEVEL_GAME || !loc)
		return

	if(prompt_ghost)
		var/ghost_role = tgui_alert(usr, "Become [prompt_name]? (Warning, You can no longer be revived!)",, list("Yes", "No"))
		if(ghost_role != "Yes" || !loc || QDELETED(user))
			return

	if(!config.game.ghost_spawners && !is_admin(user))
		to_chat(user, SPAN_WARNING("Ghost spawners are disabled!"))
		return

	if(!uses) //just in case
		to_chat(user, SPAN_WARNING("This spawner is out of charges!"))
		return

	if(jobban_isbanned(user, role_ban))
		to_chat(user, SPAN_WARNING("You are banned from this role!"))
		return

	if(!allow_spawn(user, silent = FALSE))
		return

	if(QDELETED(src) || QDELETED(user))
		return

	log_game("[key_name(user)] became a [prompt_name]")
	create(user)

/obj/effect/mob_spawn/ghost_role/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	if(mob_possessor)
		spawned_mob.ckey = mob_possessor.ckey
	if(show_flavor)
		var/output_message = "<span class='infoplain'><span class='big bold'>[you_are_text]</span></span>"
		if(flavour_text != "")
			output_message += "\n<span class='infoplain'><b>[flavour_text]</b></span>"
		if(important_text != "")
			output_message += "\n[SPAN_WARNING("[important_text]")]"
		to_chat(spawned_mob, output_message)
	var/datum/mind/spawned_mind = spawned_mob.mind
	if(spawned_mind)
		spawned_mob.mind.assigned_role = initial(spawner_job_path["title"])
		spawned_mind.name = spawned_mob.real_name

//multiple use mob spawner functionality here- doesn't make sense on corpses
/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname)
	. = ..()
	if(uses > 0)
		uses--
	if(!uses)
		qdel(src)

///override this to add special spawn conditions to a ghost role
/obj/effect/mob_spawn/ghost_role/proc/allow_spawn(mob/user, silent = FALSE)
	return TRUE

///these mob spawn subtypes trigger immediately (New or Initialize) and are not player controlled... since they're dead, you know?
#define CORPSE_INSTANT 1
/obj/effect/mob_spawn/corpse
	///when this mob spawn should auto trigger.
	var/spawn_when = CORPSE_INSTANT

	////damage values (very often, mappers want corpses to be mangled)

	///brute damage this corpse will spawn with
	var/brute_damage = 0
	///oxy damage this corpse will spawn with
	var/oxy_damage = 0
	///burn damage this corpse will spawn with
	var/burn_damage = 0

/obj/effect/mob_spawn/corpse/Initialize(mapload)
	. = ..()
	switch(spawn_when)
		if(CORPSE_INSTANT)
			INVOKE_ASYNC(src, .proc/create)

/obj/effect/mob_spawn/corpse/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.death(TRUE)
	spawned_mob.adjustOxyLoss(oxy_damage)
	spawned_mob.adjustBruteLoss(brute_damage)
	spawned_mob.adjustFireLoss(burn_damage)

/obj/effect/mob_spawn/corpse/create(mob/mob_possessor, newname)
	. = ..()
	qdel(src)

//almost all mob spawns in this game, dead or living, are human. so voila

/obj/effect/mob_spawn/ghost_role/human
	//gives it a base sprite instead of a mapping helper. makes sense, right?
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper_1"
	mob_type = /mob/living/carbon/human
	outfit = /decl/hierarchy/outfit/death_command

/obj/effect/mob_spawn/corpse/human
	icon_state = "corpsehuman"
	mob_type = /mob/living/carbon/human
	///disables sensors. Only makes sense on corpses because ghost roles could simply turn those on again.
	var/conceal_presence = TRUE
	///husks the corpse if true.
	var/husk = FALSE

/obj/effect/mob_spawn/corpse/human/special(mob/living/carbon/human/spawned_human)
	. = ..()
	if(husk)
		spawned_human.Drain()

/obj/effect/mob_spawn/corpse/human/equip(mob/living/carbon/human/spawned_human)
	. = ..()
	if(conceal_presence)
		var/obj/item/clothing/under/sensor_clothes = spawned_human.w_uniform
		if(istype(sensor_clothes))
			sensor_clothes.sensor_mode = SUIT_SENSOR_OFF

//don't use this in subtypes, just add 1000 brute yourself. that being said, this is a type that has 1000 brute. it doesn't really have a home anywhere else, it just needs to exist
/obj/effect/mob_spawn/corpse/human/damaged
	brute_damage = 1000
