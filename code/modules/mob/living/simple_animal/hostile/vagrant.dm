
/mob/living/simple_animal/hostile/vagrant
	name = "creature"
	desc = "You get the feeling you should run."
	icon = 'icons/mob/mob.dmi'
	icon_state = "vagrant"
	icon_living = "vagrant"
	icon_dead = "vagrant"
	icon_gib = "vagrant"
	maxHealth = 65
	health = 40
	speed = 5
	speak_chance = 0
	turns_per_move = 3
	move_to_delay = 3
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	break_stuff_probability = 0
	faction = "vagrant"
	harm_intent_damage = 3
	melee_damage_lower = 3
	melee_damage_upper = 4
	light_color = "#8A0707"
	attacktext = "mauled"
	attack_sound = 'sound/weapons/bite.ogg'
	min_gas = null
	max_gas = null
	minbodytemp = 0
	bodyparts = /decl/simple_animal_bodyparts/metroid // Kinda close I guess
	var/datum/disease2/disease/carried
	var/cloaked = 0
	var/weakref/gripping = null // Must be mob/living/carbon/human
	var/blood_per_tick = 4.25
	var/health_per_tick = 0.8

/mob/living/simple_animal/hostile/vagrant/Initialize()
	. = ..()
	if(prob(40))
		carried = new /datum/disease2/disease()
		carried.makerandom(rand(2, 4))

/mob/living/simple_animal/hostile/vagrant/Allow_Spacemove(check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/vagrant/bullet_act(obj/item/projectile/Proj)
	. = ..()
	var/oldhealth = health
	if((target_mob != Proj.firer) && health < oldhealth && !incapacitated(INCAPACITATION_KNOCKOUT) && !client) //Respond to being shot at
		set_target_mob(Proj.firer)
		turns_per_move = 2
		MoveToTarget()

/mob/living/simple_animal/hostile/vagrant/Life()
	. = ..()
	var/mob/living/carbon/human/victim = gripping?.resolve()
	if(victim)
		if(get_turf(src) != get_turf(victim))
			gripping = null

		else if(victim.should_have_organ(BP_HEART))
			var/blood_volume = round(victim.vessel.get_reagent_amount(/datum/reagent/blood))
			if(blood_volume > 5)
				victim.vessel.remove_reagent(/datum/reagent/blood, blood_per_tick)
				health = min(health + health_per_tick, maxHealth)
				if(prob(15))
					to_chat(gripping, "<span class='danger'>You feel your fluids being drained!</span>")
			else
				gripping = null

		if(turns_per_move != initial(turns_per_move))
			turns_per_move = initial(turns_per_move)

	if(stance == HOSTILE_STANCE_IDLE && !cloaked)
		cloaked = 1
		update_icon()
	if(health == maxHealth)
		new /mob/living/simple_animal/hostile/vagrant(src.loc)
		new /mob/living/simple_animal/hostile/vagrant(src.loc)
		gib()
		return
	if(health < 1)
		gib() //Leave no identifiable evidence.
		return

/mob/living/simple_animal/hostile/vagrant/update_icon()
	if(cloaked) //It's fun time
		alpha = 45
		set_light(0)
		icon_state = initial(icon_state)
		move_to_delay = initial(move_to_delay)
	else //It's fight time
		alpha = 255
		icon_state = "vagrant_glowing"
		set_light(0.2, 0.1, 3)
		move_to_delay = 2

/mob/living/simple_animal/hostile/vagrant/AttackingTarget()
	. = ..()
	if(ishuman(.))
		var/mob/living/carbon/human/H = .
		if(gripping == weakref(H))
			H.Weaken(3)
			H.Stun(3)
			return
		//This line ensures there's always a reasonable chance of grabbing, while still
		//Factoring in health
		if(!(gripping?.resolve()) && (cloaked || prob(health + ((maxHealth - health) * 2))))
			gripping = weakref(H)
			cloaked = 0
			update_icon()
			H.Weaken(3)
			H.Stun(3)
			H.visible_message("<span class='danger'>\the [src] latches onto \the [H], pulsating!</span>")
			if(carried && length(H.virus2) == 0)
				infect_virus2(H, carried, 1)
			forceMove(H)
			return

/mob/living/simple_animal/hostile/vagrant/swarm/Initialize()
	. = ..()
	if(prob(75)) new /mob/living/simple_animal/hostile/vagrant(loc)
	if(prob(50)) new /mob/living/simple_animal/hostile/vagrant(loc)
