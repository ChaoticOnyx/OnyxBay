/mob/density = 1
/mob/layer = 4.0
/mob/animate_movement = 2
/mob/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/mob/var/mholder = null

/mob/var/datum/mind/mind

/mob/var/uses_hud = 0
/mob/var/obj/screen/flash = null
/mob/var/obj/screen/pain = null
/mob/var/obj/screen/blind = null
/mob/var/obj/screen/hands = null
/mob/var/obj/screen/mach = null
/mob/var/obj/screen/sleep = null
/mob/var/obj/screen/rest = null
/mob/var/obj/screen/pullin = null
/mob/var/obj/screen/internals = null
/mob/var/obj/screen/oxygen = null
/mob/var/obj/screen/i_select = null
/mob/var/obj/screen/m_select = null
/mob/var/obj/screen/toxin = null
/mob/var/obj/screen/fire = null
/mob/var/obj/screen/bodytemp = null
/mob/var/obj/screen/healths = null
/mob/var/obj/screen/throw_icon = null
/mob/var/obj/screen/panel_icon = null
/mob/var/obj/screen/cell_icon = null
/mob/var/obj/screen/exttemp = null
/mob/var/obj/screen/store = null
/mob/var/obj/screen/module_icon = null

/mob/var/list/atom/hallucinations = list()
/mob/var/halloss = 0
/mob/var/hallucination = 0

/mob/var/alien_egg_flag = 0

/mob/var/last_special = 0

/mob/var/obj/screen/zone_sel/zone_sel = null

/mob/var/emote_allowed = 1
/mob/var/computer_id = null
/mob/var/lastattacker = null
/mob/var/lastattacked = null
/mob/var/already_placed = 0.0
/mob/var/obj/machinery/machine = null
/mob/var/other_mobs = null
/mob/var/memory = ""
/mob/var/poll_answer = 0.0
/mob/var/sdisabilities = 0
/mob/var/disabilities = 0
/mob/var/atom/movable/pulling = null
/mob/var/stat = 0.0
#define STAT_ALIVE 0
#define STAT_ASLEEP 1
#define STAT_DEAD 2
/mob/var/next_move = null
/mob/var/prev_move = null
/mob/var/monkeyizing = null
/mob/var/other = 0.0
/mob/var/hand = null
/mob/var/eye_blind = null
/mob/var/eye_blurry = null
/mob/var/ear_deaf = null
/mob/var/ear_damage = null
/mob/var/stuttering = null
/mob/var/intoxicated = null
/mob/var/real_name = null
/mob/var/blinded = null
/mob/var/rejuv = null
/mob/var/druggy = 0
/mob/var/confused = 0
/mob/var/staggering = 0
/mob/var/antitoxs = null
/mob/var/plasma = null
/mob/var/sleeping = 0.0
/mob/var/resting = 0.0
/mob/var/lying = 0.0
/mob/var/canmove = 1.0
/mob/var/eye_stat = null
/mob/var/oxyloss = 0.0
/mob/var/toxloss = 0.0
/mob/var/fireloss = 0.0
/mob/var/timeofdeath = 0.0
/mob/var/bruteloss = 0.0
/mob/var/organbruteloss = 0.0
/mob/var/cpr_time = 1.0
/mob/var/health_full = 100
/mob/var/health = 100
/mob/var/bodytemperature = 310.055	//98.7 F
/mob/var/drowsyness = 0.0
/mob/var/dizziness = 0
/mob/var/is_dizzy = 0
/mob/var/is_jittery = 0
/mob/var/jitteriness = 0
/mob/var/charges = 0.0
/mob/var/urine = 0.0
/mob/var/poo = 0.0
/mob/var/nutrition = 0.0
/mob/var/paralysis = 0.0
/mob/var/stunned = 0.0
/mob/var/weakened = 0.0
/mob/var/losebreath = 0.0
/mob/var/muted = null
/mob/var/intent = null
/mob/var/shakecamera = 0
/mob/var/a_intent = "help"
/mob/var/m_int = null
/mob/var/m_intent = "run"
/mob/var/lastDblClick = 0
/mob/var/lastKnownIP = null
/mob/var/obj/stool/buckled = null
/mob/var/obj/item/weapon/handcuffs/handcuffed = null
/mob/var/obj/item/l_hand = null
/mob/var/obj/item/r_hand = null
/mob/var/obj/item/weapon/back = null
/mob/var/obj/item/weapon/tank/internal = null
/mob/var/obj/item/weapon/storage/s_active = null
/mob/var/obj/item/clothing/mask/wear_mask = null
/mob/var/r_epil = 0
/mob/var/r_ch_cou = 0
/mob/var/r_Tourette = 0

/mob/var/obj/hud/hud_used = null

/mob/var/list/organs = list(  )
/mob/var/list/grabbed_by = list(  )
/mob/var/list/requests = list(  )

/mob/var/list/mapobjs = list()

/mob/var/in_throw_mode = 0

/mob/var/coughedtime = null

/mob/var/inertia_dir = 0
/mob/var/footstep = 1

/mob/var/music_lastplayed = "null"

/mob/var/job = null

/mob/var/nodamage = 0
/mob/var/logged_in = 0

/mob/var/underwear = 1
/mob/var/be_syndicate = 0
/mob/var/be_random_name = 0
/mob/var/const/blindness = 1
/mob/var/const/deafness = 2
/mob/var/const/muteness = 4
/mob/var/brainloss = 0

/mob/var/datum/dna/dna = null
/mob/var/radiation = 0.0

/mob/var/mutations = 0
///mob/telekinesis = 1
///mob/firemut = 2
///mob/xray = 4
///mob/hulk = 8
///mob/clumsy = 16
///mob/obese = 32
///mob/husk = 64

/mob/var/voice_name = "unidentifiable voice"
/mob/var/voice_message = null

