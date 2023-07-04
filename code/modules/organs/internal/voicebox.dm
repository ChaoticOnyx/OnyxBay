/obj/item/organ/internal/voicebox
	status = ORGAN_ROBOTIC
	name = "vocal synthesiser"
	icon = 'icons/mob/human_races/organs/cyber.dmi'
	icon_state = "voicebox"
	parent_organ = BP_CHEST
	organ_tag = BP_VOICE
	will_assist_languages = list(LANGUAGE_GALCOM, LANGUAGE_LUNAR, LANGUAGE_GUTTER, LANGUAGE_SOL_COMMON, LANGUAGE_EAL, LANGUAGE_INDEPENDENT, LANGUAGE_SPACER)

/obj/item/organ/internal/voicebox/New()
	for(var/L in will_assist_languages)
		assists_languages += all_languages[L]
	robotize()
