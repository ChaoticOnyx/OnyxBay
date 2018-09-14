/obj/item/weapon/melee/prosthetic/
	var/prost_type = "prosthetic"
	var/obj/item/organ/external/parent_hand
	canremove = 0
	candrop = 0

/obj/item/weapon/melee/prosthetic/New(var/atom/location, var/obj/item/organ/external/limb)
	attach_prosthetic(src,limb)

/obj/proc/attach_prosthetic(var/prosthetic , var/organ)
	if (!prosthetic || !organ || !isProsthetic(prosthetic))
		return 0
	if (istype(prosthetic,/obj/item/weapon/melee/prosthetic))
		var/obj/item/weapon/melee/prosthetic/P = prosthetic
		var/obj/item/organ/external/O = organ

		switch(O.organ_tag)
			if(BP_L_HAND)
				if (O.owner.l_hand)
					return 0
				O.owner.put_in_l_hand(P)
			if(BP_R_HAND)
				if (O.owner.r_hand)
					return 0
				O.owner.put_in_r_hand(P)

		O.cannot_amputate = 1
		O.no_pain = 1
		P.parent_hand = organ
	return 1

/obj/proc/remove_prosthetic(var/prosthetic = src)
	if (istype(prosthetic,/obj/item/weapon/melee/prosthetic))
		var/obj/item/weapon/melee/prosthetic/P = prosthetic
		P.parent_hand = null
		P.candrop = 1
		P.canremove = 1

/proc/isProsthetic(A)
	if (A)
		if (istype(A,/obj/item/weapon/melee/prosthetic))
			return 1
	return 0

/obj/item/weapon/melee/prosthetic/attack_self(var/mob/user)
	if (parent_hand)
		..()
	else
		to_chat(user, "<span class='notice'>[capitalize(prost_type)] needs to be surgicaly applied first.</span>")

/obj/item/weapon/melee/prosthetic/attackby(var/obj/item/I, var/mob/user)
	if (parent_hand)
		..()
	else
		to_chat(user, "<span class='notice'>[capitalize(prost_type)] needs to be surgicaly applied first.</span>")

/obj/item/weapon/melee/prosthetic/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if (parent_hand)
		..()
	else
		to_chat(user, "<span class='notice'>[capitalize(prost_type)] needs to be surgicaly applied first.</span>")

/obj/item/weapon/melee/prosthetic/bio/
	prost_type = "bioprosthetic"