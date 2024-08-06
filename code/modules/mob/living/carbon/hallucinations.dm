/mob/living/carbon/var/hallucination_power = 0
/mob/living/carbon/var/hallucination_duration = 0
/mob/living/carbon/var/next_hallucination
/mob/living/carbon/var/list/hallucinations = list()

/mob/living/carbon/proc/hallucination(duration, power)
	hallucination_duration = max(hallucination_duration, duration)
	hallucination_power = max(hallucination_power, power)

/mob/living/carbon/proc/adjust_hallucination(duration, power)
	hallucination_duration = max(0, hallucination_duration + duration)
	hallucination_power = max(0, hallucination_power + power)

/mob/living/carbon/proc/handle_hallucinations()
	//Tick down the duration
	hallucination_duration = max(0, hallucination_duration - 1)
	if(chem_effects[CE_MIND] > 0)
		hallucination_duration = max(0, hallucination_duration - 1)

	//Adjust power if we have some chems that affect it
	if(chem_effects[CE_MIND] < 0)
		hallucination_power = min(hallucination_power++, 50)
	if(chem_effects[CE_MIND] < -1)
		hallucination_power = hallucination_power++
	if(chem_effects[CE_MIND] > 0)
		hallucination_power = max(hallucination_power - chem_effects[CE_MIND], 0)

	//See if hallucination is gone
	if(!hallucination_power)
		hallucination_duration = 0
		return
	if(!hallucination_duration)
		hallucination_power = 0
		return

	if(!client || stat || world.time < next_hallucination)
		return
	if(chem_effects[CE_MIND] > 0 && prob(chem_effects[CE_MIND]*40)) //antipsychotics help
		return
	var/hall_delay = rand(10,20) SECONDS

	if(hallucination_power < 50)
		hall_delay *= 2
	next_hallucination = world.time + hall_delay
	var/list/candidates = list()
	for(var/T in subtypesof(/datum/hallucination/))
		var/datum/hallucination/H = new T
		if(H.can_affect(src))
			candidates += H
	if(candidates.len)
		var/datum/hallucination/H = pick(candidates)
		H.holder = src
		H.activate()

/mob/living/carbon/proc/is_hallucinating()
	return hallucination_power && hallucination_duration

//////////////////////////////////////////////////////////////////////////////////////////////////////
//Hallucination effects datums
//////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/hallucination
	var/mob/living/carbon/holder
	var/allow_duplicates = 1
	var/duration = 0
	var/min_power = 0 //at what levels of hallucination power mobs should get it
	var/max_power = INFINITY

/datum/hallucination/proc/start()

/datum/hallucination/proc/end()

/datum/hallucination/proc/can_affect(mob/living/carbon/C)
	if(!C.client)
		return 0
	if(min_power > C.hallucination_power)
		return 0
	if(max_power < C.hallucination_power)
		return 0
	if(!allow_duplicates && (locate(type) in C.hallucinations))
		return 0
	return 1

/datum/hallucination/Destroy()
	. = ..()
	holder = null

/datum/hallucination/proc/activate()
	if(!holder || !holder.client)
		return
	holder.hallucinations += src
	start()
	spawn(duration)
		if(holder)
			end()
			holder.hallucinations -= src
		qdel(src)


//Playing a random sound
/datum/hallucination/sound
	var/list/sounds = list('sound/machines/airlock.ogg','sound/machines/windowdoor.ogg','sound/machines/twobeep.ogg')

/datum/hallucination/sound/start()
	var/turf/T = locate(holder.x + rand(6,11), holder.y + rand(6,11), holder.z)
	holder.playsound_local(T,pick(sounds),70)

/datum/hallucination/sound/tools
	sounds = list('sound/items/Ratchet.ogg','sound/items/Welder.ogg','sound/items/Crowbar.ogg','sound/items/Screwdriver.ogg')

/datum/hallucination/sound/danger
	min_power = 20
	max_power = 50
	sounds = list('sound/effects/glass_step.ogg', 'sound/effects/hit_on_shattered_glass.ogg', 'sound/effects/fighting/smash.ogg')

