//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays")
	emote_see = list("shakes its head", "stamps a foot", "glares around")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/goat
	meat_amount = 4
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = "goat"
	attacktext = "kicked"
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 5
	var/datum/reagents/udder = null

/mob/living/simple_animal/hostile/retaliate/goat/New()
	udder = new(50, src)
	..()

/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	QDEL_NULL(udder)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			enemies = list()
			LoseTarget()
			src.visible_message("<span class='notice'>\The [src] calms down.</span>")

		if(stat == CONSCIOUS)
			if(udder && prob(5))
				udder.add_reagent(/datum/reagent/drink/milk, rand(5, 10))

		if(locate(/obj/effect/vine) in loc)
			var/obj/effect/vine/SV = locate() in loc
			if(prob(60))
				src.visible_message("<span class='notice'>\The [src] eats the plants.</span>")
				SV.die_off(1)
				if(locate(/obj/machinery/portable_atmospherics/hydroponics/soil/invisible) in loc)
					var/obj/machinery/portable_atmospherics/hydroponics/soil/invisible/SP = locate() in loc
					qdel(SP)
			else if(prob(20))
				src.visible_message("<span class='notice'>\The [src] chews on the plants.</span>")
			return

		if(!pulledby)
			var/obj/effect/vine/food
			food = locate(/obj/effect/vine) in oview(5,loc)
			if(food)
				var/step = get_step_to(src, food, 0)
				Move(step)

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	if(stat == CONSCIOUS && prob(50))
		visible_message("<span class='warning'>\The [src] gets an evil-looking gleam in their eye.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/attackby(obj/item/O, mob/user)
	var/obj/item/weapon/reagent_containers/glass/G = O
	if(stat == CONSCIOUS && istype(G) && G.is_open_container())
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/transfered = udder.trans_type_to(G, /datum/reagent/drink/milk, rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>\The [O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays")
	emote_see = list("shakes its head")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/beef
	meat_amount = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicked"
	health = 50
	var/milktype = /datum/reagent/drink/milk
	var/datum/reagents/udder = null

/mob/living/simple_animal/cow/Initialize()
	. = ..()
	udder = milktype
	udder = new(50, src)

/mob/living/simple_animal/cow/attackby(obj/item/O, mob/user)
	var/obj/item/weapon/reagent_containers/glass/G = O
	if(stat == CONSCIOUS && istype(G) && G.is_open_container())
		user.visible_message("<span class='notice'>[user] milks [src] using \the [O].</span>")
		var/transfered = udder.trans_type_to(G, milktype, rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>\The [O] is full.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'>The udder is dry. Wait a bit longer...</span>")
	else
		..()

/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS)
		if(udder && prob(5))
			udder.add_reagent(milktype, rand(5, 10))

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M)
	if(!stat && M.a_intent == I_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>","<span class='notice'>You tip over [src].</span>")
		Weaken(30)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	"[src] looks at you imploringly.",
											"[src] looks at you pleadingly",
											"[src] looks at you with a resigned expression.",
											"[src] seems resigned to its fate.")
				to_chat(M, pick(responses))
	else
		..()

/mob/living/simple_animal/cow/cowcownut
	name = "cowcownut"
	desc = "Looks like a physical embodiment of terrible puns."
	icon_state = "cowcownut"
	icon_living = "cowcownut"
	icon_dead = "cowcownut_dead"
	emote_see = list("shakes its nuts")
	health = 100
	faction = "floral"

	milktype = /datum/reagent/drink/juice/coconut

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps")
	emote_see = list("pecks at the ground","flaps its tiny wings")
	speak_chance = 2
	turns_per_move = 2
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/chicken
	meat_amount = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicked"
	maxHealth = 3
	health = 3
	var/amount_grown = 0
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE
	mob_size = MOB_MINISCULE

/mob/living/simple_animal/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat)
		amount_grown++
		if(amount_grown >= 180)
			amount_grown = -1
			new /mob/living/simple_animal/chicken(loc)
			qdel(src)

var/const/MAX_CHICKENS = 50
var/global/chicken_count = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	icon_state = "chicken"
	icon_living = "chicken"
	icon_dead = "chicken_dead"
	item_state = "chicken"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks")
	emote_see = list("pecks at the ground","flaps its wings viciously")
	speak_chance = 2
	turns_per_move = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/chicken
	meat_amount = 2
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicked"
	maxHealth = 10
	health = 10
	var/eggsleft = 0
	var/body_color
	var/egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	var/mutable = TRUE
	var/egg_chance
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_SMALL
	holder_type = /obj/item/weapon/holder/chicken

/mob/living/simple_animal/chicken/New()
	..()
	if(!body_color)
		body_color = pick( list("brown","black","white") )
	icon_state = "chicken_[body_color]"
	icon_living = "chicken_[body_color]"
	icon_dead = "chicken_[body_color]_dead"
	item_state = "chicken_[body_color]"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	chicken_count++

/mob/living/simple_animal/chicken/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	chicken_count--

/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown)) //feedin' dem chickens
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
		if(G.seed && G.seed.kitchen_tag in list("wheat", "rice", "grass"))
			if(!stat && eggsleft < 8)
				user.visible_message(SPAN("notice", "[user] feeds [O] to [name]! It clucks happily."), SPAN("notice", "You feed [O] to [name]! It clucks happily."))
				if(mutable && G.reagents.has_reagent(/datum/reagent/nanites))
					Robotize()
				user.drop_item()
				QDEL_NULL(O)
				eggsleft += rand(1, 3)
			else
				to_chat(user, SPAN("notice", "[name] doesn't seem hungry!"))
		else
			to_chat(user, "[name] doesn't seem interested in that.")
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if(eggsleft)
		egg_chance++
		if(!stat && prob(Floor(egg_chance/10)))
			visible_message("<b>[name]</b> [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
			eggsleft--
			egg_chance = 0
			var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new egg_type(get_turf(src))
			E.pixel_x = rand(-6, 6)
			E.pixel_y = rand(-6, 6)
			if(chicken_count < MAX_CHICKENS)
				START_PROCESSING(SSobj, E)
	else
		egg_chance = 0

/mob/living/simple_animal/chicken/proc/Robotize()
	if(stat)
		return
	if(!mutable)
		return
	visible_message("<b>[name]</b> flaps its wings as some twisted metal grows through its body!")

	name = "\improper robot chicken"
	desc = "Does it like to watch sketches?"
	icon_state = "chicken_robot"
	icon_living = "chicken_robot"
	icon_dead = "chicken_robot_dead"
	item_state = "chicken_robot"
	body_color = "robot"
	maxHealth = 20
	health = 20
	mutable = FALSE

/mob/living/simple_animal/chicken/robot
	name = "\improper robot chicken"
	icon_state = "chicken_robot"
	body_color = "robot"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	mutable = FALSE

/mob/living/simple_animal/chicken/robot/New()
	..()
	Robotize()


/obj/item/weapon/reagent_containers/food/snacks/egg
	var/amount_grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/Destroy()
	if(amount_grown)
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/Process()
	if(isturf(loc))
		amount_grown++
		if(amount_grown >= 300)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		return PROCESS_KILL
