/datum/spell/contract/return_master
	name = "Return to Master"
	desc = "Teleport back to your master"

	school = "conjuration"
	charge_max = 600
	spell_flags = 0
	invocation = "none"
	invocation_type = SPI_NONE
	cooldown_min = 200
	smoke_spread = 1
	smoke_amt = 5
	need_target = FALSE
	icon_state = "wiz_tele"


/datum/spell/contract/return_master/cast(mob/target, mob/user)
	target = ..(target, user)
	if(!target)
		return
	if(istype(target.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/cell = target.loc
		cell.go_out()
	target.forceMove(get_turf(user))
