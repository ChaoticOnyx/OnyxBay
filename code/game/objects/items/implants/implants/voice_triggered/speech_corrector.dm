#define AGONY_LIMIT 40
#define AGONY_STEP 5
/obj/item/implant/voice_triggered/speech_corrector
	name = "Speech corrector implant"
	desc = "A micro bio-taser that delivers an electric shock every time a blacklisted word is spoken."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2)
	var/list/words_list = list()
	var/stun = 0
	var/agony = 10
	var/agony_limit = AGONY_LIMIT
	var/stutter = 10
	var/static/list/obscene_word_list = file2list("config/obscene_word_list.txt")
	var/check_obscene_words = FALSE

/obj/item/implantcase/speech_corrector
	name = "glass case - 'speech corrector'"
	imp = /obj/item/implant/voice_triggered/speech_corrector

/obj/item/implanter/speech_corrector
	name = "implanter (SC))"
	imp = /obj/item/implant/voice_triggered/speech_corrector

/obj/item/implant/voice_triggered/speech_corrector/islegal()
	return TRUE

/obj/item/implant/voice_triggered/speech_corrector/Initialize()
	. = ..()
	GLOB.listening_objects += src

/obj/item/implant/voice_triggered/speech_corrector/Destroy()
	removed()
	GLOB.listening_objects -= src
	return ..()

/obj/item/implant/voice_triggered/speech_corrector/get_data()
	. = {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> NanoTrasen corp speech corrector implant<BR>
	<b>Life:</b> Activates when the user pronounces forbidden words.<BR>
	<B>Banned words:</B><BR>
	[!isemptylist(words_list) ? jointext(words_list,", ") : "NONE SET"]<BR>
	<A href='byond://?src=\ref[src];words_list_set=add'>add word</A>|
	<A href='byond://?src=\ref[src];words_list_set=remove'>remove word</A>|
	<A href='byond://?src=\ref[src];words_list_set=clear'>clear</A><BR>
	<HR>
	<A href='byond://?src=\ref[src];check_obscene_words=1'>Check obscene words:[check_obscene_words ? "YES" : "NO"]</A><BR>
	<A href='byond://?src=\ref[src];agony_limit=1'>Pain level limit:[agony_limit ? agony_limit : "NONE SET"]</A>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Contains a compact taser, that activates by host pronouncing words from banned list.<BR>
	<b>Special Features:</b> Tasing<BR>"}

/obj/item/implant/voice_triggered/speech_corrector/implanted(mob/target)
	var/memo = "You will be tasered every time when saying something containing this ''[jointext(words_list,", ")]''."
	target.mind.store_memory(memo, 0, 0)
	to_chat(target, SPAN("notice",memo))
	return TRUE

/obj/item/implant/voice_triggered/speech_corrector/emp_act(severity)
	if (malfunction)
		return
	malfunction = MALFUNCTION_TEMPORARY
	switch (severity)
		if (1)	//strong EMP will melt implant either making it go off, or disarming it
			if (prob(25))
				if (prob(25))
					activate()
				else if(prob(10))
					agony_limit = 100
					agony = 100
					activate()
				else
					meltdown()
	spawn (20)
		malfunction = 0
		agony_limit = AGONY_LIMIT
		agony = agony_limit

/obj/item/implant/voice_triggered/speech_corrector/hear_talk(mob/M, msg)
	if(M==imp_in)
		hear(msg)

/obj/item/implant/voice_triggered/speech_corrector/hear(msg)
	if(!words_list)
		return
	var/list/msg_words_list=splittext(sanitize_phrase(lowertext(msg))," ")
	for (var/phrase in msg_words_list)
		if((phrase in words_list) || ((phrase in obscene_word_list) && check_obscene_words))
			activate()

/obj/item/implant/voice_triggered/speech_corrector/proc/sanitize_phrase(phrase)
	var/list/replacechars = list("'" = "","\"" = "",">" = "","<" = "","(" = "",")" = "","-" = "",", " = " ","," = " ",":" = "","!" = "","." = "","?" = "",";" = "")
	return replace_characters(phrase, replacechars)

/obj/item/implant/voice_triggered/speech_corrector/Topic(href, href_list)
	..()
	switch(href_list["words_list_set"])
		if("add")
			var/word = lowertext(sanitize_phrase(input("Enter words separated with ', ':") as null|text))
			words_list |= splittext(word," ")
			interact(usr)
		if("remove")
			var/word = input("Select which word you want to remove:") as anything in words_list|null
			words_list -= word
			interact(usr)
		if("clear")
			if(!isemptylist(words_list))
				if(alert("Word list is not empty. Are you wanna to clear it?","Clear Word list","Yes","No")=="Yes")
					clearlist(words_list)
					interact(usr)
	if(href_list["agony_limit"])
		agony_limit = input("Enter number of pain level, below [AGONY_LIMIT]:") as num|null
		agony_limit = agony_limit > AGONY_LIMIT ? AGONY_LIMIT : agony_limit
		interact(usr)
	if(href_list["check_obscene_words"])
		check_obscene_words = !check_obscene_words
		interact(usr)

/obj/item/implant/voice_triggered/speech_corrector/activate()
	if (malfunction == MALFUNCTION_PERMANENT)
		return

	if(ismob(imp_in))
		var/mob/living/L = imp_in
		to_chat(L, FONT_LARGE(SPAN("danger","You feel a sharp shock!")))
		L.apply_effects(stutter=src.stutter)
		L.stun_effect_act(stun, agony, part.organ_tag, src)
		agony += agony < agony_limit ? AGONY_STEP : 0