//Monkey/infected mode
/mob/var/list/resistances = list()
/mob/var/datum/disease/virus = null

//Changeling mode stuff
/mob/var/changeling_absorbing = 0
/mob/var/changeling_fakedeath = 0
/mob/var/changeling_level = 0
/mob/var/list/absorbed_dna = list()

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air(1)

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/ishuman(A)
	if(A && istype(A, /mob/living/carbon/human))
		return 1
	return 0

/proc/isalien(A)
	if(A && istype(A, /mob/living/carbon/alien))
		return 1
	return 0

/proc/ismonkey(A)
	if(A && istype(A, /mob/living/carbon/monkey))
		return 1
	return 0

/proc/isrobot(A)
	if(A && istype(A, /mob/living/silicon/robot))
		return 1
	return 0

/proc/isAI(A)
	if(A && istype(A, /mob/living/silicon/ai))
		return 1
	return 0

/proc/iscarbon(A)
	if(A && istype(A, /mob/living/carbon))
		return 1
	return 0

/proc/issilicon(A)
	if(A && istype(A, /mob/living/silicon))
		return 1
	return 0
proc/iszombie(A)
	if(A && istype(A, /mob/living/carbon/human))
		if(A:zombie)
			return 1
	return 0
/proc/hsl2rgb(h, s, l)
	return
mob/verb/turnnorth()
	set hidden = 1
	dir = NORTH
mob/verb/turnsouth()
	set hidden = 1
	dir = SOUTH
mob/verb/turneast()
	set hidden = 1
	dir = EAST
mob/verb/turnwest()
	set hidden = 1
	dir = WEST
/proc/ran_zone(zone, probability)

	if (probability == null)
		probability = 90
	if (probability == 100)
		return zone
	switch(zone)
		if("chest")
			if (prob(probability))
				return "chest"
			else
				var/t = rand(1, 15)
				if (t < 3)
					return "head"
				else if (t < 6)
					return "l_arm"
				else if (t < 9)
					return "r_arm"
				else if (t < 13)
					return "groin"
				else if (t < 14)
					return "l_hand"
				else if (t < 15)
					return "r_hand"
				else
					return "chest"

		if("groin")
			if (prob(probability * 0.9))
				return "groin"
			else
				var/t = rand(1, 8)
				if (t < 4)
					return "chest"
				else if (t < 5)
					return "r_leg"
				else if (t < 6)
					return "l_leg"
				else if (t < 7)
					return "l_hand"
				else if (t < 8)
					return "r_hand"
				else
					return "groin"
		if("head")
			if (prob(probability * 0.75))
				return "head"
			else
				if (prob(60))
					return "chest"
				else
					return "head"
		if("l_arm")
			if (prob(probability * 0.75))
				return "l_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "l_arm"
		if("r_arm")
			if (prob(probability * 0.75))
				return "r_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "r_arm"
		if("r_leg")
			if (prob(probability * 0.75))
				return "r_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "r_leg"
		if("l_leg")
			if (prob(probability * 0.75))
				return "l_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "l_leg"
		if("l_hand")
			if (prob(probability * 0.5))
				return "l_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "l_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "l_leg"
				else
					return "l_hand"

		if("r_hand")
			if (prob(probability * 0.5))
				return "r_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "r_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "r_leg"
				else
					return "r_hand"

		if("l_foot")
			if (prob(probability * 0.25))
				return "l_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "l_leg"
				else
					if (t < 3)
						return "r_foot"
					else
						return "l_foot"
		if("r_foot")
			if (prob(probability * 0.25))
				return "r_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "r_leg"
				else
					if (t < 3)
						return "l_foot"
					else
						return "r_foot"
		else
	return

/proc/stars(n, pr = 25)
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		var/n_letter = copytext(te, p, p + 1)
		if (prob(80))
			if (prob(10))
				n_letter = text("[n_letter][n_letter][n_letter][n_letter]")
			else
				if (prob(20))
					n_letter = text("[n_letter][n_letter][n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter][n_letter]")
		t = text("[t][n_letter]")
		p++
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || M.shakecamera)
		return
	spawn(1)
		var/oldeye=M.client.eye
		var/x
		M.shakecamera = 1
		for(x=0; x<duration, x++)
			M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)
		M.shakecamera = 0
		M.client.eye=oldeye

/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[msg]"))
			return 1
	return 0

/obj/proc/alter_health()
	return 1

/atom/proc/relaymove()
	return

/obj/proc/hide(h)
	return

/obj/item/weapon/grab/proc/throw()
	if(affecting)
		var/grabee = affecting
		spawn(0)
			del(src)
		return grabee
	return null

/obj/item/weapon/grab/proc/synch()
	if (assailant.r_hand == src)
		hud1.screen_loc = ui_rhand
	else
		hud1.screen_loc = ui_lhand
	return