/datum/hallucination/sound/danger/start()
	sounds.Add(GET_SFX(SFX_EXPLOSION))
	sounds.Add(GET_SFX(SFX_EXPLOSION_ELECTRIC))
	sounds.Add(GET_SFX(SFX_FIGHTING_PUNCH))
	..()

/datum/hallucination/sound/spooky
	min_power = 50
	sounds = list(
		'sound/effects/ghost.ogg',
		'sound/effects/ghost2.ogg',
		'sound/effects/Heart Beat.ogg',
		'sound/effects/screech.ogg',
		'sound/hallucinations/behind_you1.ogg',
		'sound/hallucinations/behind_you2.ogg',
		'sound/hallucinations/far_noise.ogg',
		'sound/hallucinations/growl1.ogg',
		'sound/hallucinations/growl2.ogg',
		'sound/hallucinations/growl3.ogg',
		'sound/hallucinations/im_here1.ogg',
		'sound/hallucinations/im_here2.ogg',
		'sound/hallucinations/i_see_you1.ogg',
		'sound/hallucinations/i_see_you2.ogg',
		'sound/hallucinations/look_up1.ogg',
		'sound/hallucinations/look_up2.ogg',
		'sound/hallucinations/over_here1.ogg',
		'sound/hallucinations/over_here2.ogg',
		'sound/hallucinations/over_here3.ogg',
		'sound/hallucinations/turn_around1.ogg',
		'sound/hallucinations/turn_around2.ogg',
		'sound/hallucinations/veryfar_noise.ogg',
		'sound/hallucinations/wail.ogg',
		'sound/hallucinations/goblin_aggro0.ogg',
		'sound/hallucinations/goblin_aggro1.ogg',
		'sound/hallucinations/goblin_aggro2.ogg',
		'sound/hallucinations/goblin_aggro3.ogg',
		'sound/hallucinations/goblin_death0.ogg',
		'sound/hallucinations/goblin_death1.ogg',
		'sound/hallucinations/goblin_idle0.ogg',
		'sound/hallucinations/goblin_idle1.ogg',
		'sound/hallucinations/goblin_idle2.ogg',
		'sound/hallucinations/goblin_idle3.ogg',
		'sound/hallucinations/goblin_idle4.ogg',
		'sound/hallucinations/goblin_laugh0.ogg',
		'sound/hallucinations/goblin_laugh1.ogg',
		'sound/hallucinations/goblin_pain0.ogg',
		'sound/hallucinations/goblin_pain1.ogg',
		'sound/hallucinations/goblin_pain2.ogg',
		'sound/hallucinations/goblin_pain3.ogg',
		'sound/hallucinations/goblin_pain4.ogg',
		'sound/hallucinations/goblin_painscream0.ogg',
		'sound/hallucinations/goblin_painscream1.ogg',
		'sound/hallucinations/goblin_painscream2.ogg',
		'sound/hallucinations/goblin_painscream3.ogg',
		'sound/hallucinations/goblin_painscream4.ogg',
	)

//Hearing someone being shot twice
/datum/hallucination/gunfire
	var/gunshot
	var/turf/origin
	duration = 15
	min_power = 30

/datum/hallucination/gunfire/start()
	gunshot = pick('sound/effects/weapons/gun/fire_strong.ogg', 'sound/effects/weapons/gun/gunshot2.ogg', 'sound/effects/weapons/gun/fire_shotgun.ogg', 'sound/effects/weapons/gun/gunshot.ogg','sound/effects/weapons/energy/Taser.ogg')
	origin = locate(holder.x + rand(4,8), holder.y + rand(4,8), holder.z)
	holder.playsound_local(origin,gunshot,50)

/datum/hallucination/gunfire/end()
	holder.playsound_local(origin,gunshot,50)

//Hearing someone talking to/about you.
/datum/hallucination/talking/can_affect(mob/living/carbon/C)
	if(!..())
		return 0
	for(var/mob/living/M in oview(C))
		return TRUE

/datum/hallucination/talking
	min_power = 15

