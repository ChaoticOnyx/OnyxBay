/obj/item/implant/uplink
	name = "uplink"
	desc = "Summon things."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_ILLEGAL = 3)

/obj/item/implant/uplink/implanted(mob/source, amount)
	AddComponent(/datum/component/uplink, source?.mind, FALSE, FALSE, null, amount || IMPLANT_TELECRYSTAL_AMOUNT(DEFAULT_TELECRYSTAL_AMOUNT))
	var/datum/component/uplink/U = get_component(/datum/component/uplink)
	var/emote_options = list("blink", "blink_r", "eyebrow", "chuckle", "twitch_v", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	U?.unlock_emote = source.client ? (tgui_input_list(source, "Choose activation emote:", "Uplink Implant Setup", emote_options)) : emote_options[1]
	source.mind.store_memory("Uplink implant can be activated by using the [U?.unlock_emote] emote, <B>say *[U?.unlock_emote]</B> to attempt to activate.", 0, 0)
	to_chat(source, "The implanted uplink implant can be activated by using the [U?.unlock_emote] emote, <B>say *[U?.unlock_emote]</B> to attempt to activate.")

	return TRUE

/obj/item/implant/uplink/trigger(emote, mob/source)
	var/datum/component/uplink/U = get_component(/datum/component/uplink)
	if(!istype(U) || usr != source)
		return

	if(U.unlock_emote == emote)
		U.interact(source)
/obj/item/implanter/uplink
	name = "implanter (U)"
	imp = /obj/item/implant/uplink
