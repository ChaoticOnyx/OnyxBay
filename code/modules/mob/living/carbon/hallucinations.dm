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

/mob/living/carbon/proc/make_hallucination(datum/hallucination/H, force = FALSE)
	if(!H.can_affect(src) && !force)
		return

	H.holder = src
	H.activate()

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


#define FAKE_FLOOD_EXPAND_TIME 5
#define FAKE_FLOOD_MAX_RADIUS 30

/datum/hallucination/fake_flood
	// Plasma starts flooding from the nearby vent
	var/turf/center
	var/list/flood_images = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/plasma.dmi'
	var/image_state = "onturf"
	var/radius = 0
	var/next_expand = 0
	duration = 1 MINUTE
	min_power = 40

/datum/hallucination/fake_flood/can_affect(mob/living/carbon/C)
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in view(7, usr))
		if(!U.welded)
			return TRUE
	return FALSE

/datum/hallucination/fake_flood/start()
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in view(7, usr))
		if(!U.welded)
			center = get_turf(U)
			break

	if(!center)
		qdel(src)
		return

	var/image/plasma_image = image(image_icon, center, image_state)
	plasma_image.alpha = 50
	plasma_image.plane = FLY_LAYER
	flood_images += plasma_image
	flood_turfs += center
	if(holder.client)
		holder.client.images |= flood_images
	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	START_PROCESSING(SSobj, src)

/datum/hallucination/fake_flood/Process()
	if((get_turf(holder) in flood_turfs) && !holder.internal)
		var/need_hud_error = TRUE
		for(var/datum/hallucination/hud_error/H in holder.hallucinations)
			if(H.errortype == "toxin")
				need_hud_error = FALSE
				break

		need_hud_error && holder.make_hallucination(new /datum/hallucination/hud_error("toxin"))
	if(next_expand <= world.time)
		next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
		if(radius > FAKE_FLOOD_MAX_RADIUS)
			return
		expand()

/datum/hallucination/fake_flood/proc/expand()
	for(var/image/I in flood_images)
		I.alpha = min(I.alpha + 50, 255)

	var/expanded = 0
	for(var/turf/FT in flood_turfs)
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_step(FT, dir)
			if((T in flood_turfs) || !FT.CanZASPass(T))
				continue
			var/image/new_plasma = image(image_icon, T, image_state)
			new_plasma.alpha = 50
			new_plasma.plane = FLY_LAYER
			flood_images += new_plasma
			flood_turfs += T
			expanded = 1
	radius += expanded
	if(holder.client)
		holder.client.images |= flood_images

/datum/hallucination/fake_flood/end()
	STOP_PROCESSING(SSobj, src)

	if(holder.client)
		holder.client.images.Remove(flood_images)
	QDEL_LIST(flood_images)
	flood_turfs.Cut()
	holder.hallucinations -= src

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
	sounds.Add(get_sfx("explosion"))
	sounds.Add(get_sfx("electric_explosion"))
	sounds.Add(get_sfx("punch"))
	..()

/datum/hallucination/sound/spooky
	min_power = 50
	sounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
	'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
	'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
	'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
	'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')

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
	spawn(5)
		holder.playsound_local(origin,gunshot,50)
	spawn(10)
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

		var/image/speech_bubble = image('icons/mob/talk.dmi',talker,"h[holder.say_test(message)]")
		speech_bubble.alpha = 0
		speech_bubble.plane = MOUSE_INVISIBLE_PLANE
		speech_bubble.layer = FLOAT_LAYER
		INVOKE_ASYNC(GLOBAL_PROC, /.proc/animate_speech_bubble, speech_bubble, list(holder.client), 3 SECONDS)

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

/datum/hallucination/evacuation
	min_power = 60 // Very high

/datum/hallucination/evacuation/can_affect()
	return prob(5)

/datum/hallucination/evacuation/start()
	holder.playsound_local(holder, 'sound/effects/Evacuation.ogg', 35)
	to_chat(holder, "<h1 class='alert'>Priority Announcement</h1><br>[SPAN("alert", replacetext(GLOB.using_map.emergency_shuttle_docked_message, "%ETD%", "3 minutes"))]")

/datum/hallucination/death
	min_power = 60 // Very high
	duration = 16 SECONDS

/datum/hallucination/death/can_affect()
	return prob(5)

