/obj/item/organ/internal/heart/gland/transform
	abductor_hint = "anthropmorphic transmorphosizer. The abductee will occasionally change appearance and species."
	cooldown_low = 900
	cooldown_high = 1800
	uses = -1
	human_only = TRUE
	icon_state = "species"
	mind_control_uses = 7
	mind_control_duration = 300

/obj/item/organ/internal/heart/gland/transform/activate()
	to_chat(owner, SPAN_NOTICE("You feel unlike yourself."))
	for(var/i=1 to owner.dna.UI.len)
		owner.dna.SetUIValue(i,rand(1,4095))
	domutcheck(owner, null)
	owner.UpdateAppearance()
