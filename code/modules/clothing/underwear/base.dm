/obj/item/underwear
	w_class = ITEM_SIZE_TINY
	icon = 'icons/inv_slots/hidden/icon.dmi'
	var/required_slot_flags
	var/required_free_body_parts

/obj/item/underwear/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return // Might as well check
	DelayedEquipUnderwear(user, target)

/obj/item/underwear/MouseDrop(atom/target)
	DelayedEquipUnderwear(usr, target)

/obj/item/underwear/proc/CanEquipUnderwear(mob/user, mob/living/carbon/human/H)
	if(!CanAdjustUnderwear(user, H, "put on"))
		return FALSE
	if(!(H.species && (H.species.species_appearance_flags & HAS_UNDERWEAR)))
		to_chat(user, "<span class='warning'>\The [H]'s species cannot wear underwear of this nature.</span>")
		return FALSE
	if(is_path_in_list(type, H.worn_underwear))
		to_chat(user, "<span class='warning'>\The [H] is already wearing underwear of this nature.</span>")
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
	return ForceEquipUnderwear(H, user)

/obj/item/underwear/proc/ForceEquipUnderwear(mob/living/carbon/human/H, mob/user, update_icons = TRUE)
	// No matter how forceful, we still don't allow multiples of the same underwear type
	if(is_path_in_list(type, H.worn_underwear))
		return FALSE

	if(isnull(user))
		forceMove(H)
		_add_verb_to_stat(H, /obj/item/underwear/verb/RemoveSocks)
	else if(!user.drop(src, H, changing_slots = H == user))
		return FALSE

	H.worn_underwear += src

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

/obj/item/underwear/top
	required_free_body_parts = UPPER_TORSO

/obj/item/underwear/bottom
	required_free_body_parts = FEET|LEGS|LOWER_TORSO

/obj/item/underwear/undershirt
	required_free_body_parts = UPPER_TORSO

/obj/item/underwear/wrist
	required_free_body_parts = NO_BODYPARTS
	icon = 'icons/obj/clothing/wrist.dmi'
	/// Can use different wear layers to be drawn over/under uniform.
	var/mob_wear_layer = HO_WRISTS_UNDER_LAYER
	/// Some children of this type can be flipped (left/right wrist). -1 means it cannot be flipped at all.
	var/flipped = -1

/obj/item/underwear/wrist/Initialize()
	. = ..()
	if(flipped != -1)
		verbs += /obj/item/underwear/wrist/proc/swapwrists

/obj/item/underwear/wrist/proc/swapwrists()
	set name = "Flip Wristwear"
	set category = "Object"

	flipped = !flipped
	icon_state = "[initial(item_state)][flipped ? "_flip" : ""]"
	to_chat(usr, "You change \the [src] to be on your [src.flipped ? "left" : "right"] wrist.")
	if(pickup_sound)
		play_handling_sound(slot_r_hand)
	else
		play_drop_sound()

	var/mob/living/carbon/human/H = usr
	H?.update_underwear()

/mob/living/carbon/human/verb/wristwear_layer()
	set name = "Change Wristwear Layer"
	set category = "IC"

	change_wristwear_layer()

/mob/living/carbon/human/proc/change_wristwear_layer()
	var/list/underwear_list = list()
	for(var/obj/item/underwear/wrist/W in worn_underwear)
		underwear_list |= W

	if(length(underwear_list) < 1)
		return

	var/obj/item/underwear/wrist/choice = null
	if(length(underwear_list) == 1)
		choice = underwear_list[1]
	else
		choice = tgui_input_list(usr, "Position Wristwear", "Select Wristwear", underwear_list)

	var/list/options = list("Under Uniform" = HO_WRISTS_UNDER_LAYER, "Over Uniform" = HO_WRIST_UNIFORM_LAYER, "Over Suit" = HO_WRISTS_OVER_LAYER)
	var/new_layer = tgui_input_list(usr, "Position Wristwear", "Wristwear Style", options)
	if(new_layer)
		choice.mob_wear_layer = options[new_layer]
		to_chat(usr, SPAN_NOTICE("\The [src] will now layer [new_layer]."))
		var/mob/living/carbon/human/H = usr
		H?.update_underwear()

/obj/item/underwear/wrist/watch
	name = "watch"
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in black plastic."
	icon_state = "watch"
	item_state = "watch"
	flipped = FALSE

/obj/item/underwear/wrist/watch/silver
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in silver."
	icon_state = "watch_silver"
	item_state = "watch_silver"

