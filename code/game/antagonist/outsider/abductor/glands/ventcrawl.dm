/obj/item/organ/internal/heart/gland/ventcrawling
	abductor_hint = "pliant cartilage enabler. The abductee can crawl through vents without trouble."
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/ventcrawling/activate()
	to_chat(owner, SPAN_NOTICE("You feel very stretchy."))
	owner.verbs += /mob/living/proc/ventcrawl
