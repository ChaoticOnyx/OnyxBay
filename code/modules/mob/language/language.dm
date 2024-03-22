#define SCRAMBLE_CACHE_LEN 20

/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language"  // Fluff name of language if any.
	var/desc = "A language."          // Short description for 'Check Languages'.
	var/speech_verb = "says"          // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"             // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims"     // Used when sentence ends in a !
	var/whisper_verb                  // Optional. When not specified speech_verb + quietly/softly is used instead.
	var/signlang_verb = list("signs", "gestures") // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/colour = "body"               // CSS style to use for strings in this language.
	var/key = "x"                     // Character used to speak in language eg. :o for Unathi.
	var/language_flags = 0            // Various language flags.
	var/native                        // If set, non-native speakers will have trouble speaking.
	var/list/syllables                // Used when scrambling text for a non-speaker.
	var/list/space_chance = 55        // Likelihood of getting a space in the random scramble string
	var/machine_understands = 1       // Whether machines can parse and understand this language
	var/shorthand = "UL"			  // Shorthand that shows up in chat for this language.

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4, syllable_divisor=2)
	if(!syllables || !syllables.len)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	var/full_name = ""
	var/new_name = ""

	for(var/i = 0;i<name_count;i++)
		new_name = ""
		for(var/x = rand(Floor(syllable_count/syllable_divisor),syllable_count);x>0;x--)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"

	return "[trim(full_name)]"

/datum/language
	var/list/scramble_cache = list()

/datum/language/proc/scramble(input)

	if(!syllables || !syllables.len)
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = 1

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = 0
		scrambled_text += next
		var/chance = rand(100)
		if(chance <= 5)
			scrambled_text += ". "
			capitalize = 1
		else if(chance > 5 && chance <= space_chance)
			scrambled_text += " "

	scrambled_text = trim(scrambled_text)
	var/ending = copytext(scrambled_text, length(scrambled_text))
	if(ending == ".")
		scrambled_text = copytext(scrambled_text,1,length(scrambled_text)-1)
	var/input_ending = copytext(input, input_size)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len-SCRAMBLE_CACHE_LEN-1)

	return scrambled_text

/datum/language/proc/format_message(message, verb)
	return "[verb], <span class='message'><span class='[colour]'>\"[capitalize(message)]\"</span></span>"

/datum/language/proc/format_message_plain(message, verb)
	return "[verb], \"[capitalize(message)]\""

/datum/language/proc/format_message_radio(message, verb)
	return "[verb], <span class='[colour]'>\"[capitalize(message)]\"</span>"

/datum/language/proc/get_talkinto_msg_range(message)
	// if you yell, you'll be heard from two tiles over instead of one
	return (copytext(message, length(message)) == "!") ? 2 : 1

/datum/language/proc/broadcast(mob/living/speaker,message,speaker_mask)
	log_say("[key_name(speaker)]: ([name]) [message]")

	if(!speaker_mask) speaker_mask = speaker.name
	message = format_message(message, get_spoken_verb(message))

	for(var/mob/player in GLOB.player_list)
		player.hear_broadcast(src, speaker, speaker_mask, message)

/mob/proc/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	if((language in languages) && language.check_special_condition(src))
		var/msg = "<i><span class='game say'>[language.name], <span class='name'>[speaker_name]</span> [message]</span></i>"
		to_chat(src, msg)

/mob/new_player/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	return

/mob/observer/ghost/hear_broadcast(datum/language/language, mob/speaker, speaker_name, message)
	if(speaker.name == speaker_name || antagHUD)
		to_chat(src, "<i><span class='game say'>[language.name], <span class='name'>[speaker_name]</span> ([ghost_follow_link(speaker, src)]) [message]</span></i>")
	else
		to_chat(src, "<i><span class='game say'>[language.name], <span class='name'>[speaker_name]</span> [message]</span></i>")

/datum/language/proc/check_special_condition(mob/other)
	return 1

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return exclaim_verb
		if("?")
			return ask_verb
	return speech_verb

/datum/language/proc/can_speak_special(mob/speaker)
	return 1

// Language handling.
/mob/proc/add_language(language)

	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	. = (L in languages)
	languages.Remove(L)

/mob/living/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	if(default_language == L)
		default_language = null
	return ..()

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)
	if(!speaking)
		return 0

	if (only_species_language && speaking != all_languages[species_language])
		return 0

	return (speaking.can_speak_special(src) && (universal_speak || (speaking && speaking.language_flags & INNATE) || (speaking in src.languages)))

/mob/proc/get_language_prefix()
	return get_prefix_key(/decl/prefix/language)

/mob/proc/is_language_prefix(prefix)
	return prefix == get_prefix_key(/decl/prefix/language)

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	language_menu.tgui_interact(usr)

/proc/transfer_languages(mob/source, mob/target, except_flags)
	for(var/datum/language/L in source.languages)
		if(L.language_flags & except_flags)
			continue
		target.add_language(L.name)

#undef SCRAMBLE_CACHE_LEN