/obj/item/weapon/grab/process()
	if(!assailant || !affecting)
		del(src)
		return
	if ((!( isturf(assailant.loc) ) || (!( isturf(affecting.loc) ) || (assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1))))
		//SN src = null
		del(src)
		return
	if (assailant.client)
		assailant.client.screen -= hud1
		assailant.client.screen += hud1
	if (assailant.pulling == affecting)
		assailant.pulling = null
	if (state <= 2)
		allow_upgrade = 1
		if ((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if ((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if (G.affecting != affecting)
				allow_upgrade = 0
		if (state == 2)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if (G.state == 2)
					allow_upgrade = 0
				//Foreach goto(341)
		if (allow_upgrade)
			hud1.icon_state = "reinforce"
		else
			hud1.icon_state = "!reinforce"
	else
		if (!( affecting.buckled ))
			affecting.loc = assailant.loc
	if ((killing && state == 3))
		if(prob(45)) affecting.stunned = max(3, affecting.stunned)
		//affecting.paralysis = max(3, affecting.paralysis)
		affecting.losebreath = min(affecting.losebreath + 2, 3)
	return

/obj/item/weapon/grab/proc/s_click(obj/screen/S as obj)
	if (assailant.next_move > world.time)
		return
	if ((!( assailant.canmove ) || assailant.lying))
		//SN src = null
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state >= 3)
				if (!( killing ))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has temporarily tightened his grip on []!", assailant, affecting), 1)
						//Foreach goto(97)
					assailant.next_move = world.time + 10
					affecting.stunned = max(2, affecting.stunned)
					//affecting.paralysis = max(1, affecting.paralysis)
					affecting.losebreath = min(affecting.losebreath + 1, 3)
					last_suffocate = world.time
					flick("disarm/killf", S)
		else
	return

/obj/item/weapon/grab/proc/s_dbclick(obj/screen/S as obj)
	if ((assailant.next_move > world.time && !( last_suffocate < world.time + 2 )))
		return
	if ((!( assailant.canmove ) || assailant.lying))
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (state < 2)
				if (!( allow_upgrade ))
					return
				if (prob(75))
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has grabbed [] aggressively (now hands)!", assailant, affecting), 1)
					state = 2
					icon_state = "grabbed1"
				else
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has failed to grab [] aggressively!", assailant, affecting), 1)
					del(src)
					return
			else
				if (state < 3)
					if(istype(affecting, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = affecting
						/*if(H.mutations & 32)
							assailant << "\blue You can't strangle [affecting] through all that fat!"
							return*/
						for(var/obj/item/clothing/C in list(H.head, H.wear_suit, H.wear_mask, H.w_uniform))
							if(C.body_parts_covered & HEAD)
								assailant << "\blue You have to take off [affecting]'s [C.name] first!"
								return
						/*
						if(istype(H.wear_suit, /obj/item/clothing/suit/space) || istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/bio_suit) || istype(H.wear_suit, /obj/item/clothing/suit/swat_suit))
							assailant << "\blue You can't strangle [affecting] through their suit collar!"
							return
						*/
					for(var/mob/O in viewers(assailant, null))
						O.show_message(text("\red [] has reinforced his grip on [] (now neck)!", assailant, affecting), 1)

					state = 3
					icon_state = "grabbed+1"
					if (!( affecting.buckled ))
						affecting.loc = assailant.loc
					hud1.icon_state = "disarm/kill"
					hud1.name = "disarm/kill"
				else
					if (state >= 3)
						killing = !( killing )
						if (killing)
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has tightened his grip on []'s neck!", assailant, affecting), 1)
							assailant.next_move = world.time + 10
							affecting.stunned = max(2, affecting.stunned)
							//affecting.paralysis = max(1, affecting.paralysis)
							affecting.losebreath += 1
							hud1.icon_state = "disarm/kill1"
						else
							hud1.icon_state = "disarm/kill"
							for(var/mob/O in viewers(assailant, null))
								O.show_message(text("\red [] has loosened the grip on []'s neck!", assailant, affecting), 1)
		else
	return

/obj/item/weapon/grab/New()
	..()
	hud1 = new /obj/screen/grab( src )
	hud1.icon_state = "reinforce"
	hud1.name = "Reinforce Grab"
	hud1.id = 1
	hud1.master = src
	return

/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == affecting)
		if (state < 3)
			s_dbclick(hud1)
		else
			s_click(hud1)
		return
	if(M == assailant && state >= 2)
		if( ( ishuman(user) /*&& (user.mutations & 32)*/ && ismonkey(affecting) ) || ( isalien(user) && iscarbon(affecting) ) )
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [affecting]!</B>"), 1)
			if(!do_mob(user, affecting)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [affecting]!</B>"), 1)
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			del(src)

/obj/item/weapon/grab/dropped()
	del(src)
	return

/obj/item/weapon/grab/Del()
	del(hud1)
	..()
	return

/obj/screen/zone_sel/MouseDown(location, control,params)		//(location, icon_x, icon_y)
	// Changes because of 4.0


	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])

	if (icon_y < 2)
		return
	else if (icon_y < 5)
		if ((icon_x > 9 && icon_x < 23))
			if (icon_x < 16)
				selecting = "r_foot"
			else
				selecting = "l_foot"
	else if (icon_y < 11)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				selecting = "r_leg"
			else
				selecting = "l_leg"
	else if (icon_y < 12)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				selecting = "r_leg"
			else if (icon_x < 19)
				selecting = "groin"
			else
				selecting = "l_leg"
		else
			return
	else if (icon_y < 13)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_hand"
			else if (icon_x < 13)
				selecting = "r_leg"
			else if (icon_x < 20)
				selecting = "groin"
			else if (icon_x < 21)
				selecting = "l_leg"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 14)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_hand"
			else if (icon_x < 21)
				selecting = "groin"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 16)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 13)
				selecting = "r_hand"
			else if (icon_x < 20)
				selecting = "chest"
			else
				selecting = "l_hand"
		else
			return
	else if (icon_y < 23)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				selecting = "r_arm"
			else if (icon_x < 21)
				selecting = "chest"
			else
				selecting = "l_arm"
		else
			return
	else if (icon_y < 24)
		if ((icon_x > 11 && icon_x < 21))
			selecting = "chest"
		else
			return
	else if (icon_y < 25)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				selecting = "head"
			else if (icon_x < 17)
				selecting = "mouth"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 26)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 18)
				selecting = "mouth"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 27)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 16)
				selecting = "eyes"
			else if (icon_x < 17)
				selecting = "mouth"
			else if (icon_x < 18)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 28)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				selecting = "head"
			else if (icon_x < 19)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 29)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				selecting = "head"
			else if (icon_x < 16)
				selecting = "eyes"
			else if (icon_x < 17)
				selecting = "head"
			else if (icon_x < 18)
				selecting = "eyes"
			else
				selecting = "head"
		else
			return
	else if (icon_y < 31)
		if ((icon_x > 11 && icon_x < 21))
			selecting = "head"
		else
			return
	else
		return

	overlays = null
	overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", selecting))

	return

