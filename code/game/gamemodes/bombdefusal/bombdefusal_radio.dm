// ========== BOMB DEFUSAL - TEAM RADIO ==========

// Terrorist headset - uses Syndicate frequency
/obj/item/device/radio/headset/bombdefusal_t
	name = "terrorist radio headset"
	desc = "A radio headset tuned to the terrorist team frequency."
	icon_state = "headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/bombdefusal_t

// Counter-Terrorist headset - uses Security frequency
/obj/item/device/radio/headset/bombdefusal_ct
	name = "counter-terrorist radio headset"
	desc = "A radio headset tuned to the counter-terrorist team frequency."
	icon_state = "headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/bombdefusal_ct

// Encryption keys - use existing registered channels
/obj/item/device/encryptionkey/bombdefusal_t
	name = "terrorist encryption key"
	icon_state = "cypherkey"
	channels = list("Syndicate" = 1)

/obj/item/device/encryptionkey/bombdefusal_ct
	name = "counter-terrorist encryption key"
	icon_state = "cypherkey"
	channels = list("Security" = 1)