/datum/hallucination/talking/start()
	var/sanity = 2 //even insanity needs some sanity
	for(var/mob/living/talker in oview(holder))
		var/message
		if(prob(80) && GLOB.hallucination_phrases.len)
			var/list/phrases = new()
			for(var/phrase in GLOB.hallucination_phrases)
				var/separator_position = findtext(phrase, "|")
				var/required_power = separator_position ? text2num(copytext(phrase, 1, separator_position)) : 0
				if(holder.hallucination_power >= required_power)
					phrases += separator_position ? copytext(phrase, separator_position + 1) : phrase
			ASSERT(phrases.len)
			message = pick(phrases)
			holder.hear_say(message, speaker = talker)
			log_misc("[holder.name] is hallucinating about [talker.name] SAYS : [message]")
		else
			to_chat(holder,"<B>[talker.name]</B> points at [holder.name]")
			to_chat(holder,"<span class='game say'><span class='name'>[talker.name]</span> says something softly.</span>")

		holder.show_bubble_to_client(holder.bubble_icon, holder.say_test(message), talker, holder.client)

		sanity-- //don't spam them in very populated rooms.
		if(!sanity)
			return

//Spiderling skitters
/datum/hallucination/skitter/start()
	to_chat(holder,"<span class='notice'>The spiderling skitters[pick(" away"," around","")].</span>")

//Spiders in your body
/datum/hallucination/spiderbabies
	min_power = 40

