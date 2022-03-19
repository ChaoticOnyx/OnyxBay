/obj/item/organ/internal/heart/gland/access
	abductor_hint = "anagraphic electro-scrambler. After it activates, grants the abductee intrinsic all access."
	cooldown_low = 600
	cooldown_high = 1200
	uses = 1
	icon_state = "mindshock"
	mind_control_uses = 3
	mind_control_duration = 900
	var/list/access

/obj/item/organ/internal/heart/gland/access/activate()
	to_chat(owner, SPAN_NOTICE(FONT_LARGE("You feel like a VIP for some reason.")))
	access = get_all_station_access()

/obj/item/organ/internal/heart/gland/access/GetAccess()
	return access
