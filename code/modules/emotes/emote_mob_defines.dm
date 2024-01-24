
/mob/living/carbon/alien
	default_emotes = list(
		/datum/emote/scratch,
		/datum/emote/drool,
		/datum/emote/nod,
		/datum/emote/sway,
		/datum/emote/sulk,
		/datum/emote/twitch,
		/datum/emote/dance,
		/datum/emote/roll,
		/datum/emote/shake,
		/datum/emote/jump,
		/datum/emote/hiss,
		/datum/emote/shiver,
		/datum/emote/collapse,
		/datum/emote/deathgasp_alien,
		/datum/emote/whimper,
		/datum/emote/gasp,
		/datum/emote/choke,
		/datum/emote/moan,
		/datum/emote/chirp
		)

/mob/living/carbon/human
	default_emotes = list(
		/datum/emote/scream,
		/datum/emote/scream_long,
		/datum/emote/gasp,
		/datum/emote/sneeze,
		/datum/emote/sniff,
		/datum/emote/snore,
		/datum/emote/whimper,
		/datum/emote/yawn,
		/datum/emote/clap,
		/datum/emote/chuckle,
		/datum/emote/cough,
		/datum/emote/cry,
		/datum/emote/sigh,
		/datum/emote/laugh,
		/datum/emote/mumble,
		/datum/emote/grumble,
		/datum/emote/groan,
		/datum/emote/moan,
		/datum/emote/grunt,
		/datum/emote/nod,
		/datum/emote/shake,
		/datum/emote/shiver,
		/datum/emote/collapse,
		/datum/emote/airguitar,
		/datum/emote/blink,
		/datum/emote/blink_rapidly,
		/datum/emote/bow,
		/datum/emote/salute,
		/datum/emote/flap,
		/datum/emote/aflap,
		/datum/emote/drool,
		/datum/emote/eyebrow,
		/datum/emote/twitch,
		/datum/emote/twitch_violently,
		/datum/emote/faint,
		/datum/emote/frown,
		/datum/emote/blush,
		/datum/emote/wave,
		/datum/emote/glare,
		/datum/emote/stare,
		/datum/emote/look,
		/datum/emote/raise,
		/datum/emote/grin,
		/datum/emote/shrug,
		/datum/emote/smile,
		/datum/emote/pale,
		/datum/emote/tremble,
		/datum/emote/wink,
		/datum/emote/hug,
		/datum/emote/dap,
		/datum/emote/handshake,
		/datum/emote/dance,
		/datum/emote/vomit
	)

/mob/living/carbon/metroid/load_default_emotes()
	default_emotes += typesof(/datum/emote/metroid)
	return ..()

/mob/living/silicon/robot
	default_emotes = list(
		/datum/emote/synth/beep,
		/datum/emote/synth/ping,
		/datum/emote/synth/buzz,
		/datum/emote/synth/deny,
		/datum/emote/synth/confirm,
		/datum/emote/synth/law,
		/datum/emote/synth/halt,
		/datum/emote/synth/deathgasp,
		/datum/emote/clap,
		/datum/emote/bow,
		/datum/emote/salute,
		/datum/emote/flap,
		/datum/emote/aflap,
		/datum/emote/twitch,
		/datum/emote/twitch_violently,
		/datum/emote/nod,
		/datum/emote/shake,
		/datum/emote/glare,
		/datum/emote/look,
		/datum/emote/stare,
		/datum/emote/dance
		)

/mob/living/silicon/robot/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/synth)
	return ..()

/mob/living/carbon/metroid
	default_emotes = list(
		/datum/emote/moan,
		/datum/emote/twitch,
		/datum/emote/sway,
		/datum/emote/shiver
	)

/datum/species
	var/list/default_emotes = list()

/datum/species/unathi
	default_emotes = list(
		/datum/emote/species/swish,
		/datum/emote/species/swag,
		/datum/emote/species/sway,
		/datum/emote/species/qwag,
		/datum/emote/species/fastsway,
		/datum/emote/species/swag,
		/datum/emote/species/stopsway
		)

/datum/species/tajaran
	default_emotes = list(
		/datum/emote/species/swish,
		/datum/emote/species/wag,
		/datum/emote/species/sway,
		/datum/emote/species/qwag,
		/datum/emote/species/fastsway,
		/datum/emote/species/swag,
		/datum/emote/species/stopsway
		)

/datum/species/swine
	default_emotes = list(
		/datum/emote/oink
		)
