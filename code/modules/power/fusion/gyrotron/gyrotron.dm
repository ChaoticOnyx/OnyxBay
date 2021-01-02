#define GYRO_POWER 25000

var/list/gyrotrons = list()

/obj/machinery/power/emitter/gyrotron
	name = "gyrotron"
	icon = 'icons/obj/machines/power/fusion.dmi'
	desc = "It is a heavy duty industrial gyrotron suited for powering fusion reactors."
	icon_state = "emitter-off"
	req_access = list(access_engine)
	use_power = POWER_USE_IDLE
	active_power_usage = GYRO_POWER

	var/id_tag
	var/rate = 3
	var/mega_energy = 1


/obj/machinery/power/emitter/gyrotron/anchored
	anchored = 1
	state = 2

/obj/machinery/power/emitter/gyrotron/Initialize()
	gyrotrons += src
	. = ..()
	change_power_consumption(mega_energy * GYRO_POWER, POWER_USE_ACTIVE)

/obj/machinery/power/emitter/gyrotron/Destroy()
	gyrotrons -= src
	return ..()

/obj/machinery/power/emitter/gyrotron/Process()
	change_power_consumption(mega_energy * GYRO_POWER, POWER_USE_ACTIVE)
	. = ..()

/obj/machinery/power/emitter/gyrotron/get_rand_burst_delay()
	return rate*10

/obj/machinery/power/emitter/gyrotron/get_burst_delay()
	return rate*10

/obj/machinery/power/emitter/gyrotron/get_emitter_beam()
	var/obj/item/projectile/beam/emitter/E = ..()
	E.damage = mega_energy * 50
	return E

/obj/machinery/power/emitter/gyrotron/update_icon()
	if (active && powernet && avail(active_power_usage))
		icon_state = "emitter-on"
	else
		icon_state = "emitter-off"

/obj/machinery/power/emitter/gyrotron/attackby(obj/item/W, mob/user)
	if(isMultitool(W))
		var/new_ident = sanitize(input("Enter a new ident tag.", "Gyrotron", id_tag) as null|text)
		if(new_ident && user.Adjacent(src))
			id_tag = new_ident
		return

	else if(isWrench(W))
		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return

	return ..()

#undef GYRO_POWER
