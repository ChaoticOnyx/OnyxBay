GLOBAL_LIST_INIT(default_humanoid_emotes, list(
	/decl/emote/visible/blink,
	/decl/emote/visible/blink_r,
	/decl/emote/audible/synth,
	/decl/emote/audible/synth/ping,
	/decl/emote/audible/synth/buzz,
	/decl/emote/audible/synth/confirm,
	/decl/emote/audible/synth/deny,
	/decl/emote/visible/nod,
	/decl/emote/visible/shake,
	/decl/emote/visible/shiver,
	/decl/emote/audible/sneeze,
	/decl/emote/audible/sniff,
	/decl/emote/audible/snore,
	/decl/emote/audible/whimper,
	/decl/emote/audible/yawn,
	/decl/emote/audible/clap,
	/decl/emote/audible/chuckle,
	/decl/emote/audible/cough,
	/decl/emote/audible/cry,
	/decl/emote/audible/sigh,
	/decl/emote/audible/laugh,
	/decl/emote/audible/mumble,
	/decl/emote/audible/grumble,
	/decl/emote/audible/groan,
	/decl/emote/audible/moan,
	/decl/emote/audible/grunt,
	/decl/emote/audible/giggle,
	/decl/emote/visible/airguitar,
	/decl/emote/visible/bow,
	/decl/emote/visible/salute,
	/decl/emote/visible/eyebrow,
	/decl/emote/visible/frown,
	/decl/emote/visible/blush,
	/decl/emote/visible/wave,
	/decl/emote/visible/look,
	/decl/emote/visible/stare,
	/decl/emote/visible/glare,
	/decl/emote/visible/raise,
	/decl/emote/visible/grin,
	/decl/emote/visible/shrug,
	/decl/emote/visible/smile,
	/decl/emote/visible/pale,
	/decl/emote/visible/tremble,
	/decl/emote/visible/wink,
	/decl/emote/visible/dap,
	/decl/emote/visible/signal,
	/decl/emote/audible/scream,
	/decl/emote/audible/long_scream,
	/decl/emote/audible/gasp,
	/decl/emote/visible/faint))

GLOBAL_LIST_INIT(default_humanoid_emotes_proc, list(
	/mob/proc/emote_pale,
	/mob/proc/emote_laugh,
	/mob/proc/emote_giggle,
	/mob/proc/emote_scream,
	/mob/proc/emote_long_scream,
	/mob/proc/emote_blush,
	/mob/proc/emote_blink,
	/mob/proc/emote_blink_r,
	/mob/proc/emote_bow,
	/mob/proc/emote_chuckle,
	/mob/proc/emote_collapse,
	/mob/proc/emote_cough,
	/mob/proc/emote_cry,
	/mob/proc/emote_clap,
	/mob/proc/emote_drool,
	/mob/proc/emote_faint,
	/mob/proc/emote_frown,
	/mob/proc/emote_gasp,
	/mob/proc/emote_groan,
	/mob/proc/emote_grin,
	/mob/proc/emote_nod,
	/mob/proc/emote_moan,
	/mob/proc/emote_shake,
	/mob/proc/emote_sigh,
	/mob/proc/emote_smile,
	/mob/proc/emote_sneeze,
	/mob/proc/emote_grumble,
	/mob/proc/emote_sniff,
	/mob/proc/emote_snore,
	/mob/proc/emote_shrug,
	/mob/proc/emote_tremble,
	/mob/proc/emote_twitch_v,
	/mob/proc/emote_twitch,
	/mob/proc/emote_wave,
	/mob/proc/emote_whimper,
	/mob/proc/emote_wink,
	/mob/proc/emote_yawn,
	/mob/proc/emote_salute,
	/mob/proc/emote_eyebrow,
	/mob/proc/emote_airguitar,
	/mob/proc/emote_mumble,
	/mob/proc/emote_raise,
	/mob/proc/emote_signal,
	/mob/proc/emote_shiver,
	/mob/proc/emote_dap,
	/mob/proc/emote_grunt,
	/mob/proc/emote_look,
	/mob/proc/emote_glare,
	/mob/proc/emote_stare,
	/mob/proc/emote_vomit
))
/datum/species
	var/list/default_emotes = list()

/datum/species/human/New()
	. = ..()
	default_emotes += GLOB.default_humanoid_emotes
	inherent_verbs += GLOB.default_humanoid_emotes_proc

/mob/living/carbon/update_emotes()
	. = ..(skip_sort=1)
	if(species)
		for(var/emote in species.default_emotes)
			var/decl/emote/emote_datum = decls_repository.get_decl(emote)
			if(emote_datum.check_user(src))
				usable_emotes[emote_datum.key] = emote_datum
	usable_emotes = sortAssoc(usable_emotes)

// Specific defines follow.

/datum/species/metroid
	default_emotes = list(
		/decl/emote/visible/bounce,
		/decl/emote/visible/jiggle,
		/decl/emote/visible/lightup,
		/decl/emote/visible/vibrate
		)

/datum/species/unathi/New()
	. = ..()
	default_emotes += list(
		/decl/emote/human/swish,
		/decl/emote/human/wag,
		/decl/emote/human/sway,
		/decl/emote/human/qwag,
		/decl/emote/human/fastsway,
		/decl/emote/human/swag,
		/decl/emote/human/stopsway
	) | GLOB.default_humanoid_emotes

	inherent_verbs += list(
		/mob/proc/emote_swish,
		/mob/proc/emote_wag,
		/mob/proc/emote_fastsway,
		/mob/proc/emote_stopsway
	) | GLOB.default_humanoid_emotes_proc


/datum/species/tajaran/New()
	. = ..()
	default_emotes += list(
		/decl/emote/human/swish,
		/decl/emote/human/wag,
		/decl/emote/human/sway,
		/decl/emote/human/qwag,
		/decl/emote/human/fastsway,
		/decl/emote/human/swag,
		/decl/emote/human/stopsway
	) | GLOB.default_humanoid_emotes

	inherent_verbs += list(
		/mob/proc/emote_swish,
		/mob/proc/emote_wag,
		/mob/proc/emote_fastsway,
		/mob/proc/emote_stopsway
	) | GLOB.default_humanoid_emotes_proc

/datum/species/skrell/New()
	. = ..()
	default_emotes += GLOB.default_humanoid_emotes
	inherent_verbs += GLOB.default_humanoid_emotes_proc

/datum/species/monkey/New()
	. = ..()
	default_emotes += list(
		/decl/emote/visible/scratch,
		/decl/emote/visible/jump,
		/decl/emote/visible/roll,
		/decl/emote/visible,
		/decl/emote/audible/cry,
		/decl/emote/audible/whimper,
		/decl/emote/audible/scream,
		/decl/emote/audible/giggle,
		/decl/emote/visible/frown
	)

	inherent_verbs += list(
		/mob/proc/emote_scratch,
		/mob/proc/emote_jump,
		/mob/proc/emote_roll,
		/mob/proc/emote_tail,
		/mob/proc/emote_cry,
		/mob/proc/emote_whimper,
		/mob/proc/emote_scream,
		/mob/proc/emote_giggle,
		/mob/proc/emote_frown
	)

/datum/species/nabber
	default_emotes = list(
		/decl/emote/audible/bug_hiss,
		/decl/emote/audible/bug_buzz,
		/decl/emote/audible/bug_chitter
		)

/mob/living/carbon/human/set_species(new_species, default_colour)
	. = ..()
	update_emotes()
