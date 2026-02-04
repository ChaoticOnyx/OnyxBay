/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = ITEM_SIZE_TINY
	mod_weight = 0.1
	mod_reach = 0.25
	mod_handy = 0.25
	slot_flags = SLOT_EARS
	var/associated_account_number = 0

	var/list/files = list(  )

	drop_sound = SFX_DROP_DISK
	pickup_sound = SFX_PICKUP_DISK

/obj/item/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "card_data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.SetName(text("data disk- '[]'", t))
	else
		src.SetName("data disk")
	src.add_fingerprint(usr)
	return

/*
 * ID CARDS
 */

/obj/item/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "emag"
	origin_tech = list(TECH_MAGNET = 2, TECH_ILLEGAL = 2)

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "emag"
	origin_tech = list(TECH_MAGNET = 2, TECH_ILLEGAL = 2)
	var/uses = 10

var/const/NO_EMAG_ACT = -50
/obj/item/card/emag/resolve_attackby(atom/A, mob/user)
	var/used_uses = A.emag_act(uses, user, src)
	if(used_uses == NO_EMAG_ACT)
		return ..(A, user)

	uses -= used_uses
	uses = max(uses, -1)
	A.add_fingerprint(user)
	if(used_uses)
		log_and_message_admins("emagged \an [A].")

	if(uses == 0)
		user.visible_message(SPAN("warning", "\The [src] fizzles and sparks - it seems it's been used once too often, and is now spent."))
		var/obj/item/card/emag_broken/junk = new(user.loc)
		junk.add_fingerprint(user)
		uses = -1
		user.replace_item(src, junk, TRUE, TRUE)

	return 1

/obj/item/card/emag/robot
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "emag"
	origin_tech = list(TECH_MAGNET = 2, TECH_ILLEGAL = 2)
	uses = 3

/obj/item/card/emag/robot/resolve_attackby(atom/A, mob/user)
	var/used_uses = A.emag_act(uses, user, src)
	if(used_uses == NO_EMAG_ACT)
		return ..(A, user)

	uses -= used_uses
	if(used_uses)
		log_and_message_admins("emagged \an [A].")

	if(uses<1)
		user.visible_message("<span class='warning'>\The [src] fizzles and sparks - it seems it's been used once too often, and is now spent.</span>")
	return 1

/obj/item/card/emag/robot/examine(mob/user, infix)
	. = ..()
	. += SPAN_NOTICE("It has [uses] uses left.")

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access."
	icon_state = "card_id"
	item_state = "card_id"

	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_ID

	var/age = "\[UNSET\]"
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"
	var/sex = "\[UNSET\]"
	var/icon/front
	var/icon/side
	var/mining_points //miners gotta eat

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0			// determines if this ID has claimed a dorm already

	var/job_access_type     // Job type to acquire access rights from, if any

/obj/item/card/id/New()
	..()
	if(job_access_type)
		var/datum/job/j = job_master.GetJobByType(job_access_type)
		if(j)
			rank = j.title
			assignment = rank
			access |= j.get_access()

/obj/item/card/id/examine(mob/user, infix)
	. = ..()

	if(in_range(user, src))
		show(user)
		. += desc
		return

	if(isghost(user))
		. += desc
		return

	. += SPAN("warning", "It is too far away.")

/obj/item/card/id/get_examine_line(examine_distance = 10)
	var/visible_name = examine_distance < 3 ? name : "ID Card"
	if(is_bloodied)
		. = SPAN("warning", "\icon[src] a [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [SPAN("info", "<em>[visible_name]</em>")]")
	else
		. = "\icon[src] \a [SPAN("info", "<em>[visible_name]</em>")]"

/obj/item/card/id/proc/prevent_tracking()
	return 0

/obj/item/card/id/proc/show(mob/user)
	if(front && side)
		send_rsc(user, front, "front.png")
		send_rsc(user, side, "side.png")
	var/datum/browser/popup = new(user, "idcard", name, 600, 250)
	popup.set_content(dat())
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/item/card/id/proc/update_name()
	var/final_name = "[registered_name]'s ID Card"

	if(assignment)
		final_name = final_name + " ([assignment])"
	SetName(final_name)

/obj/item/card/id/proc/set_id_photo(mob/M)
	M.ImmediateOverlayUpdate()
	front = M.get_flat_icon(M, SOUTH)
	side = M.get_flat_icon(M, WEST)

/mob/proc/set_id_info(obj/item/card/id/id_card)
	id_card.age = 0
	id_card.registered_name		= real_name
	id_card.sex 				= capitalize(gender)
	spawn(2 SECONDS)
		id_card.set_id_photo(src)

	if(dna)
		id_card.blood_type		= dna.b_type
		id_card.dna_hash		= dna.unique_enzymes
		id_card.fingerprint_hash= md5(dna.uni_identity)
	id_card.update_name()

