/obj/item/organ_module/active/health_scanner
	name = "integrated health scanner"
	action_button_name = "Activate Health Scanner"
	icon_state = "iatric_monitor"
	cooldown = 8
	allowed_organs = list(BP_L_HAND, BP_R_HAND)
	loadout_cost = 10

/obj/item/organ_module/active/health_scanner/activate(obj/item/organ/E, mob/living/carbon/human/H)
	show_browser(H, medical_scan_results(H, TRUE), "window=scanconsole;size=430x350")
	H.playsound_local(null, 'sound/machines/triple_beep.ogg', 20)
