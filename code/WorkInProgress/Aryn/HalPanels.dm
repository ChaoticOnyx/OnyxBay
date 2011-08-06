obj/machinery/proc/mockpanel(list/buttons,start_txt,end_txt,list/mid_txts)

	if(!mocktxt)

		mocktxt = ""

		var/possible_txt = list("Launch Escape Pods","Self-Destruct Sequence","\[Swipe ID\]","De-Monkify",\
		"Reticulate Splines","Plasma","Open Valve","Lockdown","Nerf Airflow","Kill Traitor","Nihilism",\
		"OBJECTION!","Arrest Stephen Bowman","Engage Anti-Trenna Defenses","Increase Captain IQ","Retrieve Arms",\
		"Play Charades","Oxygen","Inject BeAcOs","Ninja Lizards","Limit Break","Build Sentry")

		if(mid_txts)
			while(mid_txts.len)
				var/mid_txt = pick(mid_txts)
				mocktxt += mid_txt
				mid_txts -= mid_txt

		while(buttons.len)

			var/button = pick(buttons)

			var/button_txt = pick(possible_txt)

			mocktxt += "<a href='?src=\ref[src];[button]'>[button_txt]</a><br>"

			buttons -= button
			possible_txt -= button_txt

	return start_txt + mocktxt + end_txt + "</TT></BODY></HTML>"

proc/check_panel(mob/M)
	if (istype(M, /mob/living/carbon/human) || istype(M, /mob/living/silicon/ai))
		if(M.hallucination < 15)
			return 1
	return 0