// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)


// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define LIGHT_BULB_TEMPERATURE 400 //K - used value for a 60W bulb
#define LIGHTING_POWER_FACTOR 5		//5W per luminosity * range

/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1

	layer = ABOVE_HUMAN_LAYER

	var/stage = 1
	var/fixture_type = /obj/machinery/light
	var/sheets_refunded = 2

/obj/machinery/light_construct/New(atom/newloc, newdir, atom/fixture = null)
	..(newloc)

	if(newdir)
		set_dir(newdir)

	if(istype(fixture))
		if(istype(fixture, /obj/machinery/light))
			fixture_type = fixture.type
		fixture.transfer_fingerprints_to(src)

	update_icon()

/obj/machinery/light_construct/on_update_icon()
	switch(stage)
		if(1) icon_state = "tube-construct-stage1"
		if(2) icon_state = "tube-construct-stage2"
		if(3) icon_state = "tube-empty"

/obj/machinery/light_construct/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) > 2)
		return

	switch(src.stage)
		if(1) . += "\nIt's an empty frame."
		if(2) . += "\nIt's wired."
		if(3) . += "\nThe casing is closed."

/obj/machinery/light_construct/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)
	if(isWrench(W))
		if (src.stage == 1)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			to_chat(usr, "You begin deconstructing \a [src].")
			if (!do_after(usr, 30,src))
				return
			new /obj/item/stack/material/steel( get_turf(src.loc), sheets_refunded )
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
			qdel(src)
		if (src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

		if (src.stage == 3)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(isWirecutter(W))
		if (src.stage != 2) return
		src.stage = 1
		src.update_icon()
		new /obj/item/stack/cable_coil(get_turf(src.loc), 1, "red")
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		return

	if(isCoil(W))
		if (src.stage != 1) return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			src.stage = 2
			src.update_icon()
			user.visible_message("[user.name] adds wires to [src].", \
				"You add wires to [src].")
		return

	if(isScrewdriver(W))
		if (src.stage == 2)
			src.stage = 3
			src.update_icon()
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)

			var/obj/machinery/light/newlight = new fixture_type(src.loc, src)
			newlight.set_dir(src.dir)

			src.transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1

	layer = ABOVE_HUMAN_LAYER
	stage = 1
	fixture_type = /obj/machinery/light/small
	sheets_refunded = 1

/obj/machinery/light_construct/small/on_update_icon()
	switch(stage)
		if(1) icon_state = "bulb-construct-stage1"
		if(2) icon_state = "bulb-construct-stage2"
		if(3) icon_state = "bulb-empty"

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1

	layer = ABOVE_HUMAN_LAYER // They were appearing under mobs which is a little weird - Ostaf
	use_power = POWER_USE_OFF // It resets during initialization anyway, but using other options may cause some initially-unpowered areas to act silly.
	idle_power_usage = 2 WATTS
	active_power_usage = 20 WATTS
	power_channel = STATIC_LIGHT //Lights are calc'd via area so they dont need to be in the machine list

	var/on = 0					// 1 if on, 0 if off
	var/flickering = 0
	var/light_type = /obj/item/light/tube		// the type of light item
	var/construct_type = /obj/machinery/light_construct
	var/pixel_shift = 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread

	var/obj/item/light/lightbulb

	var/current_mode = null

	var/static/list/light_eas = list()

/obj/machinery/light/vox
	name = "alien light"
	icon_state = "voxlight"
	base_state = "voxlight"
	desc = "A strange lighting fixture."
	light_type = /obj/item/light/tube

/obj/machinery/light/spot
	name = "spotlight"
	desc = "A more robust socket for light tubes that demands more power."
	light_type = /obj/item/light/tube/large

/obj/machinery/light/he
	name = "high efficiency light fixture"
	icon_state = "hetube1"
	base_state = "hetube"
	desc = "An efficient lighting fixture used to reduce strain on the station's power grid."
	light_type = /obj/item/light/tube/he