/mob/living/carbon/human/set_id_info(obj/item/card/id/id_card)
	..()
	id_card.age = age

/obj/item/card/id/proc/dat()
	var/list/dat = list("<table><tr><td>")
	dat += text("Name: []</A><BR>", registered_name)
	dat += text("Sex: []</A><BR>\n", sex)
	dat += text("Age: []</A><BR>\n", age)
	dat += text("Assignment: []</A><BR>\n", assignment)
	dat += text("Fingerprint: []</A><BR>\n", fingerprint_hash)
	dat += text("Blood Type: []<BR>\n", blood_type)
	dat += text("DNA Hash: []<BR><BR>\n", dna_hash)
	if(mining_points)
		dat += text("Ore Redemption Points: []<BR><BR>\n", mining_points)
	if(front && side)
		dat +="<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4><img src=side.png height=80 width=80 border=4></td>"
	dat += "</tr></table>"
	return jointext(dat,null)

/obj/item/card/id/attack_self(mob/user)
	user.visible_message("\The [user] shows you: \icon[src] [src.name]. The assignment on the card: [src.assignment]",\
		"You flash your ID card: \icon[src] [src.name]. The assignment on the card: [src.assignment]")

	src.add_fingerprint(user)
	return

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/get_id_card()
	return src

/obj/item/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	to_chat(usr, text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment))
	to_chat(usr, "The blood type on the card is [blood_type].")
	to_chat(usr, "The DNA hash on the card is [dna_hash].")
	to_chat(usr, "The fingerprint hash on the card is [fingerprint_hash].")
	if(mining_points)
		to_chat(usr, "A ticker indicates the card has [mining_points] ore redemption points available.")
	return

/obj/item/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "card_silver"
	item_state = "card_silver"
	job_access_type = /datum/job/hop

/obj/item/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "card_gold"
	item_state = "card_gold"
	job_access_type = /datum/job/captain

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	icon_state = "card_syndie"
	item_state = "card_syndie"
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)

/obj/item/card/id/syndicate_command/gold
	icon_state = "card_syndieGold"
	item_state = "card_syndieGold"

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "card_gold"
	item_state = "card_gold"
	registered_name = "Captain"
	assignment = "Captain"
	is_poi = TRUE

/obj/item/card/id/captains_spare/New()
	access = get_all_station_access()
	..()

/obj/item/card/id/synthetic
	name = "\improper Synthetic ID"
	desc = "Access module for lawed synthetics."
	icon_state = "card_robot"
	item_state = "card_id"
	assignment = "Synthetic"

/obj/item/card/id/synthetic/New()
	access = get_all_station_access() + access_synth
	..()

/obj/item/card/id/centcom
	name = "\improper CentCom. ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "card_centcom"
	item_state = "card_centcom"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/card/id/centcom/New()
	access = get_all_centcom_access()
	..()

/obj/item/card/id/centcom/station/New()
	..()
	access |= get_all_station_access()

/obj/item/card/id/centcom/ERT
	name = "\improper Emergency Response Team ID"
	assignment = "Emergency Response Team"

/obj/item/card/id/centcom/ERT/New()
	..()
	access |= get_all_station_access()

/obj/item/card/id/all_access
	name = "\improper Administrator's spare ID"
	desc = "The spare ID of the Lord of Lords himself."
	icon_state = "card_data"
	item_state = "card_data"
	registered_name = "Administrator"
	assignment = "Administrator"

/obj/item/card/id/all_access/New()
	access = get_access_ids()
	..()

// Department-flavor IDs
/obj/item/card/id/medical
	name = "identification card"
	desc = "A card issued to medical staff."
	icon_state = "card_med"
	item_state = "card_med"
	job_access_type = /datum/job/doctor

/obj/item/card/id/medical/chemist
	icon_state = "card_chem"
	job_access_type = /datum/job/chemist

/obj/item/card/id/medical/virologist
	icon_state = "card_viro"
	job_access_type = /datum/job/virologist

/obj/item/card/id/medical/psychiatrist
	icon_state = "card_psych"
	job_access_type = /datum/job/psychiatrist

/obj/item/card/id/medical/paramedic
	icon_state = "card_paramed"
	job_access_type = /datum/job/paramedic

/obj/item/card/id/medical/head
	name = "identification card"
	desc = "A card which represents care and compassion."
	icon_state = "card_cmo"
	item_state = "card_head"
	job_access_type = /datum/job/cmo

/obj/item/card/id/security
	name = "identification card"
	desc = "A card issued to security staff."
	icon_state = "card_sec"
	item_state = "card_sec"
	job_access_type = /datum/job/officer

/obj/item/card/id/security/warden
	icon_state = "card_warden"
	job_access_type = /datum/job/warden

/obj/item/card/id/security/detective
	icon_state = "card_dec"
	job_access_type = /datum/job/detective