/datum/hallucination/death/proc/deadsay(period)
	sleep(period)
	var/mob/fakemob

	var/list/dead_people = list()
	for(var/mob/observer/ghost/G in GLOB.player_list)
		dead_people += G

	fakemob = dead_people.len ? pick(dead_people) : holder

	var/message = pick(GLOB.hallucination_deadchat_phrases)
	to_chat(holder, SPAN_DEADSAY("[create_text_tag("dead", "DEAD")] <b>[fakemob.name]</b> says, [message]"))
	return 1

/datum/hallucination/death/start()
	holder.silent += 10
	holder.Paralyse(300)
	sleep(5)

	holder.healths.overlays = null
	holder.healths.icon_state = "health7"
	holder.should_update_healths = FALSE

	to_chat(holder, SPAN_DEADSAY("You have died."))

	if(GLOB.hallucination_deadchat_phrases.len)
		if(prob(25))
			deadsay(rand(2 SECONDS, 4 SECONDS))
		if(prob(25))
			deadsay(rand(4 SECONDS, 6 SECONDS))
		if(prob(50))
			deadsay(rand(6 SECONDS, 8 SECONDS))
		if(prob(30))
			deadsay(rand(8 SECONDS,10 SECONDS))
		if(prob(25))
			deadsay(rand(10 SECOND,12 SECONDS))


/datum/hallucination/death/end()
	holder.SetParalysis(0)
	holder.silent = 0
	holder.should_update_healths = TRUE

//Seeing stuff

/obj/item/mirage_item
	var/image/img
	var/client/client

/obj/item/mirage_item/pickup(mob/living/carbon/human/H)
	H.visible_message(SPAN_NOTICE("[H] tried to take something, but only grabbed air."),
		SPAN_WARNING("Your hand seems to go right through the [name ? src : "item"]. It's like it doesn't exist."))

	client.images -= img
	qdel(src)

/datum/hallucination/item_mirage
	duration = 30 SECONDS
	var/number = 1
	var/list/items = list() // items
	var/sound // Pop!
	var/volume = 25

/datum/hallucination/item_mirage/Destroy()
	end()
	. = ..()

/datum/hallucination/item_mirage/proc/generate_mirage(turf/loc)
	var/obj/item/mirage_item/I = new(loc)
	I.name = null // it will be visible to anyone with RMB and with RMB only, because it have no icon

	switch(rand(1,6))
		if(1) // gun
			var/icon/icon = new('icons/obj/gun.dmi')

			var/list/icon_states = icon.IconStates()
			icon_states -= list("energykill", "energystan", "nenergy-g", "nenergy-f", "nenergy-c",
								"nucgun-stun", "nucgun-kill", "nucgun-100", "nucgun-75", "nucgun-50",
								"nucgun-25", "nucgun-0", "nucgun-whee", "nucgun-clean", "nucgun-light",
								"nucgun-crit", "unused")
			I.img = image(icon, icon_state = pick(icon_states), loc = I)
		if(2) // bomb
			var/icon/icon = new('icons/obj/grenade.dmi')
			I.img = image(icon, icon_state = pick(icon.IconStates()), loc = I)
		if(3) // weapon
			var/icon/icon = new('icons/obj/weapons.dmi')
			var/list/icon_state = pick(icon.IconStates())
			I.img = image(icon, icon_state = icon_state, loc = I)

			if(findtext(icon_state, "sword"))
				I.name = "Energy sword"
			if(findtext(icon_state, "stanbaton"))
				I.name = "Stanbaton"
		if(4) // card
			var/icon/icon = new('icons/obj/card.dmi')
			var/icon_state = pick(icon.IconStates())
			I.img = image(icon, icon_state = icon_state, loc = I)

			switch(icon_state)
				if("emag")
					I.name = "Cryptographic Sequencer"
				if("gold")
					I.name = "captain's spare ID"
		if(5) // trash
			var/icon/icon = new('icons/obj/trash.dmi')
			I.img = image(icon, icon_state = pick(icon.IconStates()), loc = I)
		if(6) // money
			I.name = "Cash"
			I.img = image('icons/obj/items.dmi', "spacecash[pick(1000,500,200,100,50)]", loc = I)


	return I

/datum/hallucination/item_mirage/start()
	var/list/possible_points = list()
	for(var/turf/simulated/floor/F in view(holder, world.view+1))
		possible_points += F
	if(!possible_points.len)
		return
	for(var/i = 1 to number)
		var/turf/simulated/floor/point = pick(possible_points)
		var/obj/item/mirage_item/thing = generate_mirage(point)
		thing.client = holder.client
		items += thing
		if(sound)
			holder.playsound_local(point, sound, volume)
		holder.client.images += thing.img