/obj/machinery/light/quartz
	name = "quartz light fixture"
	icon_state = "qtube1"
	base_state = "qtube"
	desc = "Light is almost the same as sunlight."
	light_type = /obj/item/light/tube/quartz

// the smaller bulb light fixture
/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb
	construct_type = /obj/machinery/light_construct/small
	pixel_shift = 3

/obj/machinery/light/small/he
	name = "high efficiency light fixture"
	icon_state = "hebulb1"
	base_state = "hebulb"
	desc = "An efficient small lighting fixture used to reduce strain on the station's power grid."
	light_type = /obj/item/light/bulb/he

/obj/machinery/light/small/quartz
	name = "quartz light fixture"
	icon_state = "qbulb1"
	base_state = "qbulb"
	desc = "Light is almost the same as sunlight."
	light_type = /obj/item/light/bulb/quartz

/obj/machinery/light/small/emergency
	light_type = /obj/item/light/bulb/red

/obj/machinery/light/small/red
	light_type = /obj/item/light/bulb/red

/obj/machinery/light/small/hl
	name = "old light fixture"
	icon_state = "hanginglantern1"
	base_state = "hanginglantern"
	desc = "Combination of old technologies and electricity."
	light_type = /obj/item/light/bulb/old

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload, obj/machinery/light_construct/construct = null)
	. = ..(mapload)

	s.set_up(1, 1, src)

	if(construct)
		construct_type = construct.type
		construct.transfer_fingerprints_to(src)
		set_dir(construct.dir)
	else
		lightbulb = new light_type(src)
		if(prob(lightbulb.broken_chance))
			broken(1)

	on = powered()
	update_icon()

/obj/machinery/light/Destroy()
	QDEL_NULL(lightbulb)
	QDEL_NULL(s)
	. = ..()

/obj/machinery/light/on_update_icon(trigger = 1)
	ClearOverlays()
	if(pixel_shift)
		switch(dir)
			if(NORTH)
				pixel_y = pixel_shift
			if(SOUTH)
				pixel_y = -pixel_shift
			if(EAST)
				pixel_x = pixel_shift
			if(WEST)
				pixel_x = -pixel_shift

	switch(get_status())		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = 0
			update_use_power(POWER_USE_OFF)
			set_light(0)
			return
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = 0

	var/image/TO
	var/TO_alpha = between(128, (lightbulb.b_max_bright * 1.25 * 255), 255)
	var/TO_color = lightbulb.b_color

	if(on)
		update_use_power(POWER_USE_ACTIVE)

		var/changed = 0
		if(current_mode && (current_mode in lightbulb.lighting_modes))
			changed = set_light(arglist(lightbulb.lighting_modes[current_mode]))
			if(lightbulb?.tone_overlay)
				TO_color = lightbulb.lighting_modes[current_mode]["l_color"]
				TO_alpha = between(128, (lightbulb.lighting_modes[current_mode]["l_max_bright"] * 1.5 * 255), 255) // Some fine tuning here
		else
			changed = set_light(lightbulb.b_max_bright, lightbulb.b_inner_range, lightbulb.b_outer_range, lightbulb.b_curve, lightbulb.b_color)

		if(lightbulb?.tone_overlay)
			TO = image_repository.overlay_image(icon, "[icon_state]-over", TO_alpha, RESET_COLOR, TO_color, dir, EFFECTS_ABOVE_LIGHTING_PLANE, ABOVE_LIGHTING_LAYER)

		if(trigger && changed && get_status() == LIGHT_OK)
			switch_check()

		if(on)
			if(!light_eas[icon_state])
				light_eas[icon_state] = emissive_appearance(icon, "[icon_state]_ea")
			AddOverlays(light_eas[icon_state])
	else
		if(lightbulb?.tone_overlay)
			TO = image_repository.overlay_image(icon, "[icon_state]-over", TO_alpha, RESET_COLOR, TO_color, dir)
		update_use_power(POWER_USE_OFF)
		set_light(0)

	if(TO)
		AddOverlays(TO)

	change_power_consumption((light_outer_range * light_max_bright) * LIGHTING_POWER_FACTOR, POWER_USE_ACTIVE)

