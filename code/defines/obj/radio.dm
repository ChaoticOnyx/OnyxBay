/obj/item/device/radio
	name = "handheld radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var/last_transmission
	var/frequency = 1459
	var/traitor_frequency = 0.0
	var/security_frequency = 0.0
	var/obj/item/device/radio/patch_link = null
	var/obj/item/device/uplink/radio/traitorradio = null
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	var/b_stat = 0.0
	var/broadcasting = null
	var/listening = 1.0
	flags = 450.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 5 // only 2/second/radio

/obj/item/device/radio/beacon
	name = "Tracking Beacon"
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"

/obj/item/device/radio/electropack
	name = "Electropack"
	icon_state = "electropack0"
	var/code = 2.0
	var/on = 0.0
	var/e_pads = 0.0
	frequency = 1449
	w_class = 5.0
	flags = 323.0
	item_state = "electropack"

/obj/item/device/radio/headset
	name = "Radio Headset"
	desc = "Headset for use in communication with the rest of the ship. (Use say ; to talk into headset when worn.)"
	icon_state = "headset"
	item_state = "headset"
	var/protective_temperature = 0

/obj/item/device/radio/headset/security
	name = "Security Headset"
	desc = "Headset which uses an additional frequency for secure transmissions. (Use say :h to transmit on secure channel.)"
	icon_state = "security_headset"
	item_state = "security_headset"
	security_frequency = 1399
/obj/item/device/radio/headset/security/engineer
	name = "Engineering Headset"
	desc = "Headset which uses an additional frequency for secure transmissions. (Use say :h to transmit on secure channel.)"
	icon_state = "engi_headset"
	item_state = "headset"
	security_frequency = 1400
/obj/item/device/radio/headset/security/medical
	name = "Medical Headset"
	desc = "Headset which uses an additional frequency for secure transmissions. (Use say :h to transmit on secure channel.)"
	icon_state = "med_headset"
	item_state = "headset"
	security_frequency = 1401
/obj/item/device/radio/intercom
	name = "Ship Intercom (Radio)"
	icon_state = "intercom"
	anchored = 1.0
	var/number = 0
