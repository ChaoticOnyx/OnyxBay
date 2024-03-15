//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	desc = "It's stringy and sticky."
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 0
	var/health = 15

//similar to weeds, but only barfed out by nurses manually
/obj/structure/spider/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/structure/spider/attackby(obj/item/W, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(W.attack_verb.len)
		visible_message("<span class='warning'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='warning'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	var/damage = W.force / 4.0

	if(isWelder(W))
		var/obj/item/weldingtool/WT = W

		if(WT.use_tool(src, user, amount = 1))
			damage = 15

	health -= damage
	healthcheck()

/obj/structure/spider/bullet_act(obj/item/projectile/Proj)
	..()
	health -= Proj.get_structure_damage()
	healthcheck()

/obj/structure/spider/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/spider/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > (300 CELSIUS))
		health -= 5
		healthcheck()

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"
	///Whether or not the web is a sealed web
	var/sealed = FALSE

/obj/structure/spider/stickyweb/Initialize()
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"

/obj/structure/spider/stickyweb/sealed
	name = "sealed web"
	desc = "A solid thick wall of web, airtight enough to block air flow."
	icon_state = "sealedweb"
	sealed = TRUE
	can_atmos_pass = ATMOS_PASS_NO
	density = TRUE
	opacity = TRUE

/obj/structure/spider/stickyweb/sealed/attack_generic(mob/user, damage, attack_verb, wallbreaker)
    if(istype (user, /mob/living/simple_animal/hostile/giant_spider))
        user.visible_message(SPAN_WARNING("[user] begins to claw through the [src]!"), "You begin to claw through the [src].")
        if(do_after(user, 50, target = src))
            user.visible_message(SPAN_WARNING("[user] ruptures [src] open!"), "You succesfully claw through the [src].")
            health = 0
            healthcheck ()
            return
    return ..()

/obj/structure/spider/stickyweb/CanPass(atom/movable/mover, turf/target)
	if(sealed)
		return FALSE

	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return TRUE

	else if(istype(mover, /mob/living))
		if(istype(mover.pulledby, /mob/living/simple_animal/hostile/giant_spider))
			return TRUE
		if(prob(70))
			to_chat(mover, "<span class='warning'>You get stuck in \the [src] for a moment.</span>")
			return FALSE
		return TRUE

	else if(istype(mover, /obj/item/projectile))
		return prob(30)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "guard"
	anchored = 0
	layer = BELOW_OBJ_LAYER
	health = 3
	var/mob/living/simple_animal/hostile/giant_spider/greater_form
	var/last_itch = 0
	var/amount_grown = -1
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/dormant = FALSE    // If dormant, does not add the spiderling to the process list unless it's also growing
	var/growth_chance = 50 // % chance of beginning growth, and eventually become a beautiful death machine

	var/directive = "" //Message from the mother
	var/faction = "spiders"

	var/shift_range = 6

/obj/structure/spider/spiderling/Initialize(mapload, atom/parent)
	. = ..()
	pixel_x = rand(-shift_range, shift_range)
	pixel_y = rand(-shift_range, shift_range)

	if(prob(growth_chance))
		amount_grown = 1
		dormant = FALSE

	if(dormant)
		register_signal(src, SIGNAL_MOVED, nameof(.proc/disturbed))
	else
		set_next_think(world.time)

	get_light_and_color(parent)

/obj/structure/spider/spiderling/hunter
	greater_form = /mob/living/simple_animal/hostile/giant_spider/hunter
	icon_state = "hunter"

/obj/structure/spider/spiderling/nurse
	greater_form = /mob/living/simple_animal/hostile/giant_spider/nurse
	icon_state = "nurse"

/obj/structure/spider/spiderling/midwife
	greater_form = /mob/living/simple_animal/hostile/giant_spider/midwife
	icon_state = "hunter"

/obj/structure/spider/spiderling/viper
	greater_form = /mob/living/simple_animal/hostile/giant_spider/viper
	icon_state = "hunter"

/obj/structure/spider/spiderling/tarantula
	greater_form = /mob/living/simple_animal/hostile/giant_spider/tarantula

/obj/structure/spider/spiderling/mundane
	growth_chance = 0 // Just a simple, non-mutant spider
	greater_form = /mob/living/simple_animal/hostile/giant_spider

/obj/structure/spider/spiderling/mundane/dormant
	dormant = TRUE    // It lies in wait, hoping you will walk face first into its web

/obj/structure/spider/spiderling/Destroy()
	if(dormant)
		unregister_signal(src, SIGNAL_MOVED)
	. = ..()

/obj/structure/spider/spiderling/attackby(obj/item/W, mob/user)
	..()
	if(health > 0)
		disturbed()

/obj/structure/spider/spiderling/Crossed(mob/living/L)
	if(dormant && istype(L) && L.mob_size > MOB_TINY)
		disturbed()

/obj/structure/spider/spiderling/proc/disturbed()
	if(!dormant)
		return
	dormant = FALSE

	unregister_signal(src, SIGNAL_MOVED)
	set_next_think(world.time)

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		forceMove(user.loc)
	else
		..()

/obj/structure/spider/spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(loc)
	qdel(src)

/obj/structure/spider/spiderling/healthcheck()
	if(health <= 0)
		die()

/obj/structure/spider/spiderling/think()
	if(travelling_in_vent)
		if(istype(src.loc, /turf))
			travelling_in_vent = 0
			entry_vent = null

	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			if(entry_vent.network && entry_vent.network.normal_members.len)
				var/list/vents = list()
				for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
					vents.Add(temp_vent)
				if(!vents.len)
					entry_vent = null

					set_next_think(world.time + 1 SECOND)
					return
				var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
				/*if(prob(50))
					src.visible_message("<B>[src] scrambles into the ventillation ducts!</B>")*/

				spawn(rand(20,60))
					forceMove(exit_vent)
					var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
					spawn(travel_time)

						if(!exit_vent || exit_vent.welded)
							forceMove(entry_vent)
							entry_vent = null
							set_next_think(world.time + 1 SECOND)
							return

						if(prob(50))
							var/msg = SPAN("notice", "You hear something squeezing through the ventilation ducts.")
							visible_message(msg, msg)
						sleep(travel_time)

						if(!exit_vent || exit_vent.welded)
							forceMove(entry_vent)
							entry_vent = null
							set_next_think(world.time + 1 SECOND)
							return
						forceMove(exit_vent.loc)
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
			else
				entry_vent = null
	//=================

	else if(prob(33))
		var/list/nearby = oview(10, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom, 5)
			if(prob(40))
				src.visible_message(SPAN_NOTICE("\The [src] skitters[pick(" away"," around","")]."))

	else if(prob(10))
		//vent crawl!
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 5)
				break

	if(isturf(loc))
		if(amount_grown >= 100)
			if(!greater_form)
				if(prob(3))
					greater_form = pick(/mob/living/simple_animal/hostile/giant_spider/tarantula, /mob/living/simple_animal/hostile/giant_spider/viper, /mob/living/simple_animal/hostile/giant_spider/midwife)
				else
					greater_form = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/giant_spider/S = new greater_form(src.loc)
			notify_ghosts("[capitalize(S.name)] is now available to possess!", source = S, action = NOTIFY_POSSES, posses_mob = TRUE)

			S.faction = faction
			S.directive = directive

			qdel(src)
			return

	else if(isorgan(loc))
		if(!amount_grown) amount_grown = 1
		var/obj/item/organ/external/O = loc
		if(!O.owner || O.owner.is_ic_dead() || amount_grown > 80)
			amount_grown = 20 //reset amount_grown so that people have some time to react to spiderlings before they grow big
			O.implants -= src
			forceMove(O.owner ? O.owner.loc : O.loc)
			visible_message("<span class='warning'>\A [src] emerges from inside [O.owner ? "[O.owner]'s [O.name]" : "\the [O]"]!</span>")
			if(O.owner)
				O.owner.apply_damage(1, BRUTE, O.organ_tag)
		else if(prob(1))
			O.owner.apply_damage(1, TOX, O.organ_tag)
			if(world.time > last_itch + 30 SECONDS)
				last_itch = world.time
				to_chat(O.owner, "<span class='notice'>Your [O.name] itches...</span>")
	else if(prob(1))
		src.visible_message("<span class='notice'>\The [src] skitters.</span>")

	if(amount_grown > 0)
		amount_grown += rand(0,2)

	set_next_think(world.time + 1 SECOND)

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"
	anchored = 1
	layer = BLOOD_LAYER

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	health = 60

/obj/structure/spider/cocoon/Initialize()
	. = ..()
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")

/obj/structure/spider/cocoon/proc/mob_breakout(mob/living/user)// For God's sake, don't make it a closet
	var/breakout_time = 600
	user.last_special = world.time + 100
	to_chat(user, SPAN_NOTICE("You struggle against the tight bonds... (This will take about [time2text(breakout_time)].)"))
	visible_message(SPAN_NOTICE("You see something struggling and writhing in \the [src]!"))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message(SPAN_WARNING("\The [src] splits open."))
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