/obj/machinery/light/proc/get_status()
	if(QDELETED(lightbulb))
		return LIGHT_EMPTY
	else
		return lightbulb.status

/obj/machinery/light/proc/switch_check()
	lightbulb.switch_on()
	if(get_status() != LIGHT_OK)
		set_light(0)

/obj/machinery/light/attack_generic(mob/user, damage)
	if(!damage)
		return
	var/status = get_status()
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		to_chat(user, "That object is useless to you.")
		return
	if(!(status == LIGHT_OK || status == LIGHT_BURNED))
		return
	visible_message("<span class='danger'>[user] smashes the light!</span>")
	attack_animation(user)
	broken()
	return 1

/obj/machinery/light/bullet_act(obj/item/projectile/P)
	var/status = get_status()
	if(!(status == LIGHT_OK || status == LIGHT_BURNED))
		return
	if(P.nodamage || (P.damage_type != BRUTE))
		return
	visible_message("<span class='danger'>[P] hits \the [src]!</span>")
	broken()
	..()

/obj/machinery/light/proc/set_mode(new_mode)
	if(current_mode == new_mode || !lightbulb)
		return

	if(new_mode in lightbulb.lighting_modes)
		current_mode = new_mode

	else if(new_mode == null)
		current_mode = null

	update_icon(0)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(state)
	on = (state && get_status() == LIGHT_OK)
	queue_icon_update()

// examine verb
/obj/machinery/light/_examine_text(mob/user)
	. = ..()
	var/fitting = get_fitting_name()
	switch(get_status())
		if(LIGHT_OK)
			. += "\nIt is turned [on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "\nThe [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "\nThe [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "\nThe [fitting] has been smashed."

/obj/machinery/light/proc/get_fitting_name()
	var/obj/item/light/L = light_type
	return initial(L.name)

// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/proc/insert_bulb(obj/item/light/L)
	L.forceMove(src)
	lightbulb = L

	var/area/A = get_area(src)
	if(A && (A.lighting_mode in lightbulb.lighting_modes))
		current_mode = A.lighting_mode

	on = powered()
	update_icon()

/obj/machinery/light/proc/remove_bulb()
	. = lightbulb
	lightbulb.dropInto(loc)
	lightbulb.update_icon()
	lightbulb = null
	current_mode = null
	update_icon()

/obj/machinery/light/attackby(obj/item/W, mob/user)

	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		if(isliving(user))
			var/mob/living/U = user
			LR.ReplaceLight(src, U)
			return

	// attempt to insert light
	if(istype(W, /obj/item/light))
		if(lightbulb)
			to_chat(user, "There is a [get_fitting_name()] already inserted.")
			return
		if(!istype(W, light_type))
			to_chat(user, "This type of light requires a [get_fitting_name()].")
			return
		if(!user.drop(W))
			return

		to_chat(user, "You insert [W].")
		insert_bulb(W)
		add_fingerprint(user)

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(lightbulb && (lightbulb.status != LIGHT_BROKEN))

		if(prob(1 + W.force * 5))

			user.visible_message("<span class='warning'>[user.name] smashed the light!</span>", "<span class='warning'>You smash the light!</span>", "You hear a tinkle of breaking glass")
			if(on && (W.obj_flags & OBJ_FLAG_CONDUCTIBLE))
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			to_chat(user, "You hit the light!")
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)

	// attempt to remove the lightbulb out of the fixture with a crowbar
	else if(isCrowbar(W) && lightbulb)
		if(powered() && (W.obj_flags & OBJ_FLAG_CONDUCTIBLE))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(ishuman(user) && prob(75))
				var/mob/living/carbon/human/H = user
				var/wrong_choice = TRUE
				if(H.species.siemens_coefficient <= 0)
					wrong_choice = FALSE
				else if(H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(G.siemens_coefficient == 0)
						wrong_choice = FALSE
				if(wrong_choice)
					user.visible_message(SPAN("warning", "[user] tries to pry [lightbulb] out of [src] with [W], only to get shocked."))
					user.drop_active_hand()
					electrocute_mob(user, get_area(src), src, rand(0.7, 1.0))
					return
		user.visible_message(SPAN("notice", "[user] pries [lightbulb] out of [src] with [W]."))
		remove_bulb()
		return

	// attempt to stick weapon into light socket
	else if(!lightbulb)
		if(isScrewdriver(W)) //If it's a screwdriver open it.
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user.visible_message("[user.name] opens [src]'s casing.", "You open [src]'s casing.", "You hear a noise.")
			new construct_type(src.loc, src.dir, src)
			qdel(src)
			return

		to_chat(user, "You stick \the [W] into the light socket!")
		if(powered() && (W.obj_flags & OBJ_FLAG_CONDUCTIBLE))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7,1.0))


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/powered()
	var/area/A = get_area(src)
	return A && A.lightswitch && ..(power_channel)