/obj/screen/grab/Click()
	master:s_click(src)
	return

/obj/screen/grab/DblClick()
	master:s_dbclick(src)
	return

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/Click(location, control, params)

	var/list/pa = params2list(params)

	switch(name)
		if("map")
			usr.clearmap()

		if("maprefresh")
			var/obj/machinery/computer/security/seccomp = usr.machine

			if(seccomp!=null)
				seccomp.drawmap(usr)
			else
				usr.clearmap()

		if("other")
			if (usr.hud_used.show_otherinventory)
				usr.hud_used.show_otherinventory = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.show_otherinventory = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.other_update()


		if("act_intent")
			if(!istype(usr, /mob/living/silicon/robot))
				if(pa.Find("left"))
					switch(usr.a_intent)
						if("help")
							usr.a_intent = "disarm"
							usr.hud_used.action_intent.icon_state = "disarm"
						if("disarm")
							usr.a_intent = "hurt"
							usr.hud_used.action_intent.icon_state = "harm"
						if("hurt")
							usr.a_intent = "grab"
							usr.hud_used.action_intent.icon_state = "grab"
						if("grab")
							usr.a_intent = "help"
							usr.hud_used.action_intent.icon_state = "help"
				else
					switch(usr.a_intent)
						if("help")
							usr.a_intent = "grab"
							usr.hud_used.action_intent.icon_state = "grab"
						if("disarm")
							usr.a_intent = "help"
							usr.hud_used.action_intent.icon_state = "help"
						if("hurt")
							usr.a_intent = "disarm"
							usr.hud_used.action_intent.icon_state = "disarm"
						if("grab")
							usr.a_intent = "hurt"
							usr.hud_used.action_intent.icon_state = "harm"
			else
				switch(usr.a_intent)
					if("help")
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "harm"
					if ("hurt")
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "help"

		if("arrowleft")
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
				if("disarm")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"
				if("hurt")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
				if("grab")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"

		if("arrowright")
			switch(usr.a_intent)
				if("help")
					usr.a_intent = "disarm"
					usr.hud_used.action_intent.icon_state = "disarm"
				if("disarm")
					usr.a_intent = "hurt"
					usr.hud_used.action_intent.icon_state = "harm"
				if("hurt")
					usr.a_intent = "grab"
					usr.hud_used.action_intent.icon_state = "grab"
				if("grab")
					usr.a_intent = "help"
					usr.hud_used.action_intent.icon_state = "help"

		if("mov_intent")
			switch(usr.m_intent)
				if("run")
					usr.m_intent = "walk"
					usr.hud_used.move_intent.icon_state = "walking"
				if("walk")
					usr.m_intent = "run"
					usr.hud_used.move_intent.icon_state = "running"

		if("intent")
			if (!( usr.intent ))
				switch(usr.a_intent)
					if("help")
						usr.intent = "13,15"
					if("disarm")
						usr.intent = "14,15"
					if("hurt")
						usr.intent = "15,15"
					if("grab")
						usr.intent = "12,15"
			else
				usr.intent = null
		if("m_intent")
			if (!( usr.m_int ))
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if ("module")
			if (istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = usr
				M.installed_modules()
		if ("panel")
			if (istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = usr
				M.panel_menu()
		if ("radio")
			if (istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/M = usr
				M.radio_menu()
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("hurt")
			usr.a_intent = "hurt"
			usr.intent = "15,15"
		if("grab")
			usr.a_intent = "grab"
			usr.intent = "12,15"
		if("disarm")
			if (istype(usr, /mob/living/carbon/human))
				var/mob/M = usr
				M.a_intent = "disarm"
				M.intent = "14,15"
		if("help")
			usr.a_intent = "help"
			usr.intent = "13,15"
		if("Reset Machine")
			usr.machine = null
		if("internal")
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				usr.internal = null
		if("pull")
			usr.pulling = null
		if("sleep")
			usr.sleeping = !( usr.sleeping )
		if("rest")
			usr.resting = !( usr.resting )
		if("throw")
			if (!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			usr.drop_item_v()
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		if("resist")
			if (usr.next_move < world.time)
				return
			usr.next_move = world.time + 20
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				for(var/obj/O in usr.requests)
					del(O)
				for(var/obj/item/weapon/grab/G in usr.grabbed_by)
					if (G.state == 1)
						del(G)
					else
						if (G.state == 2)
							if (prob(25))
								for(var/mob/O in viewers(usr, null))
									O.show_message(text("\red [] has broken free of []'s grip!", usr, G.assailant), 1)
								del(G)
						else
							if (G.state == 3)
								if (prob(5))
									for(var/mob/O in viewers(usr, null))
										O.show_message(text("\red [] has broken free of []'s headlock!", usr, G.assailant), 1)
									del(G)
				for(var/mob/O in viewers(usr, null))
					O.show_message(text("\red <B>[] resists!</B>", usr), 1)

			if(usr:handcuffed && (usr.last_special <= world.time))
				var/breakouttime = 1200
				var/displaytime = 2
				if(!usr:canmove)
					breakouttime = 2400
					displaytime = 4
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				usr << "\red You attempt to remove your handcuffs. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(usr))
					O.show_message(text("\red <B>[] attempts to remove the handcuffs!</B>", usr), 1)
				spawn(0)
					if(do_after(usr, breakouttime))
						if(!usr:handcuffed) return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to remove the handcuffs!</B>", usr), 1)
						usr << "\blue You successfully remove your handcuffs."
						usr:handcuffed:loc = usr:loc
						usr:handcuffed = null

		else
			DblClick()
	return

/obj/screen/attack_hand(mob/user as mob, using)
	user.db_click(name, using)
	return

/obj/screen/attack_paw(mob/user as mob, using)
	user.db_click(name, using)
	return

/obj/equip_e/proc/process()
	return

/obj/equip_e/proc/done()
	return

/obj/equip_e/New()
	if (!ticker)
		del(src)
		return
	spawn(100)
		del(src)
		return
	..()
	return

/mob/New()
	health = health_full
	..()

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/equip_e/human/O = new /obj/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		requests += O
		spawn(0)
			O.process()
			return
	..()
	return

/mob/proc/show_message(msg, type, alt, alt_type)
	if (!client) return

	if (type)
		if ((type & 1 && (sdisabilities & 1 || (blinded || paralysis)))) // If you can't see, replace msg with alt
			if (!alt) return
			else
				msg = alt
				type = alt_type
				if ((type & 2 && (sdisabilities & 4 || ear_deaf))) // Can't see, but can't hear either
					return

		if ((type & 2 && (sdisabilities & 4 || ear_deaf))) // If you can't hear
			if (!alt) return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && (sdisabilities & 1 || (blinded || paralysis)))) // Can't see either
					return

	log_m("Heard [msg]")

	if ((stat == 1 || sleeping > 0) && !(sdisabilities & 4) && ear_deaf == 0) //Can you actually hear?
		if(type & 8) //Radio
			src << "<I>... You hear the crackle of a radio transmission ...</I>"
		else if(type & 4) //Said by someone
			src << "<I>... You can almost hear someone talking ...</I>"
		else if(type & 2)
			src << "<I>... You can almost hear a noise ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/update_clothing()
	return

/mob/proc/death(gibbed)
	if (mind)
		var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
		mind.store_memory("Time of death: [tod]", 0)
	timeofdeath = world.time
	// Necessary in the event of the mob getting deleted before the check can complete (i.e. gibbed)
	if (client)
		spawn check_death(client)
	else
		spawn check_death()
	src.client.onDeath()
	return ..(gibbed)

/proc/check_death(var/client/client = null)
	if (client)
		if(client && client.mob.stat == 2)
			client.mob.verbs += /mob/proc/ghostize

	var/cancel
	for (var/client/C)
		if (C.mob && C.mob.stat < 2)
			cancel = 1
			break

	if (!cancel && !abandon_allowed)
		cancel = 0
		for (var/client/C)
			if (C.mob && !C.mob.stat)
				cancel = 1
				break

		if (!cancel && !abandon_allowed)
			world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"

			spawn (300)
				log_game("Rebooting because of no live players")
				world.Reboot()

/mob/proc/restrained()
	if (handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	switch(text)
		if("mask")
			if (wear_mask)
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if ((back || !( istype(W, /obj/item/weapon) )))
				return
			if (!( W.flags & 1 ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
		else
	return


/mob/living/carbon/proc/swap_hand()
	hand = !( hand )
	if (!( hand ))
		hands.dir = NORTH
	else
		hands.dir = SOUTH
	return

/mob/proc/drop_item_v()
	if (stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in contents))
		return
	u_equip(item)
	if (client)
		client.screen -= item
	if (item)
		item.loc = loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
	var/turf/T = get_turf(loc)
	T.Entered(item)
	return

/mob/proc/drop_item()
	var/obj/item/W = equipped()
	if (W)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
		var/turf/T = get_turf(loc)
		T.Entered(W)
	return

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/mob/proc/equipped()
	if (hand)
		return l_hand
	else
		return r_hand
	return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = text("<TT>\n<B><FONT size=3>[]</FONT></B><BR>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A><BR>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A><BR>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A><BR>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A><BR>\n\t[]<BR>\n\t[]<BR>\n\t[]<BR>\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A><BR>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A><BR>\n</TT>", name, src, (wear_mask ? text("[]", wear_mask) : "Nothing"), src, (l_hand ? text("[]", l_hand) : "Nothing"), src, (r_hand ? text("[]", r_hand) : "Nothing"), src, (back ? text("[]", back) : "Nothing"), ((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), (internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), (handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), src, user, name)
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == back)
		back = null
	else if (W == wear_mask)
		wear_mask = null

	update_clothing()

/mob/proc/ret_grab(obj/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (G.affecting && !( L.container.Find(G.affecting) ))
				L.container += G.affecting
				G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (G.affecting && !( L.container.Find(G.affecting) ))
				L.container += G.affecting
				G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return

/mob/verb/mode()
	set name = "Equipment Mode"

	set src = usr

	var/obj/item/W = equipped()
	if (W)
		W.attack_self(src)
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"

	if (mind)
		mind.show_memory(src)

/mob/verb/add_memory(msg as message)
	set name = "Add Note"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	//msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	//if (sane)
		//msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/verb/help()
	set name = "Help"
	src << browse('help.html', "window=help")
	return

/mob/verb/abandon_mob()
	set name = "Respawn"

	if (!( abandon_allowed ))
		return
	if ((stat != 2 || !( ticker )))
		usr << "\blue <B>You must be dead to use this!</B>"
		return

	log_game("[usr.name]/[usr.key] used abandon mob.")

	usr << "\blue <B>Please roleplay correctly!</B>"

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	for(var/obj/screen/t in usr.client.screen)
		if (t.loc == null)
			//t = null
			del(t)
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		del(M)
		return



	if(client && client.holder && (client.holder.state == 2))
		client.admin_play()
		return

	M.key = client.key
	M.Login()
	return

/mob/verb/cmd_rules()
	set name = "Rules"
	src << browse(rules, "window=rules;size=480x320")

/mob/verb/changes()
	set name = "Changelog"
	src.client.changes = 1
	src.client.showchanges()
/*	if (client)
		src << browse_rsc('postcardsmall.jpg')
		src << browse_rsc('somerights20.png')
		src << browse_rsc('88x31.png')
		src << browse('changelog.html', "window=changes;size=400x650")
		client.changes = 1*/

/mob/verb/succumb()
	set hidden = 1

	if ((health < 0 && health > -95.0))
		oxyloss += health + 200
		health = 100 - oxyloss - toxloss - fireloss - bruteloss - organbruteloss
		src << "\blue You have given up life and succumbed to death."

/mob/verb/observe()
	set name = "Observe"
	var/is_admin = 0

	if (client.holder && client.holder.level >= 1 && ( client.holder.state == 2 || client.holder.level > 3 ))
		is_admin = 1
	else if (istype(src, /mob/new_player) || stat != 2)
		usr << "\blue You must be observing to use this!"
		return

	if (is_admin && stat == 2)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for (var/obj/item/weapon/disk/nuclear/D in world)
		var/name = "Nuclear Disk"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D

	for (var/obj/machinery/bot/B in world)
		var/name = "BOT: [B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B


//THIS IS HOW YOU ADD OBJECTS TO BE OBSERVED

	creatures += getmobs()
//THIS IS THE MOBS PART: LOOK IN HELPERS.DM

	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	if (is_admin)
		eye_name = input("Please, select a player!", "Admin Observe", null, null) as null|anything in creatures
	else
		eye_name = input("Please, select a player!", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/eye = creatures[eye_name]
	if (is_admin)
		if (eye)
			reset_view(eye)
			client.adminobs = 1
			if(eye == client.mob)
				client.adminobs = 0
		else
			reset_view(null)
			client.adminobs = 0
	else
		if (eye)
			client.eye = eye
		else
			client.eye = client.mob

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	reset_view(null)
	machine = null
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !density || lying)
	else
		return (!mover.density || !density || lying)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
		src << browse(null, t1)

	if(href_list["teleto"])
		src.client.jumptoturf(locate(href_list["teleto"]))

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			if(muted)
				src << "You are muted have a nice day"
				return
			if (!( ismob(M) ))
				return

			var/t

			if((usr.client && usr.client.holder) || !(M.client && M.client.holder && M.client.stealth))
				t = input("Message:", text("Private message to [M.key]"))  as text
			else
				t = input("Message:", text("Private message to Administrator"))  as text

			if (!( t ))
				return

			if (usr.client && usr.client.holder)
				if(TABBED_PM)
					M.ctab_message("PM", "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]")
					usr.ctab_message("PM", "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]")
				else
					M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
					usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
			else
				if (M.client && M.client.holder)
					if(TABBED_PM)
						M.ctab_message("PM", "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]")
					else
						M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
				else
					if(TABBED_PM)
						M.ctab_message("PM", "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]")
					else
						M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				if(TABBED_PM)
					usr.ctab_message("PM", "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]")
				else
					usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

			log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/client/C)
				if(C.holder && C.mob.key != usr.key && C.mob.key != M.key)
					if(TABBED_PM)
						C.ctab_message("PM", "<b><font color='blue'>PM: [key_name(usr, C.mob)]->[key_name(M, C.mob)]:</b> \blue [t]</font>")
					else
						C.mob << "<b><font color='blue'>PM: [key_name(usr, C.mob)]->[key_name(M, C.mob)]:</b> \blue [t]</font>"
	..()
	return

/mob/proc/get_damage()
	return health

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(M.mutations & 1)
		show_inv(usr)
		return
	if(get_dist(usr,src) > 1) return
	if(LinkBlocked(usr.loc,loc)) return
	show_inv(usr)

/mob/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(51, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			bruteloss += 51
		updatehealth()
		if (prob(80) && weakened <= 2)
			weakened = 2
	else if (flag == PROJECTILE_TASER)
		if (prob(75) && stunned <= 10)
			stunned = 10
		else
			weakened = 10
	else if(flag == PROJECTILE_LASER)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(20, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			bruteloss += 20
		updatehealth()
		if (prob(25) && stunned <= 2)
			stunned = 2
	else if(flag == PROJECTILE_PULSE)
		if (istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/dam_zone = pick("chest", "chest", "chest", "groin", "head")
			if (H.organs[text("[]", dam_zone)])
				var/datum/organ/external/affecting = H.organs[text("[]", dam_zone)]
				if (affecting.take_damage(40, 0))
					H.UpdateDamageIcon()
				else
					H.UpdateDamage()
		else
			bruteloss += 40
		updatehealth()
		if (prob(50))
			stunned = min(stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		toxloss += 3
		radiation += 100
		updatehealth()
		stuttering += 5
		drowsyness += 5
		if (prob(10))
			weakened = min(weakened, 2)
	return


/atom/movable/Move(NewLoc, direct)
	if (direct & direct - 1)
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					step(src, EAST)
				else
					if (step(src, EAST))
						step(src, NORTH)
			else
				if (direct & 8)
					if (step(src, NORTH))
						step(src, WEST)
					else
						if (step(src, WEST))
							step(src, NORTH)
		else
			if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						step(src, EAST)
					else
						if (step(src, EAST))
							step(src, SOUTH)
				else
					if (direct & 8)
						if (step(src, SOUTH))
							step(src, WEST)
						else
							if (step(src, WEST))
								step(src, SOUTH)
	else
		. = ..()

		if(istype(src,/mob))
			var/mob/a = src
			if(a.mind)
				a.mind.log.updateloc(loc.loc,src)
	return

/atom/movable/verb/pull()
	set src in oview(1)

	if (!( usr ))
		return
	if (!( anchored ))
		usr.pulling = src
	return

/atom/verb/examine()
	set src in oview(12)	//make it work from farther away

	if (!( usr ))
		return
	usr << "This is \an [name]."
	usr << desc
	// *****RM
	//usr << "[name]: Dn:[density] dir:[dir] cont:[contents] icon:[icon] is:[icon_state] loc:[loc]"
	return


/client/North()
	..()

/client/South()
	..()

/client/West()
	..()

/client/East()
	..()

/client/Northeast()
	if (istype(mob, /mob/dead/observer) && mob.z > 1)
		mob.Move(locate(mob.x, mob.y, mob.z - 1))
	else if (istype(mob, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/M = mob
		if ((!M.current && M.loc.z > 1) || M.current.z > 1)
			AIMoveZ(UP, mob)
	else if(istype(mob, /mob/living/carbon))
		if (mob:back && istype(mob:back, /obj/item/weapon/tank/jetpack))
			mob:back:move_z(UP, mob)
		else if(isobj(mob.loc))
			mob.loc:relaymove(mob,UP)
		else
			mob:swap_hand()

/client/Southeast()
	var/obj/item/weapon/W = mob.equipped()
	if (istype(mob, /mob/dead/observer) && mob.z < 4)
		mob.Move(locate(mob.x, mob.y, mob.z + 1))
	else if (istype(mob, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/M = mob
		if ((!M.current && M.loc.z < 4) || M.current.z < 4)
			AIMoveZ(DOWN, mob)
	else if(istype(mob, /mob/living/carbon) && mob:back && istype(mob:back, /obj/item/weapon/tank/jetpack))
		mob:back:move_z(DOWN, mob)
	else if(isobj(mob.loc))
		mob.loc:relaymove(mob,DOWN)
	else if (W)
		W.attack_self(mob)

/client/Northwest()
	mob.drop_item_v()
	return

/client/Southwest()

/client/Center()
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	return

/client/Move(n, direct)
	if(istype(mob, /mob/dead))
		return mob.Move(n,direct)
	if (moving)
		return 0
	if (world.time < move_delay)
		return
	if (!( mob ))
		return
	if (mob.stat == 2)
		return
	if(istype(mob, /mob/living/silicon/ai))
		return AIMove(n,direct,mob)
	if (mob.monkeyizing)
		return

	var/is_monkey = istype(mob, /mob/living/carbon/monkey)
	if (locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list(  )
		if (istype(mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.l_hand
			grabbing += G.affecting
		if (istype(mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if (G.state == 1)
				if (!( grabbing.Find(G.assailant) ))
					del(G)
			else
				if (G.state == 2)
					move_delay = world.time + 10
					if ((prob(25) && (!( is_monkey ) || prob(25))))
						mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
						del(G)
					else
						return
				else
					if (G.state == 3)
						move_delay = world.time + 10
						if ((prob(5) && !( is_monkey ) || prob(25)))
							mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
							del(G)
						else
							return
	if (mob.canmove)

		if(mob.m_intent == "face")
			mob.dir = direct

		var/j_pack = 0
		if ((istype(mob.loc, /turf/space)))
			if (!( mob.restrained() ))
				if (!( (locate(/obj/grille) in oview(1, mob)) || (locate(/turf/simulated) in oview(1, mob)) || (locate(/obj/lattice) in oview(1, mob)) ))
					if (istype(mob.back, /obj/item/weapon/tank/jetpack))
						var/obj/item/weapon/tank/jetpack/J = mob.back
						j_pack = J.allow_thrust(0.01, mob)
						if(j_pack)
							mob.inertia_dir = 0
						if (!( j_pack ))
							return 0
					else
						return 0
			else
				return 0


		if (isturf(mob.loc))
			move_delay = world.time
			if ((j_pack && j_pack < 1))
				move_delay += 5
			switch(mob.m_intent)
				if("run")
					if (mob.drowsyness > 0)
						move_delay += 6
					move_delay += 1
				if("face")
					mob.dir = direct
					return
				if("walk")
					move_delay += 4


			move_delay += mob.movement_delay()

			if (mob.restrained())
				for(var/mob/M in range(mob, 1))
					if (((M.pulling == mob && (!( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
						src << "\blue You're restrained! You can't move!"
						return 0
			if(ishuman(mob))
				var/datum/organ/external/lleg = mob.organs["l_leg"]
				var/datum/organ/external/rleg = mob.organs["r_leg"]
				if(lleg.broken && rleg.broken)
					src << "\blue You feel a sharp pain as you try to walk!"
					mob.paralysis += 10
					return 0
				if(lleg.broken || rleg.broken)
					if(mob.r_hand)
						if(istype(mob.r_hand,/obj/item/weapon/cane) || istype(mob.l_hand,/obj/item/weapon/cane))
							src << "\blue You able to support yourself on the [mob.r_hand]"
					else if(prob(50))
						src << "\blue You feel a sharp pain as you try to walk!"
						mob.paralysis += 10
						return 0
			moving = 1
			if (locate(/obj/item/weapon/grab, mob))
				move_delay = max(move_delay, world.time + 7)
				var/list/L = mob.ret_grab()
				if (istype(L, /list))
					if (L.len == 2)
						L -= mob
						var/mob/M = L[1]
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
					else
						for(var/mob/M in L)
							M.other_mobs = 1
							if (mob != M)
								M.animate_movement = 3
						for(var/mob/M in L)
							spawn( 0 )
								step(M, direct)
								return
							spawn( 1 )
								M.other_mobs = null
								M.animate_movement = 2
								return
			else
				if(mob.confused)
					step(mob, pick(cardinal))
				else if(mob.staggering)
					Stagger(mob,direct)
				. = ..()
			moving = null
			return .
		else
			if (isobj(mob.loc) || ismob(mob.loc))
				var/atom/O = mob.loc
				if (mob.canmove)
					return O.relaymove(mob, direct)
	else
		return
	return

/client/New()
	if(findtextEx(key, "Telnet @"))
		src << "Sorry, this game does not support Telnet."
		del(src)
	var/isbanned = CheckBan(src)
	if (isbanned)
		log_access("Failed Login: [src] - Banned")
		message_admins("\blue Failed Login: [src] - Banned")
		alert(src,"You have been banned.\nReason : [isbanned]","Ban","Ok")
		del(src)
	if(IsGuestKey(src.key))
		alert(src,"Baystation12 doesn't allow guest accounts to play. Please go to http:\\www.byond.com and register for a key.","Guest","Ok")
		del(src)
	if (((world.address == address || !(address)) && !(host)))
		host = key
		world.update_status()

	..()
	//	src << "<div class=\"motd\">[join_motd]</div>"


	//////////////Added by Strumpetplaya - Alert Changes - Draw current lights for new players joining
	//If this is causing lag, may need to change the light spawning code to create a list to use instead
	//of using the world list.
	for(var/obj/alertlighting/firelight/F in world)
		var/image/imagelight = image('alert.dmi',F,icon_state = "blue")
		src << imagelight
	for(var/obj/alertlighting/atmoslight/G in world)
		var/image/imagelight = image('alert.dmi',G,icon_state = "blueold")
		src << imagelight
	//////////////End Strumpetplaya Add

//new admin bit - Nannek


	if (admins.Find(ckey))
		holder = new /obj/admins(src)
		holder.rank = admins[ckey]
		update_admins(admins[ckey])

	if (ticker && ticker.mode && ticker.mode.name == "Sandbox")
		mob.CanBuild()
		if(holder  && (holder.level >= 3))
			verbs += /mob/proc/Delete

/client/Del()
	spawn(0)
		if(holder)
			del(holder)
	return ..()

/mob/proc/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && istype(buckled, /obj/stool/bed)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/proc/updatehealth()
	if (!nodamage)
		health = health_full - (oxyloss + toxloss + fireloss + bruteloss + halloss + organbruteloss)
	else
		health = health_full
		stat = 0

//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human) && (!mutations & 2))
		if(src.mutations & mShock)
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/datum/organ/external/affecting = null
		var/extradam = 0	//added to when organ is at max dam
		for(var/A in H.organs)
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /datum/organ/external))	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey) && (!mutations & 2))
		var/mob/living/carbon/monkey/M = src
		M.fireloss += burn_amount
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [bodytemperature] ~ [temperature]"
	return temperature

/mob/proc/gib(give_medal)
	if (istype(src, /mob/dead/observer))
		gibs(loc, virus)
		return
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	if(ishuman(src))
		animation = new(loc)
		animation.icon_state = "blank"
		animation.icon = 'mob.dmi'
		animation.master = src
		flick("gibbed", animation)

	if (client && mind)
		var/mob/dead/observer/newmob

		newmob = new/mob/dead/observer(src.loc,src)
		src:client:mob = newmob
		mind.transfer_to(newmob)
		if(istype(src,/mob/living/silicon/robot))	//Robots don't gib like humans! - Strumpetplaya
			robogibs(loc,virus)
		else
			gibs(loc, virus)

	else if (!client)
		if(istype(src,/mob/living/silicon/robot))
			robogibs(loc,virus)
		else
			gibs(loc, virus,src:virus2)
	var/mob/M = src
	for(var/obj/item/W in M)
		if (istype(W,/obj/item))
			M.u_equip(W)
			if (M.client)
				M.client.screen -= W
			if (W)
				W.loc = M.loc
				W.dropped(M)
				W.layer = initial(W.layer)

	sleep(15)
	del(src)

/mob/proc/get_contents()
	var/list/L = list()
	L += contents
	for(var/obj/item/weapon/storage/S in contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/mob/proc/check_contents_for(A)
	var/list/L = list()
	L += contents
	for(var/obj/item/weapon/storage/S in contents)
		L += S.return_inv()
	for(var/obj/item/weapon/secstorage/S in contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0
/mob/proc/check_contents_for_reagent(A)
	var/list/L = list()
	L += contents
	for(var/obj/item/weapon/storage/S in contents)
		L += S.return_inv()
	for(var/obj/item/weapon/secstorage/S in contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()

	for(var/obj/item/weapon/reagent_containers/B in L)
		for(var/datum/reagent/R in B.reagents.reagent_list)
			if(R.type == A)
				return 1
	return 0

// adds a dizziness amount to a mob
// use this rather than directly changing var/dizziness
// since this ensures that the dizzy_process proc is started
// currently only humans get dizzy

// value of dizziness ranges from 0 to 1000
// below 100 is not dizzy

/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


// dizzy process - wiggles the client's pixel offset over time
// spawned from make_dizzy(), will terminate automatically when dizziness gets <100
// note dizziness decrements automatically in the mob's Life() proc.
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// jittery process - wiggles the client's pixel offset over time
// spawned from make_jittery(), will terminate automatically when jitteriness gets <100
// note jitteriness decrements automatically in the mob's Life() proc.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/Stat()
	..()

	statpanel("Status")

	if (client && client.holder)
		stat(null, "([x], [y], [z])")
		stat(null, "CPU: [world.cpu]")

/client/proc/station_explosion_cinematic()
	if(mob)
		var/mob/M = mob
		M.loc = null // HACK, but whatever, this works
		var/obj/screen/boom = M.hud_used.station_explosion
		M.client.screen += boom
		if(ticker)
			switch(ticker.mode.name)
				if("nuclear emergency")
					flick("start_nuke", boom)
				if("AI malfunction")
					flick("start_malf", boom)
				else
					boom.icon_state = "start"
		sleep(40)
		M << sound('explosionfar.ogg')
		boom.icon_state = "end"
		flick("explode", boom)
		sleep(40)
		if(ticker)
			switch(ticker.mode.name)
				if("nuclear emergency")
					boom.icon_state = "loss_nuke"
				if("AI malfunction")
					boom.icon_state = "loss_malf"
				else
					boom.icon_state = "loss_general"


/mob/proc/log_m(var/text)
	if(mind)
		mind.log.log_m(text,src)