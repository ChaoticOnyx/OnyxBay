/datum/emote/nymph/chirp
	key = "chirp"

	message_1p = "You chirp."
	message_3p = "chirps!"

	message_type = AUDIBLE_MESSAGE

	sound = 'sound/misc/nymphchirp.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)
