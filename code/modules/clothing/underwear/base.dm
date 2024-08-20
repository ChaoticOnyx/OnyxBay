
#define UNDERWEAR_SLOT_FREE       0
#define UNDERWEAR_SLOT_SOCKS      0x1
#define UNDERWEAR_SLOT_TOP        0x2
#define UNDERWEAR_SLOT_BOTTOM     0x4
#define UNDERWEAR_SLOT_UNDERSHIRT 0x8
#define UNDERWEAR_SLOT_L_WRIST    0x10
#define UNDERWEAR_SLOT_R_WRIST    0x20
#define UNDERWEAR_SLOT_NECK       0x40
#define UNDERWEAR_SLOT_WRISTS     (UNDERWEAR_SLOT_L_WRIST|UNDERWEAR_SLOT_R_WRIST)

/obj/item/underwear
	w_class = ITEM_SIZE_TINY
	icon = 'icons/inv_slots/hidden/icon.dmi'
	var/required_slot_flags
	var/required_free_body_parts
	var/mob_wear_layer = HO_UNDERWEAR_LAYER
	var/underwear_slot = UNDERWEAR_SLOT_FREE

/obj/item/underwear/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return // Might as well check
	DelayedEquipUnderwear(user, target)

/obj/item/underwear/MouseDrop(atom/target)
	DelayedEquipUnderwear(usr, target)

/obj/item/underwear/proc/CanEquipUnderwear(mob/user, mob/living/carbon/human/H, silent = FALSE)
	if(!CanAdjustUnderwear(user, H, "put on"))
		return FALSE
	if(!(H.species && (H.species.species_appearance_flags & HAS_UNDERWEAR)))
		if(!silent)
			to_chat(user, SPAN("warning", "\The [H]'s species cannot wear underwear of this nature."))
		return FALSE

	for(var/obj/item/underwear/UW in H.worn_underwear)
		if(!UW.underwear_slot) // Yay, boundless underwear!
			if(UW.type == type) // ...but dare you not wear multiple instances of the same item.
				if(!silent)
					if(user == H)
						to_chat(user, SPAN("warning", "You are already wearing underwear of this nature."))
					else
						to_chat(user, SPAN("warning", "\The [H] is already wearing underwear of this nature."))
				return FALSE

			continue

		else if(UW.underwear_slot & underwear_slot)
			if(!silent)
				if(user == H)
					to_chat(user, SPAN("warning", "You are already wearing underwear of this nature."))
				else
					to_chat(user, SPAN("warning", "\The [H] is already wearing underwear of this nature."))
			return FALSE

	return TRUE

/obj/item/underwear/proc/CanRemoveUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanAdjustUnderwear(user, H, "remove"))
		return FALSE
	if(!(src in H.worn_underwear))
		to_chat(user, "<span class='warning'>\The [H] isn't wearing \the [src].</span>")
		return FALSE
	return TRUE

/obj/item/underwear/proc/CanAdjustUnderwear(mob/user, mob/living/carbon/human/H, adjustment_verb)
	if(!istype(H))
		return FALSE
	if(user != H && !CanPhysicallyInteractWith(user, H))
		return FALSE

	var/list/covering_items = H.get_covering_equipped_items(required_free_body_parts)
	if(covering_items.len)
		var/obj/item/I = covering_items[1]
		var/datum/gender/G = gender_datums[I.gender]
		if(adjustment_verb)
			to_chat(user, "<span class='warning'>Cannot [adjustment_verb] \the [src]. [english_list(covering_items)] [covering_items.len == 1 ? G.is : "are"] in the way.</span>")
		return FALSE

	return TRUE

/obj/item/underwear/proc/DelayedRemoveUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanRemoveUnderwear(user, H))
		return
	if(user != H)
		visible_message("<span class='danger'>\The [user] is trying to remove \the [H]'s [name]!</span>")
		if(!do_after(user, HUMAN_STRIP_DELAY, H))
			return FALSE
	. = RemoveUnderwear(user, H)
	if(. && user != H)
		user.visible_message("<span class='warning'>\The [user] has removed \the [src] from \the [H].</span>", "<span class='notice'>You have removed \the [src] from \the [H].</span>")
		admin_attack_log(user, H, "Removed \a [src]", "Had \a [src] removed.", "removed \a [src] from")

/obj/item/underwear/proc/DelayedEquipUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanEquipUnderwear(user, H))
		return
	if(user != H)
		user.visible_message("<span class='warning'>\The [user] has begun putting on \a [src] on \the [H].</span>", "<span class='notice'>You begin putting on \the [src] on \the [H].</span>")
		if(!do_after(user, HUMAN_STRIP_DELAY, H))
			return FALSE
	. = EquipUnderwear(user, H)
	if(. && user != H)
		user.visible_message("<span class='warning'>\The [user] has put \the [src] on \the [H].</span>", "<span class='notice'>You have put \the [src] on \the [H].</span>")
		admin_attack_log(user, H, "Put on \a [src]", "Had \a [src] put on.", "put on \a [src] on")

/obj/item/underwear/proc/EquipUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanEquipUnderwear(user, H))
		return FALSE
	if(!user.drop(src))
		return FALSE
	return ForceEquipUnderwear(H)

/obj/item/underwear/proc/ForceEquipUnderwear(mob/living/carbon/human/H, update_icons = TRUE)
	// No matter how forceful, we still don't allow multiples of the same underwear type
	for(var/obj/item/underwear/UW in H.worn_underwear)
		if(!UW.underwear_slot) // Yay, boundless underwear!
			if(UW.type == type) // ...but dare you not wear multiple instances of the same item.
				return FALSE
			continue
		else if(UW.underwear_slot & underwear_slot)
			return FALSE

	H.worn_underwear += src
	forceMove(H)

	if(update_icons)
		H.update_underwear()

	return TRUE

/obj/item/underwear/proc/RemoveUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanRemoveUnderwear(user, H))
		return FALSE

	H.worn_underwear -= src
	user.pick_or_drop(src)
	H.update_underwear()

	return TRUE

/obj/item/underwear/verb/RemoveSocks()
	set name = "Remove Underwear"
	set category = "Object"
	set src in usr

	RemoveUnderwear(usr, usr)

/obj/item/underwear/socks
	required_free_body_parts = FEET
	underwear_slot = UNDERWEAR_SLOT_SOCKS

/obj/item/underwear/top
	required_free_body_parts = UPPER_TORSO
	underwear_slot = UNDERWEAR_SLOT_TOP

/obj/item/underwear/bottom
	required_free_body_parts = FEET|LEGS|LOWER_TORSO
	underwear_slot = UNDERWEAR_SLOT_BOTTOM

/obj/item/underwear/undershirt
	required_free_body_parts = UPPER_TORSO
	underwear_slot = UNDERWEAR_SLOT_UNDERSHIRT
