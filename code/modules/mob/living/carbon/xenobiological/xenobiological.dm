#define METROID_EXTRACT_CROSSING_REQUIRED 10

/mob/living/carbon/metroid
	name = "baby metroid"
	icon = 'icons/mob/metroids.dmi'
	icon_state = "green baby metroid"
	pass_flags = PASS_FLAG_TABLE
	speak_emote = list("chirps")
	bubble_icon = "metroid"

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 800

	see_in_dark = 8
	update_metroids = 0

	// canstun and canweaken don't affect metroids because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/toxloss = 0
	var/is_adult = 0
	var/number = 0 // Used to understand when someone is talking to it
	var/cores = 1 // the number of /obj/item/metroid_extract's the metroid has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 0-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the metroid has been overfed, if 10, grows or reproduces

	var/mob/living/Victim = null // the person the metroid is currently feeding on
	var/mob/living/Target = null // AI variable - tells the metroid to hunt this down
	var/mob/living/Leader = null // AI variable - tells the metroid to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the metroid will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face

	var/AIproc = 0 // If it's 0, we need to launch an AI proc

	var/hurt_temperature = -50 CELSIUS // metroid keeps taking damage when its bodytemperature is below this
	var/die_temperature = 50 // metroid dies instantly when its bodytemperature is below this

	var/colour = "green"

	var/core_removal_stage = 0 //For removing cores.

	//CORES CROSSBREEDING
	var/effectmod //What core modification is being used.
	var/applied_cores = 0 //How many extracts of the modtype have been applied.

/mob/living/carbon/metroid/getToxLoss()
	return toxloss

/mob/living/carbon/metroid/adjustToxLoss(amount)
	toxloss = Clamp(toxloss + amount, 0, maxHealth)

/mob/living/carbon/metroid/setToxLoss(amount)
	adjustToxLoss(amount-getToxLoss())

/mob/living/carbon/metroid/New(location, colour = "green")
	verbs += /mob/living/proc/ventcrawl

	src.colour = colour
	number = random_id(/mob/living/carbon/metroid, 1, 1000)
	name = "[colour] [is_adult ? "adult" : "baby"] metroid ([number])"
	real_name = name
	mutation_chance = rand(25, 35)
	regenerate_icons()
	..(location)

/mob/living/carbon/metroid/movement_delay()
	if (bodytemperature >= 330.23) // 135 F
		return -1	// metroids become supercharged at high temperatures

	var/tally = ..()

	var/health_deficiency = (maxHealth - health)
	if(health_deficiency >= 30) tally += (health_deficiency / 25)

	if (bodytemperature < 183.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(reagents)
		if(reagents.has_reagent(/datum/reagent/hyperzine)) // Hyperzine slows metroids down
			tally *= 2

		if(reagents.has_reagent(/datum/reagent/frostoil)) // Frostoil also makes them move VEEERRYYYYY slow
			tally *= 5

	if(health <= maxHealth) // if damaged, the metroid moves twice as slow
		tally *= 2

	return tally + config.movement.metroid_delay

/mob/living/carbon/metroid/Bump(atom/movable/AM as mob|obj, yes)
	if((!(yes) || now_pushing))
		return FALSE

	now_pushing = TRUE

	if(isobj(AM) && !client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)	probab = 20
			if(3 to 4)	probab = 30
			if(5 to 6)	probab = 40
			if(7 to 8)	probab = 60
			if(9)		probab = 70
			if(10)		probab = 95
		if(prob(probab))
			if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition())
					if (is_adult || prob(5))
						UnarmedAttack(AM)

	if(ismob(AM))
		var/mob/tmob = AM

		if(is_adult)
			if(istype(tmob, /mob/living/carbon/human))
				if(prob(90))
					now_pushing = FALSE
					return TRUE
		else
			if(istype(tmob, /mob/living/carbon/human))
				now_pushing = FALSE
				return TRUE

	now_pushing = FALSE

	return ..()

/mob/living/carbon/metroid/Allow_Spacemove()
	return 1

/mob/living/carbon/metroid/Stat()
	. = ..()

	statpanel("Status")
	stat(null, "Health: [round((health / maxHealth) * 100)]%")
	stat(null, "Intent: [a_intent]")

	if(client.statpanel == "Status")
		stat(null, "Nutrition: [nutrition]/[get_max_nutrition()]")
		if(amount_grown >= 10)
			if(is_adult)
				stat(null, "You can reproduce!")
			else
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")

