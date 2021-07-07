/obj/item/device/spy_bug
	name = "bug"
	desc = ""	// Nothing to see here
	icon = 'icons/obj/weapons.dmi'
	icon_state = "eshield0"
	item_state = "nothing"
	layer = BELOW_TABLE_LAYER

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1, TECH_ILLEGAL = 3)

	var/obj/item/device/spy_monitor/paired_with
	var/obj/item/device/radio/spy/radio
	var/obj/machinery/camera/spy/camera

/obj/item/device/spy_bug/New()
	..()
	radio = new(src)
	camera = new(src)
	GLOB.listening_objects += src

/obj/item/device/spy_bug/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(camera)
	GLOB.listening_objects -= src
	return ..()

/obj/item/device/spy_bug/examine(mob/user)
	. = ..()
	if(get_dist(src, user) <= 0)
		. += "\nIt's a tiny camera, microphone, and transmission device in a happy union."
		. += "\nNeeds to be both configured and brought in contact with monitor device to be fully functional."

/obj/item/device/spy_bug/attack_self(mob/user)
	radio.attack_self(user)

/obj/item/device/spy_bug/attackby(obj/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/device/spy_monitor))
		var/obj/item/device/spy_monitor/SM = W
		SM.pair(src, user)
	else
		..()

/obj/item/device/spy_bug/hear_talk(mob/M, msg, verb, datum/language/speaking)
	radio.hear_talk(M, msg, speaking)

/obj/item/device/spy_bug/proc/pair_with(obj/item/device/spy_monitor/SM)
	paired_with = SM

/obj/item/device/spy_bug/proc/unpair()
	paired_with = null

/obj/item/device/spy_bug/Move()
	. = ..()
	if(. && paired_with)
		paired_with.bug_moved()

/obj/item/device/spy_bug/forceMove()
	. = ..()
	if(. && paired_with)
		paired_with.bug_moved()

/obj/item/device/spy_monitor
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"

	w_class = ITEM_SIZE_SMALL

	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1, TECH_ILLEGAL = 3)

	var/obj/item/device/uplink/uplink
	var/cam_spy_active = FALSE
	var/timer
	var/list/area/active_recon_areas_list = list()
	var/finish = FALSE // to protect user anus from picking bugs in finish check tick.

	var/operating = FALSE
	var/obj/item/device/radio/spy/radio
	var/obj/machinery/camera/spy/selected_camera
	var/list/obj/item/device/spy_bug/bugs = list()
	var/list/obj/machinery/camera/spy/cameras = list()

/obj/item/device/spy_monitor/New()
	..()
	radio = new(src)
	GLOB.listening_objects += src

/obj/item/device/spy_monitor/Destroy()
	GLOB.listening_objects -= src
	return ..()

/obj/item/device/spy_monitor/examine(mob/user)
	. = ..()
	if(get_dist(src, user) <= 1)
		. += "\nThe time '12:00' is blinking in the corner of the screen and \the [src] looks very cheaply made."

/obj/item/device/spy_monitor/proc/bug_moved()
	if(!timer || !length(cameras) || !length(active_recon_areas_list) || finish)
		return
	if(ishuman(uplink?.uplink_owner?.current))
		to_chat(uplink.uplink_owner.current, SPAN("notice", "It looks like there are problems with your spy network in one the following areas:\n[english_list(active_recon_areas_list, and_text = "\n")]\nBugs maintenance required. Your current progress has been zeroed out."))
	active_recon_areas_list = list()
	deltimer(timer)
	timer = null

/obj/item/device/spy_monitor/proc/start()
	timer = addtimer(CALLBACK(src, .proc/finish), 10 MINUTES, TIMER_STOPPABLE)

/obj/item/device/spy_monitor/proc/finish()
	if(length(active_recon_areas_list) && !finish)
		finish = TRUE
		for(var/datum/antag_contract/recon/C in GLOB.all_contracts)
			if(C.completed)
				continue
			C.check(src)
		finish = FALSE

