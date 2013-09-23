/*
Ideas for the subtle effects of hallucination:

Light up oxygen/plasma indicators (done)
Cause health to look critical/dead, even when standing (done)
Characters silently watching you
Brief flashes of fire/space/bombs/c4/dangerous shit (done)
Items that are rare/traitorous/don't exist appearing in your inventory slots (done)
Strange audio (should be rare) (done)
Gunshots/explosions/opening doors/less rare audio (done)

*/

mob/living/carbon/var
	image/halimage
	obj/halitem
	hal_screwyhud = 0 //1 - critical, 2 - dead, 3 - oxygen indicator, 4 - toxin indicator
	handling_hal = 0

mob/living/carbon/proc/handle_hallucinations()
	if(handling_hal) return
	handling_hal = 1
	while(hallucination > 20)
		sleep(rand(200,500))
		var/halpick = rand(1,100)
		switch(halpick)
			if(0 to 15)
				//Screwy HUD
				//src << "Screwy HUD"
				hal_screwyhud = pick(1,2,3,3,4,4)
				spawn(rand(100,250))
					hal_screwyhud = 0
			if(16 to 25)
				//Strange items
				//src << "Traitor Items"
				halitem = new
				var/list/slots_free = list("1,1","3,1")
				if(l_hand) slots_free -= "1,1"
				if(r_hand) slots_free -= "3,1"
				if(istype(src,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					if(!H.belt) slots_free += "3,0"
					if(!H.l_store) slots_free += "4,0"
					if(!H.r_store) slots_free += "5,0"
				if(slots_free.len)
					halitem.screen_loc = pick(slots_free)
					halitem.layer = 50
					switch(rand(1,6))
						if(1) //revolver
							halitem.icon = 'icons/obj/gun.dmi'
							halitem.icon_state = "revolver"
							halitem.name = "Revolver"
						if(2) //c4
							halitem.icon = 'icons/obj/syndieweapons.dmi'
							halitem.icon_state = "c4small_0"
							halitem.name = "Mysterious Package"
							if(prob(25))
								halitem.icon_state = "c4small_1"
						if(3) //sword
							halitem.icon = 'icons/obj/weapons.dmi'
							halitem.icon_state = "sword1"
							halitem.name = "Sword"
						if(4) //stun baton
							halitem.icon = 'icons/obj/weapons.dmi'
							halitem.icon_state = "stunbaton"
							halitem.name = "Stun Baton"
						if(5) //emag
							halitem.icon = 'icons/obj/card.dmi'
							halitem.icon_state = "emag"
							halitem.name = "Cryptographic Sequencer"
						if(6) //flashbang
							halitem.icon = 'icons/obj/grenade.dmi'
							halitem.icon_state = "flashbang1"
							halitem.name = "Flashbang"
					if(client) client.screen += halitem
					spawn(rand(100,250))
						del halitem
			if(26 to 40)
				//Flashes of danger
				//src << "Danger Flash"
				var/possible_points = list()
				for(var/turf/simulated/floor/F in view(src,world.view))
					possible_points += F
				var/turf/simulated/floor/target = pick(possible_points)

				switch(rand(1,3))
					if(1)
						//src << "Space"
						halimage = image('icons/turf/space.dmi',target,"[rand(1,25)]",TURF_LAYER)
					if(2)
						//src << "Fire"
						halimage = image('icons/effects/fire.dmi',target,"1",TURF_LAYER)
					if(3)
						//src << "C4"
						halimage = image('icons/obj/syndieweapons.dmi',target,"c4small_1",OBJ_LAYER+0.01)


				if(client) client.images += halimage
				spawn(rand(10,50)) //Only seen for a brief moment.
					if(client) client.images -= halimage
					halimage = null


			if(41 to 65)
				//Strange audio
				//src << "Strange Audio"
				switch(rand(1,12))
					if(1) src << 'sound/machines/airlock.ogg'
					if(2)
						if(prob(50))src << 'sound/effects/Explosion1.ogg'
						else src << 'sound/effects/Explosion2.ogg'
					if(3) src << 'sound/effects/explosionfar.ogg'
					if(4) src << 'sound/effects/Glassbr1.ogg'
					if(5) src << 'sound/effects/Glassbr2.ogg'
					if(6) src << 'sound/effects/Glassbr3.ogg'
					if(7) src << 'sound/machines/twobeep.ogg'
					if(8) src << 'sound/machines/windowdoor.ogg'
					if(9)
						//To make it more realistic, I added two gunshots (enough to kill)
						src << 'sound/weapons/Gunshot.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Gunshot.ogg'
					if(10) src << 'sound/weapons/smash.ogg'
					if(11)
						//Same as above, but with tasers.
						src << 'sound/weapons/Taser.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Taser.ogg'
				//Rare audio
					if(12)
						switch(rand(1,4))
							if(1) src << 'sound/effects/ghost.ogg'
							if(2) src << 'sound/effects/ghost2.ogg'
							if(3) src << 'sound/effects/Heart Beat.ogg'
							if(4) src << 'sound/effects/screech.ogg'
	handling_hal = 0




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