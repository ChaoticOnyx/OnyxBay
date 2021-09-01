/mob
	var/list/default_emotes = list()
	var/list/usable_emotes = list()

/mob/proc/update_emotes(skip_sort)
	usable_emotes.Cut()
	for(var/emote in default_emotes)
		var/decl/emote/emote_datum = decls_repository.get_decl(emote)
		if(emote_datum.check_user(src))
			usable_emotes[emote_datum.key] = emote_datum
	if(!skip_sort)
		usable_emotes = sortAssoc(usable_emotes)

/mob/Initialize()
	. = ..()
	update_emotes()

// Specific defines follow.
/mob/living/carbon/alien
	default_emotes = list(
		/decl/emote/visible,
		/decl/emote/visible/scratch,
		/decl/emote/visible/drool,
		/decl/emote/visible/nod,
		/decl/emote/visible/sway,
		/decl/emote/visible/sulk,
		/decl/emote/visible/twitch,
		/decl/emote/visible/dance,
		/decl/emote/visible/roll,
		/decl/emote/visible/shake,
		/decl/emote/visible/jump,
		/decl/emote/visible/hiss,
		/decl/emote/visible/shiver,
		/decl/emote/visible/collapse,
		/decl/emote/audible,
		/decl/emote/audible/deathgasp_alien,
		/decl/emote/audible/whimper,
		/decl/emote/audible/gasp,
		/decl/emote/audible/scretch,
		/decl/emote/audible/choke,
		/decl/emote/audible/moan,
		/decl/emote/audible/gnarl,
		/decl/emote/audible/chirp
		)

/mob/living/carbon/brain/can_emote()
	return (istype(container, /obj/item/device/mmi) && ..())

/mob/living/carbon/brain
	default_emotes = list(
		/decl/emote/audible/alarm,
		/decl/emote/audible/alert,
		/decl/emote/audible/notice,
		/decl/emote/audible/whistle,
		/decl/emote/audible/synth,
		/decl/emote/audible/boop,
		/decl/emote/visible/blink,
		/decl/emote/visible/flash
		)

/mob/living/carbon/human
	default_emotes = list(
		/decl/emote/human/deathgasp,
		/decl/emote/visible/drool,
		/decl/emote/visible/point,
		/decl/emote/human,
		/decl/emote/visible/twitch,
		/decl/emote/visible/twitch_v,
	)

/mob/living/silicon/robot
	default_emotes = list(
		/decl/emote/visible/twitch,
		/decl/emote/visible/twitch_v,
		/decl/emote/visible/deathgasp_robot,
		/decl/emote/audible/synth,
		/decl/emote/audible/synth/ping,
		/decl/emote/audible/synth/buzz,
		/decl/emote/audible/synth/confirm,
		/decl/emote/audible/synth/deny,
		/decl/emote/audible/synth/security,
		/decl/emote/audible/synth/security/halt
		)

/mob/living/carbon/metroid
	default_emotes = list(
		/decl/emote/audible/moan,
		/decl/emote/visible/twitch,
		/decl/emote/visible/sway,
		/decl/emote/visible/shiver,
		/decl/emote/visible/bounce,
		/decl/emote/visible/jiggle,
		/decl/emote/visible/lightup,
		/decl/emote/visible/vibrate,
		/decl/emote/metroid,
		/decl/emote/metroid/pout,
		/decl/emote/metroid/sad,
		/decl/emote/metroid/angry,
		/decl/emote/metroid/frown,
		/decl/emote/metroid/smile
		)
