/obj/item/weapon/melee/prosthetic/
	var/prost_type = "prosthetic"
	var/obj/item/organ/external/parent_hand
	canremove = FALSE

/obj/item/weapon/melee/prosthetic/New(atom/location, obj/item/organ/external/limb)
	attach_prosthetic(src,limb)

/obj/proc/attach_prosthetic(prosthetic , organ)
	if(!prosthetic || !organ || !isProsthetic(prosthetic))
		return FALSE
	if(istype(prosthetic,/obj/item/weapon/melee/prosthetic))
		var/obj/item/weapon/melee/prosthetic/P = prosthetic
		var/obj/item/organ/external/O = organ

		switch(O.organ_tag)
			if(BP_L_HAND)
				if(O.owner.l_hand)
					return FALSE
				O.owner.put_in_l_hand(P)
			if(BP_R_HAND)
				if(O.owner.r_hand)
					return FALSE
				O.owner.put_in_r_hand(P)

		O.status = ORGAN_ROBOTIC
		P.parent_hand = organ
	return TRUE

/obj/proc/remove_prosthetic(prosthetic = src)
	if(istype(prosthetic,/obj/item/weapon/melee/prosthetic))
		var/obj/item/weapon/melee/prosthetic/P = prosthetic
		P.parent_hand = null
		P.canremove = TRUE

/proc/isProsthetic(A)
	if(A)
		if(istype(A,/obj/item/weapon/melee/prosthetic))
			return TRUE
	return FALSE

/obj/item/weapon/melee/prosthetic/attack_self(mob/user)
	if(parent_hand)
		..()
	else
		to_chat(user, SPAN("notice", "[capitalize(prost_type)] needs to be surgicaly applied first."))

/obj/item/weapon/melee/prosthetic/attackby(obj/item/I, mob/user)
	if(parent_hand)
		..()
	else
		to_chat(user, SPAN("notice", "[capitalize(prost_type)] needs to be surgicaly applied first."))

/obj/item/weapon/melee/prosthetic/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(parent_hand)
		..()
	else
		to_chat(user, SPAN("notice", "[capitalize(prost_type)] needs to be surgicaly applied first."))

/obj/item/weapon/melee/prosthetic/bio/
	prost_type = "bioprosthetic"

/obj/item/weapon/melee/prosthetic/bio/attach_prosthetic(prosthetic, organ)
	if(!prosthetic || !organ || !isProsthetic(prosthetic))
		return FALSE
	if(istype(prosthetic, /obj/item/weapon/melee/prosthetic))
		var/obj/item/weapon/melee/prosthetic/P = prosthetic
		var/obj/item/organ/external/O = organ

		switch(O.organ_tag)
			if(BP_L_HAND)
				if(O.owner.l_hand)
					return FALSE
				O.owner.put_in_l_hand(P)
			if(BP_R_HAND)
				if(O.owner.r_hand)
					return FALSE
				O.owner.put_in_r_hand(P)

		P.parent_hand = organ
	return TRUE
