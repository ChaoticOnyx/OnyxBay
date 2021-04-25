/obj/item/device/spy_sensor
	name = "spying sensor"
	icon_state = "motion0" //placeholder
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MAGNET = 5, TECH_ILLEGAL = 2)
	matter = list(MATERIAL_STEEL = 4000, MATERIAL_PLATINUM = 2000)
	var/active = FALSE
	var/obj/item/device/uplink/uplink
	var/list/obj/item/device/spy_sensor/group
	var/timer

/obj/item/device/spy_sensor/Destroy()
	group = null
	return ..()

/obj/item/device/spy_sensor/Move()
	. = ..()
	if(.)
		reset()

/obj/item/device/spy_sensor/forceMove()
	. = ..()
	if(.)
		reset()

/obj/item/device/spy_sensor/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	var/obj/item/device/uplink/U = W.hidden_uplink
	if(U && U.uplink_owner)
		if(uplink == U)
			return
		uplink = U
		to_chat(user, "You claim \the [src].")

/obj/item/device/spy_sensor/verb/activate()
	set name = "Activate"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || !Adjacent(usr) || !isturf(loc) || !ishuman(usr))
		return
	if(locate(/obj/item/device/spy_sensor) in orange(src,1))
		to_chat(usr, SPAN_WARNING("Another sensor in proximity prevents activation."))
		return
	active = TRUE
	start()

	var/sensor_amount = length(get_local_sensors())
	to_chat(usr, SPAN_NOTICE("Sensor activated. [sensor_amount] sensor\s active in the area."))
	if(sensor_amount >= 3 && timer)
		to_chat(usr, SPAN_NOTICE("Data collection initiated."))
		if(uplink)
			for(var/datum/antag_contract/recon/C in GLOB.all_contracts)
				if(C.completed)
					continue
				if(get_area(src) in C.targets)
					to_chat(usr, SPAN_NOTICE("Recon contract locked in."))
					return

/obj/item/device/spy_sensor/proc/get_local_sensors()
	var/list/local_sensors = list()
	for(var/obj/item/device/spy_sensor/S in get_area(src))
		if(S.uplink != uplink || !S.active)
			continue
		local_sensors += S
	return local_sensors

/obj/item/device/spy_sensor/proc/start()
	var/list/local_sensors = get_local_sensors()
	if(local_sensors.len >= 3)
		timer = addtimer(CALLBACK(src, .proc/finish), 10 MINUTES, TIMER_STOPPABLE)
		for(var/obj/item/device/spy_sensor/S in local_sensors)
			S.timer = timer
			S.group = local_sensors

/obj/item/device/spy_sensor/proc/reset()
	if(!timer || !group)
		return

	if(length(group) > 3)
		group -= src
		return

	deltimer(timer)
	for(var/obj/item/device/spy_sensor/S in group)
		S.timer = null
		S.group = null
	start()

/obj/item/device/spy_sensor/proc/finish()
	for(var/datum/antag_contract/recon/C in GLOB.all_contracts)
		if(C.completed)
			continue
		C.check(src)
	for(var/obj/item/device/spy_sensor/S in group)
		S.self_destruct()

/obj/item/device/spy_sensor/proc/self_destruct()
	empulse(src, 0, 2)
	qdel(src)
