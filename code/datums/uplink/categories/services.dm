/***********
* Services *
************/
/datum/uplink_item/item/services
	category = /datum/uplink_category/services

/datum/uplink_item/item/services/fake_ion_storm
	name = "Ion Storm Announcement"
	desc = "Interferes with ion sensors."
	item_cost = 1
	path = /obj/item/device/uplink_service/fake_ion_storm

/datum/uplink_item/item/services/suit_sensor_garble
	name = "Complete Suit Sensor Jamming"
	desc = "Garbles all suit sensor data for 10 minutes."
	item_cost = 2
	path = /obj/item/device/uplink_service/jamming/garble

/datum/uplink_item/item/services/fake_rad_storm
	name = "Radiation Storm Announcement"
	desc = "Interferes with radiation sensors."
	item_cost = 3
	path = /obj/item/device/uplink_service/fake_rad_storm

/datum/uplink_item/item/services/fake_crew_annoncement
	name = "Crew Arrival Announcement and Records"
	desc = "Creates a fake crew arrival announcement as well as fake crew records, using your current appearance (including held items!) and worn id card. Prepare well!"
	item_cost = 2
	path = /obj/item/device/uplink_service/fake_crew_announcement

/datum/uplink_item/item/services/suit_sensor_shutdown
	name = "Complete Suit Sensor Shutdown"
	desc = "Completely disables all suit sensors for 10 minutes."
	item_cost = 3
	path = /obj/item/device/uplink_service/jamming

/datum/uplink_item/item/services/fake_update_announcement
	name = "Central Command Announcement"
	desc = "Causes a falsified central command announcement. Think carefully about the consequences!"
	item_cost = 3
	path = /obj/item/device/uplink_service/fake_update_announcement

/***************
* Service Item *
***************/

#define AWAITING_ACTIVATION 0
#define CURRENTLY_ACTIVE 1
#define HAS_BEEN_ACTIVATED 2

/obj/item/device/uplink_service
	name = "tiny device"
	desc = "Press button to activate. Can be done once and only once."
	w_class = ITEM_SIZE_TINY
	icon_state = "sflash"
	var/state = AWAITING_ACTIVATION
	var/service_label = "Unnamed Service"
	var/service_duration = 0 SECONDS

/obj/item/device/uplink_service/Destroy()
	if(state == CURRENTLY_ACTIVE)
		deactivate()
	. = ..()

/obj/item/device/uplink_service/_examine_text(user)
	. = ..()
	if(get_dist(src, user) > 1)
		return
	var/msg
	switch(state)
		if(AWAITING_ACTIVATION)
			msg = "It is labeled '[service_label]' and appears to be awaiting activation."
		if(CURRENTLY_ACTIVE)
			msg = "It is labeled '[service_label]' and appears to be active."
		if(HAS_BEEN_ACTIVATED)
			msg = "It is labeled '[service_label]' and appears to be permanently disabled."
	. += "\n[msg]"

/obj/item/device/uplink_service/attack_self(mob/user)
	if(state != AWAITING_ACTIVATION)
		to_chat(user, "<span class='warning'>\The [src] won't activate again.</span>")
		return
	if(!enable())
		return
	state = CURRENTLY_ACTIVE
	update_icon()
	user.visible_message("<span class='notice'>\The [user] activates \the [src].</span>", "<span class='notice'>You activate \the [src].</span>")
	log_and_message_admins("has activated the service '[service_label]'", user)

	if(service_duration)
		addtimer(CALLBACK(src,/obj/item/device/uplink_service/proc/deactivate), service_duration)
	else
		deactivate()

/obj/item/device/uplink_service/proc/deactivate()
	if(state != CURRENTLY_ACTIVE)
		return
	disable()
	state = HAS_BEEN_ACTIVATED
	update_icon()
	playsound(loc, SFX_SPARK, 50, 1)
	visible_message("<span class='warning'>\The [src] shuts down with a spark.</span>")

/obj/item/device/uplink_service/update_icon()
	switch(state)
		if(AWAITING_ACTIVATION)
			icon_state = initial(icon_state)
		if(CURRENTLY_ACTIVE)
			icon_state = "sflash_on"
		if(HAS_BEEN_ACTIVATED)
			icon_state = "sflash_burnt"

/obj/item/device/uplink_service/proc/enable(mob/user = usr)
	return TRUE

/obj/item/device/uplink_service/proc/disable(mob/user = usr)
	return

/*****************
* Sensor Jamming *
*****************/
/obj/item/device/uplink_service/jamming
	service_duration = 10 MINUTES
	service_label = "Suit Sensor Shutdown"
	var/suit_sensor_jammer_method/ssjm = /suit_sensor_jammer_method/cap_off

/obj/item/device/uplink_service/jamming/New()
	..()
	ssjm = new ssjm()

/obj/item/device/uplink_service/jamming/Destroy()
	qdel(ssjm)
	ssjm = null
	. = ..()

/obj/item/device/uplink_service/jamming/enable(mob/user = usr)
	ssjm.enable()
	. = ..()

/obj/item/device/uplink_service/jamming/disable(mob/user = usr)
	ssjm.disable()

/obj/item/device/uplink_service/jamming/garble
	service_label = "Suit Sensor Garble"
	ssjm = /suit_sensor_jammer_method/random/moderate

