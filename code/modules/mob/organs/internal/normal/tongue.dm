/obj/item/organ/internal/tongue
	name = "tongue"
	desc = "A bumpy muscle. A cat must've gotten it."
	icon_state = "tongue"
	dead_icon = "tongue"
	organ_tag = BP_TONGUE
	parent_organ = BP_HEAD
	relative_size = 10
	max_damage = 45

/obj/item/organ/internal/tongue/robotize()
	..()
	SetName("lingual implant")
	icon_state = "voicebox"
	dead_icon = "voicebox"

/obj/item/organ/internal/tongue/take_internal_damage(amount, silent = FALSE, is_traumatic = FALSE)
	var/oldbroken = is_broken()
	var/oldbruised = is_bruised()
	. = ..()
	if(owner && !owner.stat)
		if(!oldbroken && is_broken())
			to_chat(owner, SPAN("danger", "You can't feel your tongue!"))
		else if(!oldbruised && is_bruised())
			to_chat(owner, SPAN("danger", "Your tongue feels numb and bruised."))