/mob/living/carbon/metroid/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/metroid/bullet_act(obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return 0

/mob/living/carbon/metroid/emp_act(severity)
	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/metroid/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			qdel(src)
			return

		if (2.0)

			b_loss += 60
			f_loss += 60


		if(3.0)
			b_loss += 30

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()


/mob/living/carbon/metroid/__unequip(obj/W)
	return

/mob/living/carbon/metroid/attack_ui(slot)
	return

/mob/living/carbon/metroid/attack_hand(mob/living/carbon/human/H)

	..()

	if(Victim)
		var/probability = 60
		var/victim_substr = ""
		if(Victim != H)
			probability = 30
			victim_substr = " \the [Victim]"

		if(prob(probability))
			visible_message(SPAN("warning", "\The [H] attempts to wrestle \the [src] off[victim_substr]!"))
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

		else
			visible_message(SPAN("warning", "\The [H] manages to wrestle \the [src] off[victim_substr]!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

			confused = max(confused, 2)
			Feedstop()
			UpdateFace()
			step_away(src, H)
		return

	switch(H.a_intent)

		if(I_HELP)
			help_shake_act(H)

		if(I_DISARM)
			var/success = prob(40)
			visible_message(SPAN("warning", "The [H] pushes \the [src]!"+(success ? " \The [src] looks momentarily disoriented!" : "")))
			if(success)
				confused = max(confused, 2)
				UpdateFace()
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

		else

			var/damage = rand(1, 9)
			var/hit_zone = H.zone_sel.selecting
			var/datum/unarmed_attack/attack = H.get_unarmed_attack(src, hit_zone)

			if(attack)
				damage += attack.get_unarmed_damage(H)

			var/attack_verb = attack ? pick(attack.attack_verb) : "punch"

			attacked += 10
			if (prob(90))
				if((MUTATION_HULK in H.mutations) || (MUTATION_STRONG in H.mutations))
					damage += 5
					if(Victim || Target)
						Feedstop()
						Target = null
					spawn(0)
						step_away(src, H, 15)
						sleep(3)
						step_away(src, H, 15)

				playsound(loc, attack ? attack.attack_sound : SFX_FIGHTING_PUNCH, rand(80, 100), 1, -1)
				visible_message(
					SPAN("danger", "[H] has [attack_verb]ed [src]!"),
					SPAN("danger", "You has been [attack_verb]ed by [src]!")
				)

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message(SPAN("danger", "[H] has attempted to [attack_verb] [src]!"))
	return

/mob/living/carbon/metroid/attackby(obj/item/W, mob/user)

	if(istype(W,/obj/item/metroid_extract))
		handle_crossbreeding(W,user)
		return

	if(istype(W, /obj/item/storage/xenobag))
		var/obj/item/storage/P = W
		if(!effectmod)
			to_chat(user, SPAN_WARNING("The slime is not currently being mutated."))
			return
		var/hasOutput = FALSE //Have we outputted text?
		var/hasFound = FALSE //Have we found an extract to be added?
		for(var/obj/item/metroid_extract/S in P.contents)
			if(S.effectmod == effectmod)
				P.remove_from_storage(S, get_turf(src))
				qdel(S)
				applied_cores++
				hasFound = TRUE
			if(applied_cores >= METROID_EXTRACT_CROSSING_REQUIRED)
				to_chat(user, SPAN_NOTICE("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
				spawn_corecross()
				hasOutput = TRUE
				break
		if(!hasOutput)
			if(!hasFound)
				to_chat(user, SPAN_WARNING("There are no extracts in the bag that this slime will accept!"))
			else
				to_chat(user, SPAN_NOTICE("You feed the slime some extracts from the bag."))
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
		return

	if(W.force > 0)
		attacked += 10
		if(!(stat) && prob(25)) //Only run this check if we're alive or otherwise motile, otherwise surgery will be agonizing for xenobiologists.
			to_chat(user, "<span class='danger'>\The [W] passes right through \the [src]!</span>")
			return

	. = ..()

	if(Victim && prob(W.force * 5))
		Feedstop()
		step_away(src, user)

/mob/living/carbon/metroid/restrained()
	return 0

/mob/living/carbon/metroid/var/co2overloadtime = null
/mob/living/carbon/metroid/var/temperature_resistance = 75 CELSIUS

/mob/living/carbon/metroid/toggle_throw_mode()
	return

/mob/living/carbon/metroid/has_eyes()
	return 0

/mob/living/carbon/metroid/check_has_mouth()
	return 0

/mob/living/carbon/metroid/proc/gain_nutrition(amount)
	add_nutrition(amount)
	if(prob(amount * 2)) // Gain around one level per 50 nutrition
		powerlevel++
		if(powerlevel > 10)
			powerlevel = 10
			adjustToxLoss(-10)
	nutrition = min(nutrition, get_max_nutrition())