/*****************
* Fake Ion storm *
*****************/
/obj/item/device/uplink_service/fake_ion_storm
	service_label = "Ion Storm Announcement"

/obj/item/device/uplink_service/fake_ion_storm/enable(mob/user = usr)
	GLOB.using_map.ion_storm_announcement()
	. = ..()

/*****************
* Fake Rad storm *
*****************/
/obj/item/device/uplink_service/fake_rad_storm
	service_label = "Radiation Storm Announcement"

/obj/item/device/uplink_service/fake_rad_storm/enable(mob/user = usr)
	var/datum/event_meta/EM = new(EVENT_LEVEL_MUNDANE, "Fake Radiation Storm", add_to_queue = 0)
	new /datum/event/radiation_storm/syndicate(EM)
	. = ..()

/***************************
* Fake CentCom Annoncement *
***************************/
/obj/item/device/uplink_service/fake_update_announcement
	service_label = "Fake Update Announcement"

/obj/item/device/uplink_service/fake_update_announcement/Destroy()
	if(state == CURRENTLY_ACTIVE)
		deactivate()
		update_icon()
	. = ..()

/obj/item/device/uplink_service/fake_update_announcement/enable(mob/user = usr)
	if(state != AWAITING_ACTIVATION)
		to_chat(user, "<span class='warning'>\The [src] won't activate again.</span>")
		return
	user.visible_message("<span class='notice'>\The [user] activates \the [src].</span>", "<span class='notice'>You activate \the [src].</span>")
	log_and_message_admins("has activated the service '[service_label]'", user)
	state = CURRENTLY_ACTIVE
	var/input = sanitize(input(user, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null, extra = 0)
	if(!input)
		state = AWAITING_ACTIVATION
		return
	var/customname = sanitizeSafe(input(user, "Pick a title for the report.", "Title") as text|null)
	if(!customname)
		customname = "[command_name()] Update"

	//New message handling
	post_comm_message(customname, replacetext(input, "\n", "<br/>"))

	switch(alert("Should this be announced to the general population?",,"Yes","No"))
		if("Yes")
			command_announcement.Announce(input, customname, new_sound = GLOB.using_map.command_report_sound, msg_sanitized = 1);
			deactivate()
		if("No")
			minor_announcement.Announce(message = "New [GLOB.using_map.company_name] Update available at all communication consoles.")
			deactivate()

/obj/item/device/uplink_service/fake_update_announcement/update_icon()
	switch(state)
		if(AWAITING_ACTIVATION)
			icon_state = initial(icon_state)
		if(CURRENTLY_ACTIVE)
			icon_state = "sflash_on"
		if(HAS_BEEN_ACTIVATED)
			icon_state = "sflash_burnt"

/*********************************
* Fake Crew Records/Announcement *
*********************************/
/obj/item/device/uplink_service/fake_crew_announcement
	service_label = "Crew Arrival Announcement and Records"
	var/does_announce_visit = 1
	var/obj/item/card/id/id_card = null

/obj/item/device/uplink_service/fake_crew_announcement/attackby(obj/item/I, mob/user = usr)
	id_card = I.GetIdCard()
	if(istype(id_card))
		to_chat(user, SPAN("notice", "Card saved!"))

/obj/item/device/uplink_service/fake_crew_announcement/verb/verb_toggle_mode()
	set category = "Object"
	set name = "Toggle Announce Mode"
	set src in usr

	does_announce_visit = !does_announce_visit
	if (does_announce_visit)
		to_chat(usr, SPAN("notice", "Device will announce your visit!"))
	else
		to_chat(usr, SPAN("notice", "Device will not announce your visit!"))

/obj/item/device/uplink_service/fake_crew_announcement/enable(mob/user = usr)
	if(!istype(id_card))
		to_chat(user, SPAN("notice", "You have to swipe a card!"))
		return

	var/datum/computer_file/crew_record/new_record = CreateModularRecord(user)

	new_record.set_name(id_card.registered_name)
	new_record.set_sex(id_card.sex)
	new_record.set_age(id_card.age)
	new_record.set_job(id_card.assignment)
	new_record.set_fingerprint(id_card.fingerprint_hash)
	new_record.set_bloodtype(id_card.blood_type)
	new_record.set_dna(id_card.dna_hash)
	new_record.set_species(user.get_species())

	var/datum/job/job = job_master.GetJob(id_card.assignment)
	if(!job)
		job = new()
		job.title = id_card.assignment
		job.department_flag = CIV

	var/assigned_flags = list()
	for(var/flag in GLOB.department_flags)
		if(flag & job.department_flag)
			assigned_flags += flag
	new_record.assigned_deparment_flags = assigned_flags

	var/record_field/department/department = locate() in new_record.fields; ASSERT(istype(department))

	var/default_message = "The current list of department flags:"
	var/list/current_department_flags_name_list = list()
	for(var/flag in new_record.assigned_deparment_flags)
		current_department_flags_name_list[GLOB.department_flags_to_text[num2text(flag)]] = flag

	department.set_value(english_list(edit_department(new_record, current_department_flags_name_list, default_message)))

	if(does_announce_visit)
		var/datum/spawnpoint/arrivals/spawnpoint = new()
		AnnounceArrival(id_card.registered_name, job, spawnpoint, arrival_sound_volume = 60, captain_sound_volume = 40)
	. = ..()