/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	if(flickering) return
	flickering = 1
	spawn(0)
		if(on && get_status() == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(get_status() != LIGHT_OK) break
				on = !on
				update_icon(0)
				sleep(rand(5, 15))
			on = (get_status() == LIGHT_OK)
			update_icon(0)
		flickering = 0

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	src.flicker(1)

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player
/obj/machinery/light/attack_hand(mob/user)

	add_fingerprint(user)

	if(!lightbulb)
		to_chat(user, "There is no [get_fitting_name()] in this light.")
		return

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			if(get_status() == LIGHT_BROKEN)
				return
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			user.do_attack_animation(src)
			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
			visible_message(SPAN("warning", "[user.name] smashes the light!"))
			broken()
			return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			if(H.getSpeciesOrSynthTemp(HEAT_LEVEL_1) > LIGHT_BULB_TEMPERATURE)
				prot = 1
			else if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					if(G.max_heat_protection_temperature > LIGHT_BULB_TEMPERATURE)
						prot = 1
		else
			prot = 1

		if(prot > 0 || (MUTATION_COLD_RESISTANCE in user.mutations))
			to_chat(user, "You remove the [get_fitting_name()]")
		else if(MUTATION_TK in user.mutations)
			to_chat(user, "You telekinetically remove the [get_fitting_name()].")
		else
			if(user.a_intent == I_HELP)
				to_chat(user, "You try to remove the [get_fitting_name()], but it's too hot and you don't want to burn your hand.")
			else
				to_chat(user, "You try to remove the [get_fitting_name()], but you burn your hand on it!")
				var/obj/item/organ/external/E = H.get_organ(user.hand ? BP_L_HAND : BP_R_HAND)
				if(E)
					E.take_external_damage(0, rand(3, 7), used_weapon = "hot lightbulb")
			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
			return				// if burned, don't remove the light
	else
		to_chat(user, "You remove the [get_fitting_name()].")

	// create a light tube/bulb item and put it in the user's hand
	user.put_in_active_hand(remove_bulb())	//puts it in our active hand


/obj/machinery/light/attack_tk(mob/user)
	if(!lightbulb)
		to_chat(user, "There is no [get_fitting_name()] in this light.")
		return

	to_chat(user, "You telekinetically remove the [get_fitting_name()].")
	remove_bulb()

// ghost attack - make lights flicker like an AI, but even spookier!
/obj/machinery/light/attack_ghost(mob/user)
	if(round_is_spooky())
		src.flicker(rand(2,5))
	else return ..()

// break the light and make sparks if was on
/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0)
	if(!lightbulb)
		return

	if(!skip_sound_and_sparks)
		if(lightbulb && !(lightbulb.status == LIGHT_BROKEN))
			playsound(src.loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
		if(on)
			s.set_up(3, 1, src)
			s.start()
	lightbulb.status = LIGHT_BROKEN
	update_icon()

/obj/machinery/light/proc/fix()
	if(get_status() == LIGHT_OK)
		return
	lightbulb.status = LIGHT_OK
	on = 1
	update_icon()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(75))
				broken()
		if(3)
			if (prob(50))
				broken()