/datum/hallucination/item_mirage/end()
	if(!holder.client)
		return
	for(var/obj/item/mirage_item/I in items)
		holder.client.images -= I.img
		qdel(I)

// Singulo
/obj/item/mirage_item/singulo
	var/target

/obj/item/mirage_item/singulo/New(loc)
	START_PROCESSING(SSobj, src)

/obj/item/mirage_item/singulo/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/mirage_item/singulo/Process()
	step_to(src, target, 1)
	if(get_dist(src, target) < 2)
		qdel(src)
		var/mob/living/carbon/human/H = target
		H?.Paralyse(5)
		H.playsound_local(get_turf(src), sound('sound/effects/bang.ogg'), 70, 1, 30)

/datum/hallucination/item_mirage/singulo
	number = 1
	min_power = 50

/datum/hallucination/item_mirage/singulo/generate_mirage(turf/loc)
	var/obj/item/mirage_item/singulo/I = new(loc)
	I.img = image('icons/effects/96x96.dmi', loc = I, icon_state = "singularity_s3")
	I.target = holder
	return I

// Balloons

/obj/item/mirage_item/balloon
	var/target
	var/mdir

/obj/item/mirage_item/balloon/New(loc)
	START_PROCESSING(SSfastprocess, src)
	mdir = rand(-1, 1)
	..(loc)

/obj/item/mirage_item/balloon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/obj/item/mirage_item/balloon/Process()
	pixel_x += sin(world.time) * 16 * mdir * rand(-1, 1)
	pixel_y += cos(world.time) * 16 * mdir * rand(-1, 1)

	if(!prob(10))
		return
	step_to(src, target, 1)
	if(get_dist(src, target) < 2)
		step_away(src, target, 5, 128)

/obj/item/mirage_item/balloon/pickup(mob/living/carbon/human/H)
	H.visible_message(SPAN_NOTICE("[H] tried to take something, but only grabbed air."),
		SPAN_WARNING("Your hand seems to go right through the [name ? src : "item"]. It's like it doesn't exist."))
	qdel(src)

/datum/hallucination/item_mirage/balloon
	number = 5
	min_power = 20

/datum/hallucination/item_mirage/balloon/generate_mirage(turf/loc)
	var/obj/item/mirage_item/balloon/I = new(loc)
	I.img = image('icons/obj/weapons.dmi', loc = I, icon_state = pick("syndballoon", "ntballoon", "snailballoon"))
	I.target = holder
	return I

// Black holes

/obj/item/mirage_item/bhole
	var/target
	var/mdir

/obj/item/mirage_item/bhole/New(loc)
	START_PROCESSING(SSfastprocess, src)
	mdir = rand(-1, 1)
	..(loc)

/obj/item/mirage_item/bhole/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/obj/item/mirage_item/bhole/Process()
	pixel_x += sin(world.time) * 32 * mdir * rand(-1, 1)
	pixel_y += cos(world.time) * 32 * mdir * rand(-1, 1)

	if(get_dist(src, target) < 2)
		var/mob/living/carbon/human/H = target
		if(!H)
			return
		H.Paralyse(1)
		to_chat(H, SPAN("danger", "*BANG*"))
		H.playsound_local(get_turf(src), sound('sound/effects/bang.ogg'), 50, 1, 30)
		qdel(src)
	else if(prob(5))
		step_rand(src)
	else if(prob(6))
		step_to(src, target)

/obj/item/mirage_item/bhole/pickup(mob/living/carbon/human/H)
	qdel(src)
/datum/hallucination/item_mirage/bhole
	number = 3
	min_power = 40

/datum/hallucination/item_mirage/bhole/generate_mirage(turf/loc)
	var/obj/item/mirage_item/bhole/I = new(loc)
	I.img = image('icons/obj/objects.dmi', loc = I, icon_state = "bhole3")
	I.target = holder
	return I

// Mirage
/datum/hallucination/mirage
	duration = 30 SECONDS
	var/number = 8
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