/obj/item/underwear/wrist/watch/gold
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in <b>REAL</b> faux gold."
	icon_state = "watch_gold"
	item_state = "watch_gold"

/obj/item/underwear/wrist/watch/holo
	desc = "It's a GaussIo ZeitMeister with a holographic screen."
	icon_state = "watch_holo"
	item_state = "watch_holo"

/obj/item/underwear/wrist/watch/leather
	desc = "It's a GaussIo ZeitMeister, a finely tuned wristwatch encased in leather."
	icon_state = "watch_leather"
	item_state = "watch_leather"

/obj/item/underwear/wrist/watch/spy
	desc = "It's a GENUINE Spy-Tech Invisi-watch! <b>WARNING</b> : Does not actually make you invisible."
	icon_state = "watch_spy"
	item_state = "watch_silver"

/obj/item/underwear/wrist/watch/nerdy
	desc = "It's a GENUINE Spy-Tech Invisi-watch! <b>WARNING</b> : Does not actually make you invisible."
	icon_state = "nerdy"
	item_state = "watch_leather"

/obj/item/underwear/wrist/watch/magnitka
	desc = "It's a GENUINE Spy-Tech Invisi-watch! <b>WARNING</b> : Does not actually make you invisible."
	icon_state = "magnitka"
	item_state = "elite-true"

/obj/item/underwear/wrist/watch/normal
	desc = "It's a GENUINE Spy-Tech Invisi-watch! <b>WARNING</b> : Does not actually make you invisible."
	icon_state = "normal"
	item_state = "watch"

/obj/item/underwear/wrist/watch/elite
	desc = "It's a GENUINE Spy-Tech Invisi-watch! <b>WARNING</b> : Does not actually make you invisible."
	icon_state = "elite-black"
	item_state = "elite-black"

/obj/item/underwear/wrist/watch/elite/gold
	icon_state = "elite-gold"
	item_state = "elite-gold"

/obj/item/underwear/wrist/watch/elite/true
	icon_state = "elite-true"
	item_state = "elite-true"

/obj/item/underwear/wrist/bracelet
	name = "bracelet"
	desc = "Made out of some synthetic polymer. Management encourages you to not ask questions."
	icon_state = "bracelet"
	item_state = "bracelet"
	flipped = FALSE

/obj/item/underwear/wrist/beaded
	name = "beaded bracelet"
	desc = "Made from loose beads with a center hole and connected by a piece of string or elastic band through said holes."
	icon_state = "beaded"
	item_state = "beaded"
	flipped = FALSE

/obj/item/underwear/wrist/slap
	name = "slap bracelet"
	desc = "Banned in schools! Popular with children and in poorly managed corporate events!"
	icon_state = "slap"
	item_state = "slap"
	flipped = FALSE
/obj/item/underwear/wrist/armchain
	name = "cobalt arm chains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with cobalt-blue gems, and made of <b>REAL</b> faux gold."
	icon_state = "cobalt_armchains"
	item_state = "cobalt_armchains"
	gender = PLURAL

/obj/item/underwear/wrist/armchain/emerald
	name = "emerald arm chains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with emerald-green gems, and made of <b>REAL</b> faux gold."
	icon_state = "emerald_armchains"
	item_state = "emerald_armchains"

/obj/item/underwear/wrist/armchain/ruby
	name = "ruby arm chains"
	desc = "A set of luxurious chains intended to be wrapped around long, lanky arms. They don't seem particularly comfortable. They're encrusted with ruby-red gems, and made of <b>REAL</b> faux gold."
	icon_state = "ruby_armchains"
	item_state = "ruby_armchains"

/obj/item/underwear/wrist/goldbracer
	name = "cobalt bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with cobalt-blue gems, and made of <b>REAL</b> faux gold."
	icon_state = "cobalt_bracers"
	item_state = "cobalt_bracers"
	gender = PLURAL

/obj/item/underwear/wrist/goldbracer/emerald
	name = "emerald bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with emerald-green gems, and made of <b>REAL</b> faux gold."
	icon_state = "emerald_bracers"
	item_state = "emerald_bracers"

/obj/item/underwear/wrist/goldbracer/ruby
	name = "ruby bracers"
	desc = "A pair of sturdy and thick decorative bracers, seeming better for fashion than protection. They're encrusted with ruby-red gems, and made of <b>REAL</b> faux gold."
	icon_state = "ruby_bracers"
	item_state = "ruby_bracers"