/obj/item/card/id/security/head
	name = "identification card"
	desc = "A card which represents honor and protection."
	icon_state = "card_hos"
	item_state = "card_head"
	job_access_type = /datum/job/hos

/obj/item/card/id/engineering
	name = "identification card"
	desc = "A card issued to engineering staff."
	icon_state = "card_eng"
	item_state = "card_eng"
	job_access_type = /datum/job/engineer

/obj/item/card/id/engineering/atmos
	icon_state = "card_atmos"
	job_access_type = /datum/job/atmos

/obj/item/card/id/engineering/head
	name = "identification card"
	desc = "A card which represents creativity and ingenuity."
	icon_state = "card_ce"
	item_state = "card_head"
	job_access_type = /datum/job/chief_engineer

/obj/item/card/id/science
	name = "identification card"
	desc = "A card issued to science staff."
	icon_state = "card_sci"
	item_state = "card_sci"
	job_access_type = /datum/job/scientist

/obj/item/card/id/science/xenobiologist
	icon_state = "card_xenobio"
	job_access_type = /datum/job/xenobiologist

/obj/item/card/id/science/roboticist
	icon_state = "card_roboticist"
	job_access_type = /datum/job/roboticist

/obj/item/card/id/science/head
	name = "identification card"
	desc = "A card which represents knowledge and reasoning."
	icon_state = "card_rd"
	item_state = "card_head"
	job_access_type = /datum/job/rd

/obj/item/card/id/provisioning
	name = "identification card"
	desc = "A card issued to provisioning staff."
	icon_state = "card_civ"
	item_state = "card_civ"

/obj/item/card/id/provisioning/head
	name = "identification card"
	desc = "A card which represents service and planning."
	icon_state = "card_hop"
	item_state = "card_head"
	job_access_type = /datum/job/hop

/obj/item/card/id/provisioning/cargo
	name = "identification card"
	desc = "A card issued to cargo staff."
	icon_state = "card_cargo"
	item_state = "card_cargo"
	job_access_type = /datum/job/cargo_tech

/obj/item/card/id/provisioning/cargo/mining
	icon_state = "card_mining"
	job_access_type = /datum/job/mining

/obj/item/card/id/provisioning/bartender
	icon_state = "card_bartender"
	job_access_type = /datum/job/bartender

/obj/item/card/id/provisioning/chef
	icon_state = "card_chef"
	job_access_type = /datum/job/chef

/obj/item/card/id/provisioning/botanist
	icon_state = "card_botanist"
	job_access_type = /datum/job/hydro

/obj/item/card/id/provisioning/janitor
	icon_state = "card_janitor"
	job_access_type = /datum/job/janitor

/obj/item/card/id/civilian
	name = "identification card"
	desc = "A card issued to civilian staff."
	icon_state = "card_civ"
	item_state = "card_civ"
	job_access_type = /datum/job/assistant

/obj/item/card/id/civilian/librarian
	icon_state = "card_librarian"
	job_access_type = /datum/job/librarian

/obj/item/card/id/civilian/internal_affairs_agent
	icon_state = "card_iaa"
	job_access_type = /datum/job/iaa

/obj/item/card/id/civilian/lawyer
	icon_state = "card_lawyer"
	job_access_type = /datum/job/lawyer

/obj/item/card/id/civilian/chaplain
	icon_state = "card_chaplain"
	job_access_type = /datum/job/chaplain

/obj/item/card/id/civilian/clown
	desc = "A card issued to... Wait, what?!"
	icon_state = "card_clown"
	item_state = "card_clown"
	job_access_type = /datum/job/clown

/obj/item/card/id/civilian/clown/gold //Use me in the name of Honkmother
	icon_state = "card_clownGold"
	item_state = "card_clownGold"
	job_access_type = null

/obj/item/card/id/civilian/clown/gold/New()
	access = get_all_station_access()
	..()

/obj/item/card/id/civilian/mime
	desc = "A card issued to..."
	icon_state = "card_mime"
	item_state = "card_mime"
	job_access_type = /datum/job/mime

/obj/item/card/id/civilian/mime/gold //...
	icon_state = "card_mimeGold"
	item_state = "card_mimeGold"
	job_access_type = null

/obj/item/card/id/civilian/mime/gold/New()
	access = get_all_station_access()
	..()

/obj/item/card/id/civilian/barmonkey
	desc = "A card issued to a monkey. Aboard a space station."
	icon_state = "card_monkey"
	item_state = "card_id"
	job_access_type = /datum/job/barmonkey

/obj/item/card/id/civilian/head //This is not the HoP. There's no position that uses this right now.
	name = "identification card"
	desc = "A card which represents common sense and responsibility."
	icon_state = "card_civGold"
	item_state = "card_head"

/obj/item/card/id/merchant
	name = "identification card"
	desc = "A card issued to Merchants, indicating their right to sell and buy goods."
	icon_state = "card_trader"
	item_state = "card_trader"
	access = list(access_merchant)