// timed process
// use power

// called when area power state changes
/obj/machinery/light/power_change()
	seton(powered())

// called when on fire

/obj/machinery/light/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

/obj/machinery/light/small/readylight
	light_type = /obj/item/light/bulb/red/readylight
	var/state = 0

/obj/machinery/light/small/readylight/proc/set_state(new_state)
	state = new_state
	if(state)
		set_mode(LIGHTMODE_READY)
	else
		set_mode(null)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = ITEM_SIZE_TINY
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	matter = list(MATERIAL_STEEL = 60)
	var/rigged = 0		// true if rigged to explode
	var/broken_chance = 2

	var/b_max_bright = 0.7
	var/b_inner_range = 1
	var/b_outer_range = 2
	var/b_curve = 2
	var/b_color = "#ffffff"

	var/list/lighting_modes = list()
	var/sound_on
	var/random_tone = FALSE
	var/tone_overlay = TRUE
	var/list/random_tone_options = list(
		"#fffee0",
		"#eafeff",
		"#fefefe",
		"#fef6ea"
	)

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	matter = list(MATERIAL_GLASS = 100)

	b_max_bright = 1.0
	b_outer_range = 7
	b_curve = 3.5
	b_color = "#fffee0"
	lighting_modes = list(
		LIGHTMODE_EMERGENCY  = list(l_max_bright = 0.7,  l_inner_range = 1, l_outer_range = 5, l_falloff_curve = 3.5, l_color = "#da0205"),
		LIGHTMODE_EVACUATION = list(l_max_bright = 1.0, l_inner_range = 1, l_outer_range = 7, l_falloff_curve = 3.5, l_color = "#bf0000"),
		LIGHTMODE_ALARM      = list(l_max_bright = 1.0, l_inner_range = 1, l_outer_range = 7, l_falloff_curve = 3.5, l_color = "#ff3333"),
		LIGHTMODE_RADSTORM   = list(l_max_bright = 0.85, l_inner_range = 1, l_outer_range = 7, l_falloff_curve = 3.5, l_color = "#8A9929")
		)
	sound_on = 'sound/machines/lightson.ogg'
	random_tone = TRUE

/obj/item/light/tube/large
	w_class = ITEM_SIZE_SMALL
	name = "large light tube"
	b_outer_range = 8

/obj/item/light/tube/he
	name = "high efficiency light tube"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "lhetube"
	b_outer_range = 7
	b_max_bright = 0.9
	b_color = "#33cccc"
	matter = list(MATERIAL_STEEL = 60, MATERIAL_GLASS = 300)
	random_tone = FALSE
	tone_overlay = FALSE

/obj/item/light/tube/quartz
	name = "quartz light tube"
	desc = "Light is almost the same as sunlight."
	base_state = "lqtube"
	b_outer_range = 8
	b_max_bright = 1.0
	b_color = "#8A2BE2"
	random_tone = FALSE
	tone_overlay = FALSE

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	broken_chance = 5
	matter = list(MATERIAL_GLASS = 100)

	b_max_bright = 0.85
	b_inner_range = 0.6
	b_outer_range = 4
	b_curve = 4.5
	b_color = "#a0a080"
	lighting_modes = list(
		LIGHTMODE_EMERGENCY  = list(l_max_bright = 0.7, l_inner_range = 0.5,  l_outer_range = 3, l_falloff_curve = 4.5, l_color = "#da0205"),
		LIGHTMODE_EVACUATION = list(l_max_bright = 0.85, l_inner_range = 0.6, l_outer_range = 4, l_falloff_curve = 4.5, l_color = "#bf0000"),
		LIGHTMODE_ALARM      = list(l_max_bright = 0.85, l_inner_range = 0.6, l_outer_range = 4, l_falloff_curve = 4.5, l_color = "#ff3333"),
		LIGHTMODE_RADSTORM   = list(l_max_bright = 0.7, l_inner_range = 0.5,  l_outer_range = 4, l_falloff_curve = 4.5, l_color = "#8A9929")
		)
	random_tone = TRUE

