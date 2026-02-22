/obj/machinery/power/dynamo
	var/power_produced = 10000
	var/raw_power = 0
	invisibility = 70

/obj/machinery/power/dynamo/Process()
	if(raw_power > 0)
		if(raw_power > 10)
			raw_power -= 3
			add_avail(power_produced * 2)
		else
			raw_power --
			add_avail(power_produced)
	return

/obj/machinery/power/dynamo/proc/Rotated()
	raw_power += 2

/obj/structure/bed/chair/pedalgen
	name = "Pedal Generator"
	desc = "This machine generates power from raw human force."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pedalgenerator"
	anchored = 1
	density = 0
	var/obj/machinery/power/dynamo/generator = null
	var/pedaled = 0
	movement_handlers = list(/datum/movement_handler/move_relay_self)
	buckle_relaymove = TRUE
	foldable = FALSE

/obj/structure/bed/chair/pedalgen/Initialize()
	. = ..()
	generator = new /obj/machinery/power/dynamo(src)
	if(anchored)
		generator.forceMove(loc)
		generator.connect_to_network()

/obj/structure/bed/chair/pedalgen/examine(mob/user, infix)
	. = ..()

	if(generator.raw_power > 0)
		. += "It has [generator.raw_power] raw power stored, it generates [generator.raw_power > 10 ? "20" : "10" ]kW!"
	else
		. += "Generator stands still. Someone need to pedal that thing."

/obj/structure/bed/chair/pedalgen/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		if(anchored)
			user.visible_message(SPAN("notice", "[user] is unsecuring \the [src]..."), \
					   	         SPAN("notice", "Now unsecuring \the [src]..."))
		else
			user.visible_message(SPAN("notice", "[user] is securing \the [src]..."), \
					   	         SPAN("notice", "Now securing \the [src]..."))
		if(!do_after(user, 10, src))
			return
		anchored = !anchored
		if(anchored)
			user.visible_message(SPAN("notice", "[user] secured \the [src]!"), \
								 SPAN("notice", "You secured \the [src]!"))
			generator.forceMove(loc)
			generator.connect_to_network()
		else
			user.visible_message(SPAN("notice", "[user] unsecured \the [src]!"), \
								 SPAN("notice", "You unsecured \the [src]!"))
			generator.disconnect_from_network()
			generator.forceMove(null)

/obj/structure/bed/chair/pedalgen/attack_hand(mob/user)
	if(buckled_mob && buckled_mob == user)
		if(!pedaled)
			pedal(user)
	else
		return ..()

/obj/structure/bed/chair/pedalgen/proc/pedal(mob/user)
	pedaled = 1
	if(!istype(buckled_mob, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/pedaler = buckled_mob
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if(pedaler.nutrition > 10 && pedaler.hydration > 0)
		playsound(src.loc, 'sound/effects/pedalgen.ogg', 20, 1)
		visible_message(SPAN("notice", "[pedaler] pedals \the [src]!"))
		generator.Rotated()
		pedaler.remove_nutrition(2.5)
		pedaler.remove_hydration(0.5)
		pedaler.adjustHalLoss(1)
		if(pedaler.getHalLoss() > 80)
			to_chat(user, "You pushed yourself too hard.")
			pedaler.adjustHalLoss(20)
			unbuckle_mob()
		sleep(10)
		pedaled = 0
	else
		to_chat(user, "You are too exausted to pedal that thing.")
		pedaled = 0
	return 1

/obj/structure/bed/chair/pedalgen/relaymove(mob/user, direction)
	if(!ishuman(user))
		unbuckle_mob()
	var/mob/living/carbon/human/pedaler = user
	if(istype(pedaler) && !pedaler.handcuffed)
		unbuckle_mob()
	else
		if(!pedaled)
			pedal(user)

/obj/structure/bed/chair/pedalgen/Move(newloc, direct)
	. = ..()
	if(!.)
		return

	if(buckled_mob?.buckled == src)
		buckled_mob.forceMove(loc)
		update_mob(buckled_mob)

/obj/structure/bed/chair/pedalgen/post_buckle_mob(mob/user)
	update_mob(user, 1)

/obj/structure/bed/chair/pedalgen/rotate()
	..()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		update_mob(buckled_mob)

/obj/structure/bed/chair/pedalgen/rotate_counter()
	..()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		update_mob(buckled_mob)

/obj/structure/bed/chair/pedalgen/on_update_icon()
	return

/obj/structure/bed/chair/pedalgen/proc/update_mob(mob/M, buckling = 0)
	if(M == buckled_mob)
		M.dir = dir
		var/new_pixel_x = 0
		var/new_pixel_y = 0
		switch(dir)
			if(SOUTH)
				new_pixel_x = 0
				new_pixel_y = 7
			if(WEST)
				new_pixel_x = 13
				new_pixel_y = 7
			if(NORTH)
				new_pixel_x = 0
				new_pixel_y = 4
			if(EAST)
				new_pixel_x = -13
				new_pixel_y = 7
		if(buckling)
			animate(M, pixel_x = new_pixel_x, pixel_y = new_pixel_y, 2, 1, LINEAR_EASING, flags = ANIMATION_PARALLEL)
		else
			M.pixel_x = new_pixel_x
			M.pixel_y = new_pixel_y
	else
		animate(M, pixel_x = 0, pixel_y = 0, 2, 1, LINEAR_EASING, flags = ANIMATION_PARALLEL)

/obj/structure/bed/chair/pedalgen/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message(SPAN("warning", "[Proj] ricochets off the [src]!"))

/obj/structure/bed/chair/pedalgen/Destroy()
	qdel(generator)
	return ..()

/obj/structure/bed/chair/pedalgen/verb/release()
	set name = "Release Pedalgen"
	set category = "Object"
	set src in view(0)

	if(usr.restrained())
		to_chat(usr, "You are restrained!")
		return

	unbuckle_mob()