/datum/hallucination/mirage/crayon/generate_mirage()
	var/icon/T  = new('icons/effects/crayondecal.dmi')
	var/icon/T2 = new('icons/effects/crayongraffiti.dmi')
	var/list/states = T.IconStates() | T2.IconStates()
	for(var/S in states)
		if(length(S) <= 2 || copytext(S, -2) == "_s")
			states.Remove(S)

	var/state = pick(states)

	var/main  = rgb(rand(0,255), rand(0, 255), rand(0, 255))
	var/shade = rgb(rand(0,255), rand(0, 255), rand(0, 255))
	return image(get_crayon_preview(main, shade, state))

/datum/hallucination/mirage/crayon/New()
	number = rand(5, 15)


//Blood and aftermath of firefight
/datum/hallucination/mirage/carnage
	min_power = 40
	number = 20


/datum/hallucination/mirage/carnage/generate_mirage()
	if(prob(50))
		var/image/I = image('icons/effects/blood.dmi', pick("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7"), layer = BELOW_TABLE_LAYER)
		I.color = COLOR_BLOOD_HUMAN
		return I
	else
		var/image/I = image('icons/obj/ammo.dmi', "s-casing-spent", layer = BELOW_TABLE_LAYER)
		I.layer = BELOW_TABLE_LAYER
		I.dir = pick(GLOB.alldirs)
		I.pixel_x = rand(-10, 10)
		I.pixel_y = rand(-10, 10)
		return I

/datum/hallucination/mirage/portal
	min_power = 50

/datum/hallucination/mirage/portal/generate_mirage()
	sound = 'sound/effects/phasein.ogg'
	return image('icons/obj/stationobjs.dmi', prob(50) ? "portal" : "portal1", layer = ABOVE_OBJ_LAYER)

/datum/hallucination/mirage/explosions
	min_power = 50
	duration = 10
	number = 12

/datum/hallucination/mirage/explosions/generate_mirage()
	sound = get_sfx("explosion")
	return image('icons/effects/96x96.dmi', prob(50) ? "explosion" : "explosionfast", layer = FLY_LAYER)

//Fake telepathy
/datum/hallucination/telepahy
	allow_duplicates = 0
	duration = 20 MINUTES

/datum/hallucination/telepahy/start()
	to_chat(holder,"<span class = 'notice'>You expand your mind outwards.</span>")
	holder.verbs += /mob/living/carbon/human/proc/fakeremotesay

/datum/hallucination/telepahy/end()
	if(holder)
		holder.verbs -= /mob/living/carbon/human/proc/fakeremotesay

/mob/living/carbon/human/proc/fakeremotesay()
	set name = "Telepathic Message"
	set category = "Superpower"

	if(!hallucination_power)
		src.verbs -= /mob/living/carbon/human/proc/fakeremotesay
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
	if (isnull(target))
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
		holder.playsound_local(get_turf(holder),"punch",rand(80, 100))

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
		fake_look.transform = turn(fake.transform, -90)
	holder.client.images |= fake_look
	log_misc("[holder.name] is hallucinating that [origin.name] is the [fake.name]")

/datum/hallucination/fake_appearance/proc/get_living_sublist(var/list/subtypes, var/list/exclude)
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
	QDEL_NULL(fake_look)

/datum/hallucination/fake_appearance/Destroy()
	end()
	. = ..()

/mob/living/carbon/proc/get_fake_appearance(mob/M)
	for(var/datum/hallucination/fake_appearance/hallutination in hallucinations)
		if(M == hallutination.origin)
			return hallutination.fake

/datum/hallucination/hud_error
	duration = 10 SECONDS
	min_power = 30
	var/obj/screen/fake
	var/errortype = ""

/datum/hallucination/hud_error/New(type_)
	if(type_)
		errortype = type_
	else
		errortype = pick("oxygen", "toxin", "fire", "body temperature", "pressure", "nutrition")

/datum/hallucination/hud_error/can_affect(mob/living/carbon/C)
	if(!..())
		return FALSE
	return istype(C, /mob/living/carbon/human)

/datum/hallucination/hud_error/start()
	ASSERT(istype(holder, /mob/living/carbon/human))
	var/mob/living/carbon/human/H = holder
	var/obj/screen/origin
	switch(errortype)
		if("oxygen")
			origin = H.oxygen
		if("toxin")
			origin = H.toxin
		if("fire")
			origin = H.fire
		if("body temperature")
			origin = H.bodytemp
		if("pressure")
			origin = H.pressure
		if("nutrition")
			origin = H.nutrition
	fake = new
	fake.name = origin.name
	fake.icon = origin.icon
	fake.appearance_flags = origin.appearance_flags
	fake.unacidable = origin.unacidable
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