/datum/hallucination/spiderbabies/start()
	if(istype(holder,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = holder
		var/obj/O = pick(H.organs)
		to_chat(H,"<span class='warning'>You feel something [pick("moving","squirming","skittering")] inside of your [O.name]!</span>")

/datum/hallucination/virus
	duration = 1 MINUTE // Just prevents duplicates for this duration
	allow_duplicates = 0

/datum/hallucination/virus/start()
	var/list/effects = list(STOMACH_EFFECT_WARNING, GUNCK_EFFECT_WARNING, SNEEZE_EFFECT_WARNING, DISORIENTATION_EFFECT_WARNING, STIMULANT_EFFECT_WARNING, HAIR_EFFECT_WARNING, CONFUSION_EFFECT_WARNING, IMMORTAL_AGING_EFFECT_WARNING)
	if(istype(holder,/mob/living/carbon/human))
		var/obj/item/organ/external/organ = pick(holder.organs)
		if(organ)
			effects.Add(ITCH_EFFECT_WARNING(organ.name), IMMORTAL_RECOVER_EFFECT_WARNING(organ.name), IMMORTAL_HEALING_EFFECT_WARNING(organ.name), ORGANS_SHUTDOWN_EFFECT_WARNING(organ.name), GIBBINGTONS_EFFECT_WARNING(organ.name))
	to_chat(holder, pick(effects))

//Seeing stuff
/datum/hallucination/mirage
	duration = 30 SECONDS
	var/number = 1
	var/list/things = list() //list of images to display
	var/sound // Pop!
	var/volume = 25

/datum/hallucination/mirage/Destroy()
	end()
	. = ..()

/datum/hallucination/mirage/proc/generate_mirage()
	var/icon/T = new('icons/obj/trash.dmi')
	return image(T, pick(T.IconStates()), layer = BELOW_TABLE_LAYER)

/datum/hallucination/mirage/start()
	var/list/possible_points = list()
	for(var/turf/simulated/floor/F in view(holder, world.view+1))
		possible_points += F
	if(possible_points.len)
		for(var/i = 1 to number)
			var/image/thing = generate_mirage()
			things += thing
			var/turf/simulated/floor/point = pick(possible_points)
			thing.loc = point
			if(sound)
				holder.playsound_local(point, sound, volume)
		holder.client.images += things

/datum/hallucination/mirage/end()
	if(holder.client)
		holder.client.images -= things

//LOADSEMONEY
/datum/hallucination/mirage/money
	min_power = 20
	max_power = 45
	number = 2

/datum/hallucination/mirage/money/generate_mirage()
	return image('icons/obj/items.dmi', "spacecash[pick(1000,500,200,100,50)]", layer = BELOW_TABLE_LAYER)

//Blood and aftermath of firefight
/datum/hallucination/mirage/carnage
	min_power = 40
	number = 10

/datum/hallucination/mirage/carnage/generate_mirage()
	if(prob(50))
		var/image/I = image('icons/effects/blood.dmi', pick("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7"), layer = BELOW_TABLE_LAYER)
		I.color = COLOR_BLOOD_HUMAN
		return I
	else
		var/image/I = image('icons/obj/ammo.dmi', "s-casing-spent", layer = BELOW_TABLE_LAYER)
		I.layer = BELOW_TABLE_LAYER
		I.dir = pick(GLOB.alldirs)
		I.pixel_x = rand(-10,10)
		I.pixel_y = rand(-10,10)
		return I

/datum/hallucination/mirage/portal
	min_power = 50

/datum/hallucination/mirage/portal/generate_mirage()
	sound = 'sound/effects/phasein.ogg'
	if(prob(90))
		return image('icons/obj/stationobjs.dmi', "portal", layer = ABOVE_OBJ_LAYER)
	else
		return image('icons/obj/stationobjs.dmi', "portal1", layer = ABOVE_OBJ_LAYER)

//Fake telepathy
/datum/hallucination/telepahy
	allow_duplicates = 0
	duration = 20 MINUTES

/datum/hallucination/telepahy/start()
	to_chat(holder,"<span class = 'notice'>You expand your mind outwards.</span>")
	grant_verb(holder, /mob/living/carbon/human/proc/fakeremotesay)

/datum/hallucination/telepahy/end()
	if(holder)
		revoke_verb(holder, /mob/living/carbon/human/proc/fakeremotesay)

/mob/living/carbon/human/proc/fakeremotesay()
	set name = "Telepathic Message"
	set category = "Superpower"

	if(!hallucination_power)
		revoke_verb(src, /mob/living/carbon/human/proc/fakeremotesay)
		return

	if(stat)
		to_chat(usr, "<span class = 'warning'>You're not in any state to use your powers right now!'</span>")
		return

	if(chem_effects[CE_MIND] > 0)
		to_chat(usr, "<span class = 'warning'>Chemicals in your blood prevent you from using your power!'</span>")

	var/list/creatures = list()
	for(var/mob/living/carbon/C in SSmobs.mob_list)
		creatures += C
	creatures -= usr
	var/mob/target = input("Who do you want to project your mind to ?") as null|anything in creatures
	if (QDELETED(target))
		return

	var/msg = sanitize(input(usr, "What do you wish to transmit"))
	show_message("<span class = 'notice'>You project your mind into [target.name]: \"[msg]\"</span>")
	if(!stat && prob(20))
		say(msg)

//Fake attack
/datum/hallucination/fakeattack
	min_power = 30

/datum/hallucination/fakeattack/can_affect(mob/living/carbon/C)
	if(!..())
		return 0
	for(var/mob/living/M in oview(C,1))
		return TRUE

/datum/hallucination/fakeattack/start()
	for(var/mob/living/M in oview(holder,1))
		to_chat(holder, "<span class='danger'>[M] has punched [holder]!</span>")
		holder.playsound_local(get_turf(holder),SFX_FIGHTING_PUNCH,rand(80, 100))

//Fake injection
/datum/hallucination/fakeattack/hypo
	min_power = 30

/datum/hallucination/fakeattack/hypo/start()
	to_chat(holder, "<span class='notice'>You feel a tiny prick!</span>")

/datum/hallucination/fake_appearance
	duration = 1 MINUTE
	min_power = 45
	var/radius = 7
	var/mob/living/origin
	var/mob/fake
	var/image/fake_look

/datum/hallucination/fake_appearance/can_affect(mob/living/carbon/C)
	if(!..())
		return FALSE
	for(var/mob/living/M in orange(radius, C))
		if(!M.is_invisible_to(C))
			return TRUE

/datum/hallucination/fake_appearance/start()
	var/list/origin_candidates = new()
	for(var/mob/living/O in orange(radius, holder)) //Including visible, but not in view
		if(!O.is_invisible_to(holder))
			origin_candidates += O
	for(var/datum/hallucination/fake_appearance/other in holder.hallucinations)
		if(other != src)
			origin_candidates -= other.origin // Forbid multiappearances on the same mob
	if(!origin_candidates.len)
		end()
		return
	origin = pick(origin_candidates)

	var/list/targets = new()
	for(var/datum/objective/objective in holder.mind.objectives)
		if(objective.target && objective.target.current)
			targets |= objective.target.current
	var/fake_type = pick(
		targets.len               * 550; "target",
		GLOB.human_mob_list.len   * 45;  "human",
		GLOB.silicon_mob_list.len * 350; "cyborg",
		GLOB.living_mob_list_.len * 6;   "animal",
		GLOB.living_mob_list_.len * 5;   "xenomorph",
		GLOB.living_mob_list_.len * 2;   "bot",
		GLOB.living_mob_list_.len    ;   "mouse",
		GLOB.ghost_mob_list.len   * 3;   "ghost"
	)

	var/list/fake_candidates = new()
	switch(fake_type)
		if("target")
			fake_candidates = targets
		if("human")
			var/look_for_same_z = prob(80)
			for(var/mob/living/F in GLOB.human_mob_list)
				if((holder.z == F.z) == look_for_same_z)
					fake_candidates += F
		if("cyborg")
			fake_candidates = GLOB.silicon_mob_list
		if("animal")
			fake_candidates = get_living_sublist(list(/mob/living/simple_animal), list(/mob/living/simple_animal/mouse))
		if("xenomorph")
			fake_candidates = get_living_sublist(list(/mob/living/carbon/alien, /mob/living/carbon/metroid, /mob/living/deity))
		if("bot")
			fake_candidates = get_living_sublist(list(/mob/living/bot))
		if("mouse")
			fake_candidates = get_living_sublist(list(/mob/living/simple_animal/mouse))
		if("ghost")
			fake_candidates = GLOB.ghost_mob_list
	if(!fake_candidates)
		end()
		return
	fake_candidates -= origin
	if(!fake_candidates.len)
		end()
		return
	fake = pick(fake_candidates)

	fake_look = new()
	fake_look.appearance = fake.appearance
	fake_look.loc = origin
	fake_look.dir = null // This makes image to always rotate with the origin
	fake_look.override = 1
	if(isghost(fake))
		fake_look.invisibility = 0
	if(fake.lying)
		fake_look.SetTransform(others = fake.transform, rotation = -90)
	holder.client.images |= fake_look

	register_signal(holder, SIGNAL_MOB_EXAMINED, nameof(.proc/on_mob_examined))
	register_signal(holder, SIGNAL_MOB_EXAMINED_MORE, nameof(.proc/on_mob_examined_more))

	log_misc("[holder.name] is hallucinating that [origin.name] is the [fake.name]")

/datum/hallucination/fake_appearance/proc/get_living_sublist(list/subtypes, list/exclude)
	var/list/same_z_candidates = new()
	var/list/other_z_candidates = new()
	for(var/mob/living/F in GLOB.living_mob_list_)
		for(var/subtype in subtypes)
			if(istype(F, subtype) && !(F:type in exclude))
				if(holder.z == F.z)
					same_z_candidates += F
				else
					other_z_candidates += F
	if (same_z_candidates.len && (!other_z_candidates.len || prob(80)))
		return same_z_candidates
	if (other_z_candidates.len)
		return other_z_candidates
	// If both lists are empty, return nothing

/datum/hallucination/fake_appearance/end()
	holder.hallucinations -= src
	if(!fake_look)
		return // No ASSERT is needed, ending is correct

	if(holder.client)
		holder.client.images -= fake_look

	unregister_signal(holder, SIGNAL_EXAMINED)
	unregister_signal(holder, SIGNAL_EXAMINED_MORE)

	QDEL_NULL(fake_look)

/datum/hallucination/fake_appearance/Destroy()
	end()
	. = ..()

/datum/hallucination/fake_appearance/proc/on_mob_examined(datum/source, mob/user, list/examine_result)
	examine_result = fake.examine(user)

/datum/hallucination/fake_appearance/proc/on_mob_examined_more(datum/source, mob/user, list/examine_result)
	examine_result = fake.examine_more(user)

/mob/living/carbon/proc/get_fake_appearance(mob/M)
	for(var/datum/hallucination/fake_appearance/hallutination in hallucinations)
		if(M == hallutination.origin)
			return hallutination.fake

/datum/hallucination/hud_error
	duration = 10 SECONDS
	min_power = 30
	var/atom/movable/screen/fake

/datum/hallucination/hud_error/can_affect(mob/living/carbon/C)
	if(!..())
		return FALSE
	return istype(C, /mob/living/carbon/human)

/datum/hallucination/hud_error/start()
	ASSERT(istype(holder, /mob/living/carbon/human))
	var/mob/living/carbon/human/H = holder
	var/atom/movable/screen/origin = pick(H.toxin, H.oxygen, H.fire, H.bodytemp, H.pressure, H.nutrition_icon)
	fake = new()
	fake.name = origin.name
	fake.icon = origin.icon
	fake.appearance_flags = origin.appearance_flags
	fake.globalscreen = FALSE
	fake.plane = HUD_PLANE
	fake.layer = HUD_ABOVE_ITEM_LAYER
	fake.screen_loc = origin.screen_loc
	switch(origin.name)
		if("oxygen")
			fake.icon_state = "oxy1"
		if("toxin")
			fake.icon_state = "tox1"
		if("fire")
			fake.icon_state = "fire[pick(1, 2)]"
		if("body temperature")
			fake.icon_state = "temp[pick(-4, -3, -2, 2, 3, 4)]"
		if("pressure")
			fake.icon_state = "pressure[pick(-2, -1, 1, 2)]"
		if("nutrition")
			fake.icon_state = "nutrition[pick(0, 3, 4)]"
		else
			end()
			return
	holder.client.screen |= fake

/datum/hallucination/hud_error/end()
	if(!fake)
		return // No ASSERT is needed, ending is correct
	if(holder.client)
		holder.client.screen -= fake
	qdel(fake)

/datum/hallucination/hud_error/Destroy()
	end()
	. = ..()

/datum/hallucination/room_effects
	duration = 30 SECONDS
	min_power = 40
	var/list/effects = new()

/datum/hallucination/room_effects/can_affect(mob/living/carbon/C)
	if(!..())
		return FALSE
	return istype(get_turf(C), /turf/simulated)

/datum/hallucination/room_effects/start()
	var/turf/simulated/location = get_turf(holder)
	ASSERT(istype(location))
	var/zone/room = location.zone
	var/list/available_effects = list("icons/effects/tile_effects.dmi" = "plasma", "icons/effects/tile_effects.dmi" = "sleeping_agent", "icons/effects/tile_effects.dmi" = "plasma-purple", "icons/effects/effects.dmi" = "electricity", "icons/effects/fire.dmi" = "real_fire") // Kinda ironic to use real_fire for non-real fire
	var/chosen = rand(1, available_effects.len)
	for(var/turf/simulated/T in room.contents)
		effects.Add(image(icon = file(available_effects[chosen]), loc = T, icon_state = available_effects[available_effects[chosen]], layer = FLY_LAYER))
	holder.client.images |= effects

/datum/hallucination/room_effects/end()
	if(!effects)
		return // Already qdeleted
	if(holder.client)
		holder.client.images -= effects
	QDEL_NULL_LIST(effects)

/datum/hallucination/room_effects/Destroy()
	end()
	. = ..()

/datum/hallucination/coloring
	duration = 30 SECONDS
	max_power = 55
	var/list/colored_images = new()

/datum/hallucination/coloring/start()
	for(var/obj/item/I in view(holder.client))
		var/image/colored = new()
		colored.appearance = I.appearance
		colored.loc = I
		colored.dir = I.dir
		colored.pixel_x = 0
		colored.pixel_y = 0
		colored.pixel_z = 0
		colored.pixel_w = 0
		colored.override = 0 // This way, increasing I.plane or I.layer will reveal original icon. If you want to change this behavior, you need to make colored.override = 1, and manually change colored.plane and colored.layer along with original`s, because it's not inherited
		colored.color = rgb(rand(60,255), rand(60,255), rand(60,255))
		colored_images += colored
	holder.client.images |= colored_images

/datum/hallucination/coloring/end()
	if(!colored_images)
		return // Already qdeleted
	if(holder.client)
		holder.client.images -= colored_images
	QDEL_NULL_LIST(colored_images)

/datum/hallucination/coloring/Destroy()
	end()
	. = ..()
