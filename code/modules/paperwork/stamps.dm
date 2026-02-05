/obj/item/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp-qm"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 15
	matter = list(MATERIAL_STEEL = 60)
	attack_verb = list("stamped")

/obj/item/stamp/attack(mob/living/M, mob/living/user, target_zone)
	if(user.a_intent == I_HURT && target_zone == BP_HEAD)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head/head = H.get_organ(BP_HEAD)
			if(istype(head))
				head.apply_stamp(name, user)
				return TRUE
			else
				to_chat(user, "<span class = 'notice'>You can't stamp on that!</span>")
				return FALSE
	return ..()

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_state = "stamp-cap"

/obj/item/stamp/hop
	name = "head of provisioning's rubber stamp"
	icon_state = "stamp-hop"
	item_state = "stamp-hop"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_state = "stamp-hos"

/obj/item/stamp/ward
	name = "warden's rubber stamp"
	icon_state = "stamp-ward"
	item_state = "stamp-ward"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_state = "stamp-ce"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_state = "stamp-rd"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_state = "stamp-cmo"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_state = "stamp-deny"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_state = "stamp-clown"

/obj/item/stamp/internalaffairs
	name = "internal affairs rubber stamp"
	icon_state = "stamp-intaff"
	item_state = "stamp-intaff"

/obj/item/stamp/centcomm
	name = "centcomm rubber stamp"
	icon_state = "stamp-cent"
	item_state = "stamp-cent"

/obj/item/stamp/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_state = "stamp-qm"

/obj/item/stamp/cargo
	name = "cargo rubber stamp"
	icon_state = "stamp-cargo"
	item_state = "stamp-cargo"

/obj/item/stamp/ok
	name = "\improper APPROVED rubber stamp"
	icon_state = "stamp-ok"
	item_state = "stamp-ok"

/obj/item/stamp/syndicate
	name = "\improper 'criminal' rubber stamp"
	icon_state = "stamp-syndicate"
	item_state = "stamp-syndicate"

/obj/item/stamp/void
	name = "void rubber stamp"
	icon_state = "stamp-void"
	item_state = "stamp-void"

/obj/item/stamp/mime
	name = "mime rubber stamp"
	icon_state = "stamp-mime"
	item_state = "stamp-mime"

/obj/item/stamp/law
	name = "law rubber stamp"
	icon_state = "stamp-law"
	item_state = "stamp-law"

/obj/item/stamp/chapel
	name = "chapel rubber stamp"
	icon_state = "stamp-chap"
	item_state = "stamp-chap"

/obj/item/stamp/merchant
	name = "merchant rubber stamp"
	icon_state = "stamp-merchant"
	item_state = "stamp-merchant"

/obj/item/stamp/ntd
	name = "nanotrasen trading department rubber stamp"
	icon_state = "stamp-ntd"
	item_state = "stamp-ntd"

// Syndicate stamp to forge documents.
/obj/item/stamp/chameleon/attack_self(mob/user as mob)

	var/list/stamp_types = typesof(/obj/item/stamp) - src.type // Get all stamp types except our own
	var/list/stamps = list()

	// Generate them into a list
	for(var/stamp_type in stamp_types)
		var/obj/item/stamp/S = new stamp_type
		stamps[capitalize(S.name)] = S

	var/list/show_stamps = list("EXIT" = null) + sortList(stamps) // the list that will be shown to the user to pick from

	var/input_stamp = input(user, "Choose a stamp to disguise as.", "Choose a stamp.") in show_stamps

	if(user && (src in user.contents))

		var/obj/item/stamp/chosen_stamp = stamps[capitalize(input_stamp)]

		if(chosen_stamp)
			SetName(chosen_stamp.name)
			icon_state = chosen_stamp.icon_state
