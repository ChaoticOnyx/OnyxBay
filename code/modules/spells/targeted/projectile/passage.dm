/datum/spell/targeted/projectile/dumbfire/passage
	name = "Passage"
	desc = "throw a spell towards an area and teleport to it."
	feedback = "PA"
	proj_type = /obj/item/projectile/spell_projectile/passage


	school = "conjuration"
	charge_max = 250
	spell_flags = 0
	invocation = "A'YASAMA"
	invocation_type = SPI_SHOUT
	range = 15


	level_max = list(SP_TOTAL = 1, SP_SPEED = 0, SP_POWER = 1)
	spell_flags = NEEDSCLOTHES
	duration = 10

	proj_step_delay = 1

	icon_state = "gen_project"


/datum/spell/targeted/projectile/dumbfire/passage/prox_cast(list/targets, atom/spell_holder, mob/user)
	if(istype(user.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/cell = user.loc
		cell.go_out()
	for(var/mob/living/L in targets)
		apply_spell_damage(L)

	var/turf/T = get_turf(spell_holder)

	holder.forceMove(T)
	var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread()
	S.set_up(3,0,T)
	S.start()


/datum/spell/targeted/projectile/dumbfire/passage/empower_spell()
	if(!..())
		return FALSE

	amt_stunned += 3

	return "[src] now stuns those who get hit by it."

/obj/item/projectile/spell_projectile/passage
	name = "spell"
	icon_state = "energy2"