/obj/item/light/bulb/he
	name = "high efficiency light bulb"
	desc = "An efficient light used to reduce strain on the station's power grid."
	base_state = "lhebulb"
	b_max_bright = 0.6
	b_outer_range = 5
	b_color = "#33cccc"
	matter = list(MATERIAL_STEEL = 30, MATERIAL_GLASS = 150)
	random_tone = FALSE
	tone_overlay = FALSE

/obj/item/light/bulb/quartz
	name = "quartz light bulb"
	desc = "Light is almost the same as sunlight."
	base_state = "lqbulb"
	b_max_bright = 0.8
	b_outer_range = 5
	b_color = "#8A2BE2"
	random_tone = FALSE
	tone_overlay = FALSE

/obj/item/light/bulb/old
	name = "old light bulb"
	desc = "Old type of light bulbs, almost not being used at the station."
	base_state = "lold_bulb"
	broken_chance = 1
	b_max_bright = 0.85
	b_outer_range = 6
	b_color = "#ec8b2f"
	random_tone = FALSE
	tone_overlay = FALSE

/obj/item/light/bulb/red
	b_outer_range = 6
	color = "#da0205"
	b_color = "#da0205"
	random_tone = FALSE
	tone_overlay = TRUE

/obj/item/light/bulb/red/readylight
	lighting_modes = list(
		LIGHTMODE_READY = list(l_max_bright = 0.85, l_inner_range = 0.5,  l_outer_range = 4, l_falloff_curve = 4.5, l_color = "#00ff00")
		)

/obj/item/light/throw_impact(atom/hit_atom)
	..()
	shatter()

/obj/item/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	matter = list(MATERIAL_GLASS = 100)
	random_tone = FALSE
	tone_overlay = FALSE


/obj/item/light/Initialize()
	. = ..()
	if(random_tone)
		b_color = pick(random_tone_options)
	update_icon()

/obj/item/light/Destroy()
	if(istype(loc, /obj/machinery/light))
		var/obj/machinery/light/L = loc
		L.lightbulb = null
		L.current_mode = null
		if(!QDELETED(L))
			L.update_icon()
	return ..()

/obj/item/light/_examine_text(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_BURNED)
			. += "\nIt appears to be burnt-out."
		if(LIGHT_BROKEN)
			. += "\nIt's broken."

// update the icon state and description of the light
/obj/item/light/on_update_icon()
	ClearOverlays()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	if(tone_overlay)
		var/image/TO = overlay_image(icon, "[icon_state]-over", flags=RESET_COLOR)
		TO.color = b_color
		AddOverlays(TO)

// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/light/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent(/datum/reagent/toxin/plasma, 5))

			log_admin("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a light with plasma, rigging it to explode.")

			rigged = 1

		S.reagents.clear_reagents()
	else
		..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/light/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != I_HURT)
		return

	shatter()

/obj/item/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		src.visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = 1
		playsound(src.loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
		update_icon()

/obj/item/light/proc/switch_on()
	switchcount++
	if(rigged)
		log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
		message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")
		var/turf/T = get_turf(src.loc)
		spawn(0)
			sleep(2)
			explosion(T, 0, 0, 3, 5)
			sleep(1)
			qdel(src)
		status = LIGHT_BROKEN
	else if(prob(min(60, switchcount*switchcount*0.01)))
		status = LIGHT_BURNED
	else if(sound_on)
		playsound(src, sound_on, 75)
	return status