/obj/item/device/spy_monitor/verb/activate()
	set name = "Activate Spy System"
	set category = "Object"
	if(usr.incapacitated() || !Adjacent(usr) || !ishuman(usr))
		return
	if(timer)
		to_chat(usr, SPAN("notice", "Active spy network detected in the following areas:\n[english_list(active_recon_areas_list, and_text = "\n")]\nYou can deactivate the network by picking up the camera bugs."))
		return
	var/list/sensor_list = list()
	if(length(active_recon_areas_list))
		active_recon_areas_list = list()
	var/list/messages = list()
	var/list/obj/item/device/spy_bug/spy_net = bugs.Copy()
	while(length(spy_net))
		var/obj/item/device/spy_bug/S = pick(spy_net)
		spy_net.Remove(S)

		if(!isturf(S.loc))
			messages += "Camera bug ([S.camera.name]) is not located on floor."
			continue

		var/detected_AS = FALSE
		for(var/obj/item/device/spy_bug/AS in range(1, S))
			if(AS == S)
				continue
			detected_AS = TRUE
			messages += "Another camera bug in proximity prevents activation. (current bug: ([S.camera.name]), conflicting bug: [AS.camera.name])"
			if(AS in spy_net)
				spy_net.Remove(AS)
		if(detected_AS)
			continue

		var/turf/T = S.loc
		var/area/S_area = T.loc
		if(!S_area)
			continue
		if(!sensor_list[S_area.name])
			sensor_list[S_area.name] = 1
		else
			sensor_list[S_area.name] = sensor_list[S_area.name] + 1

	var/sensor_active = FALSE
	for(var/area_name in sensor_list)
		if(sensor_list[area_name] >= 3)
			sensor_active = TRUE
			to_chat(usr, SPAN("notice", "Data collection initiated."))
			start()
			if(uplink?.uplink_owner == usr.mind)
				var/area/A = get_area_name(area_name)
				active_recon_areas_list += A
				for(var/datum/antag_contract/recon/C in GLOB.all_contracts)
					if(C.completed)
						continue
					if(A in C.targets)
						to_chat(usr, SPAN("notice", "Recon contract locked in."))

	if(!sensor_active)
		if(!length(messages))
			messages += "Not enough bugs."
		to_chat(usr, SPAN("warning", "Data collection initialization failed:\n[english_list(messages, and_text = "\n")]"))

/obj/item/device/spy_monitor/attack_self(mob/user)
	if(operating)
		return

	radio.attack_self(user)
	view_cameras(user)

/obj/item/device/spy_monitor/attackby(obj/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/device/spy_bug))
		pair(W, user)
	else
		return ..()

/obj/item/device/spy_monitor/proc/pair(obj/item/device/spy_bug/SB, mob/living/user)
	if(SB.camera in cameras)
		to_chat(user, SPAN("notice", "\The [SB] has been unpaired from \the [src]."))
		SB.unpair()
		bugs -= SB
		cameras -= SB.camera
	else
		to_chat(user, SPAN("notice", "\The [SB] has been paired with \the [src]."))
		SB.pair_with(src)
		bugs += SB
		cameras += SB.camera

/obj/item/device/spy_monitor/proc/view_cameras(mob/user)
	if(!can_use_cam(user))
		return

	selected_camera = cameras[1]
	view_camera(user)

	operating = 1
	while(selected_camera && Adjacent(user))
		selected_camera = input("Select camera bug to view.") as null|anything in cameras
	selected_camera = null
	operating = 0

/obj/item/device/spy_monitor/proc/view_camera(mob/user)
	spawn(0)
		while(selected_camera && Adjacent(user))
			var/turf/T = get_turf(selected_camera)
			if(!T || !is_on_same_plane_or_station(T.z, user.z) || !selected_camera.can_use())
				user.unset_machine()
				user.reset_view(null)
				to_chat(user, "<span class='notice'>[selected_camera] unavailable.</span>")
				sleep(90)
			else
				user.set_machine(selected_camera)
				user.reset_view(selected_camera)
			sleep(10)
		user.unset_machine()
		user.reset_view(null)

/obj/item/device/spy_monitor/proc/can_use_cam(mob/user)
	if(operating)
		return

	if(!cameras.len)
		to_chat(user, "<span class='warning'>No paired cameras detected!</span>")
		to_chat(user, "<span class='warning'>Bring a bug in contact with this device to pair the camera.</span>")
		return

	return 1

/obj/item/device/spy_monitor/hear_talk(mob/M, msg, verb, datum/language/speaking)
	return radio.hear_talk(M, msg, speaking)


/obj/machinery/camera/spy
	// These cheap toys are accessible from the syndicate camera console as well
	network = list(NETWORK_SYNDICATE)

/obj/machinery/camera/spy/New()
	..()
	name = "DV-136ZB #[random_id(/obj/machinery/camera/spy, 1000,9999)]"
	c_tag = name

/obj/machinery/camera/spy/check_eye(mob/user as mob)
	return 0

/obj/item/device/radio/spy
	listening = 0
	frequency = 1473
	broadcasting = 0
	canhear_range = 1
	name = "spy device"
	icon_state = "syn_cypherkey"
