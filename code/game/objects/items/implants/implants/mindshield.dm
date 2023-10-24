/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing and propaganda.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing and propaganda.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/implant/mindshield/implanted(mob/M)
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	var/datum/antagonist/antag_data = get_antag_data(H.mind.special_role)

	if(antag_data && (antag_data.flags & ANTAG_IMPLANT_IMMUNE))
		H.visible_message("[H] seems to resist the implant!", "You feel the corporate tendrils of [GLOB.using_map.company_name] try to invade your mind!")
		return FALSE

	if(prob(50))
		H.visible_message("[H] suddenly goes very red and starts writhing. There is a strange smell in the air...", \
		"<span class='userdanger'>Suddenly the horrible pain strikes your body! Your mind is in complete disorder! Blood pulses and starts burning! The pain is impossible!!!</span>")
		H.adjustBrainLoss(80)

	return TRUE

/obj/item/implanter/mindshield
	name = "implanter-mindshield"
	imp = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "glass case - 'loyalty'"
	imp = /obj/item/implant/mindshield
