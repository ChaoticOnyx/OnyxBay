/*
	Moved the non-airlock procs in airlock.dm to here.
*/

//*** Blocking Airlocks

/atom/movable/proc/blocks_airlock()
	return density

/obj/machinery/door/blocks_airlock()
	return 0

/obj/structure/window/blocks_airlock()
	return 0

/obj/machinery/mech_sensor/blocks_airlock()
	return 0

/obj/effect/energy_field/blocks_airlock()
	return 0

/obj/machinery/shield/blocks_airlock()
	return 0

/mob/living/blocks_airlock()
	return 1

/obj/structure/closet/body_bag/blocks_airlock()
	if (locate(/mob) in src)
		return 1
	else
		return 0				//Prevents Airlocks from closing on Bodybags and Cryobags with people inside


//*** Airlock Crushing

#define AIRLOCK_CRUSH_INCREMENT 10 // Damage caused by airlock crushing a mob is split into multiple smaller hits. Makes door crushing behave more like a "slow" crushing effect rather than high-speed impacts.
#define CYBORG_AIRLOCKCRUSH_RESISTANCE 2 // Damage caused to silicon mobs (usually cyborgs) from being crushed by airlocks is divided by this number. Unlike organics cyborgs don't have passive regeneration.

/atom/movable/proc/airlock_crush(crush_damage)
	return

/obj/structure/window/airlock_crush(crush_damage)
	ex_act(2)//Smashin windows

/obj/machinery/portable_atmospherics/canister/airlock_crush(crush_damage)
	. = ..()
	health -= crush_damage
	healthcheck()

/obj/effect/energy_field/airlock_crush(crush_damage)
	Stress(crush_damage)

/obj/structure/closet/airlock_crush(crush_damage)
	..()
	damage(crush_damage)
	for(var/atom/movable/AM in src)
		AM.airlock_crush()
	return

/mob/living/airlock_crush(crush_damage)
	. = ..()

	//using getarmor() instead of run_armor_check() to reflect the fact that this is "slow" damage and not high-impact damage
	var/protection = blocked_mult(getarmor(null, "melee"))
	crush_damage *= protection

	for(var/i in 1 to round(crush_damage/AIRLOCK_CRUSH_INCREMENT, 1))
		apply_damage(AIRLOCK_CRUSH_INCREMENT, BRUTE, null, 0)

	SetStunned(round(crush_damage / 8, 1))
	SetWeakened(round(crush_damage / 8, 1))


/mob/living/carbon/airlock_crush(crush_damage)
	. = ..()
	if (can_feel_pain())
		emote("scream")

/mob/living/silicon/robot/airlock_crush(crush_damage)
	return ..(round(crush_damage / CYBORG_AIRLOCKCRUSH_RESISTANCE)) //TODO implement robot melee armour and remove this.
