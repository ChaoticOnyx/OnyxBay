
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes."
	icon = 'icons/mob/hostile/spider.dmi'
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/xenomeat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	stop_automated_movement_when_pulled = 0
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin
	faction = "spiders"
	var/busy = 0
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 6
	speed = 3
	controllable = TRUE

/mob/living/simple_animal/hostile/giant_spider/alt
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes. This one looks different from the others."
	icon_state = "guard_alt"
	icon_living = "guard_alt"
	icon_dead = "guard_alt_dead"

/mob/living/simple_animal/hostile/giant_spider/alt/strong
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes. His big jaws hint to you that he's a lot more dangerous than the others"
	icon_state = "tarantula_alt"
	icon_living = "tarantula_alt"
	icon_dead = "tarantula_alt_dead"
	maxHealth = 300
	health = 300
	melee_damage_lower = 25
	melee_damage_upper = 40

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and beige, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 8
	var/atom/cocoon_target
	poison_type = /datum/reagent/soporific
	var/fed = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/alt
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes. This one looks different from the others."
	icon_state = "nurse_alt"
	icon_living = "nurse_alt"
	icon_dead = "nurse_alt_dead"

/mob/living/simple_animal/hostile/giant_spider/nurse/alt/strong
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes. The purple stripes hint to you that he is far more dangerous than the others."
	icon_state = "midwife_alt"
	icon_living = "midwife_alt"
	icon_dead = "midwife_alt_dead"
	maxHealth = 80
	health = 80
	melee_damage_lower = 10
	melee_damage_upper = 15
	poison_per_bite = 12

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 10
	move_to_delay = 4

/mob/living/simple_animal/hostile/giant_spider/hunter/alt
	desc = "Furry and dark purple, it makes you shudder to look at it. This one has sparkling purple eyes. This one looks different from the others."
	icon_state = "hunter_alt"
	icon_living = "hunter_alt"
	icon_dead = "hunter_alt_dead"

/mob/living/simple_animal/hostile/giant_spider/hunter/alt/strong
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes. His huge red sign hints to you that he is far more dangerous than the others"
	icon_state = "viper_alt"
	icon_living = "viper_alt"
	icon_dead = "viper_alt_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 25
	poison_per_bite = 20
	move_to_delay = 3

/mob/living/simple_animal/hostile/giant_spider/New(location, atom/parent)
	get_light_and_color(parent)
	..()

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
	. = ..()
	if(isliving(.))
		var/mob/living/L = .
		if(L.reagents)
			L.reagents.add_reagent(/datum/reagent/toxin, poison_per_bite)
			if(prob(poison_per_bite))
				to_chat(L, "<span class='warning'>You feel a tiny prick.</span>")
				L.reagents.add_reagent(poison_type, 5)

/mob/living/simple_animal/hostile/giant_spider/nurse/AttackingTarget()
	. = ..()
	if(ishuman(.))
		var/mob/living/carbon/human/H = .
		if(prob(poison_per_bite))
			var/obj/item/organ/external/O = pick(H.organs)
			if(!BP_IS_ROBOTIC(O))
				var/eggs = new /obj/effect/spider/eggcluster(O, src)
				O.implants += eggs

/mob/living/simple_animal/hostile/giant_spider/Life()
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			//1% chance to skitter madly away
			if(!busy && prob(1))
				/*var/list/move_targets = list()
				for(var/turf/T in orange(20, src))
					move_targets.Add(T)*/
				stop_automated_movement = 1
				walk_to(src, pick(orange(20, src)), 1, move_to_delay)
				spawn(50)
					stop_automated_movement = 0
					walk(src,0)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	..()
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat)
						cocoon_target = C
						busy = MOVING_TO_TARGET
						walk_to(src, C, 1, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return

				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					busy = SPINNING_WEB
					src.visible_message("<span class='notice'>\The [src] begins to secrete a sticky substance.</span>")
					stop_automated_movement = 1
					spawn(40)
						if(busy == SPINNING_WEB)
							new /obj/effect/spider/stickyweb(src.loc)
							busy = 0
							stop_automated_movement = 0
				else
					//third, lay an egg cluster there
					var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
					if(!E && fed > 0)
						busy = LAYING_EGGS
						src.visible_message("<span class='notice'>\The [src] begins to lay a cluster of eggs.</span>")
						stop_automated_movement = 1
						spawn(50)
							if(busy == LAYING_EGGS)
								E = locate() in get_turf(src)
								if(!E)
									new /obj/effect/spider/eggcluster(loc, src)
									fed--
								busy = 0
								stop_automated_movement = 0
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)

							if(O.anchored)
								continue

							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
								cocoon_target = O
								busy = MOVING_TO_TARGET
								stop_automated_movement = 1
								walk_to(src, O, 1, move_to_delay)
								//give up if we can't reach them after 10 seconds
								GiveUp(O)

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					busy = SPINNING_COCOON
					src.visible_message("<span class='notice'>\The [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
					stop_automated_movement = 1
					walk(src,0)
					addtimer(CALLBACK(src, .proc/finalize_cocoon), 50, TIMER_UNIQUE)

		else
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/giant_spider/nurse/proc/finalize_cocoon()
	if(busy == SPINNING_COCOON)
		if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
			var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
			var/large_cocoon = 0
			C.pixel_x = cocoon_target.pixel_x
			C.pixel_y = cocoon_target.pixel_y
			for (var/A in C.loc)
				var/atom/movable/aa = A
				if (ismob(aa))
					var/mob/M = aa
					if(istype(M, /mob/living/simple_animal/hostile/giant_spider) && M.stat != DEAD)
						continue
					large_cocoon = 1
					fed++
					src.visible_message("<span class='warning'>\The [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
					M.forceMove(C)
					C.pixel_x = M.pixel_x
					C.pixel_y = M.pixel_y
					break
				if (istype(aa, /obj/item))
					var/obj/item/I = aa
					I.forceMove(C)
				if (istype(aa, /obj/structure))
					var/obj/structure/S = aa
					if(!S.anchored)
						S.forceMove(C)
						large_cocoon = 1
				if (istype(aa, /obj/machinery))
					var/obj/machinery/M = aa
					if(!M.anchored)
						M.forceMove(C)
						large_cocoon = 1
			if(large_cocoon)
				C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		busy = 0
		stop_automated_movement = 0

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
