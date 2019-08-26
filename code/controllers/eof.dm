/datum/controller/subsystem/ticker/proc/pick_round_event()
	var/event_type = pick(typesof(/datum/round_event) - /datum/round_event)
	if (event_type)
		var/event = new event_type
		return event
	else
		log_debug("No valid /datum/round_events found.")

/datum/round_event
	var/id = "default"
	var/event_message = "You shouldn't have seen it."

/datum/round_event/proc/announce_event()
	to_world("<h1 class='alert'>Event of round:</h1>")
	to_world("<br><b>[event_message]</b><br>")
	return

/datum/round_event/proc/apply_event()
	return

/datum/round_event/without_light
	id = "withoutlight"
	event_message = "The station did not receive the heroes of this shift very favourably: the complete darkness accompanied them to their workplaces, and only the dim PDA flashlights lit the way. The staff has yet to return the station to a more or less working condition, as long as they do not have a problem with their determination."

/datum/round_event/without_light/apply_event()
	lightsout(0, 0)
	for(var/obj/item/device/flashlight/F)
		F.on = 0
		F.update_icon()

/datum/round_event/lack_of_energy
	id = "lackofenergy"
	event_message = "The absence of such a precious element as a supermattery crystal at the station on the outskirts is not such a big surprise. The corporation has raised another challenge to the engineers, who in turn tighten the wires with a heavy breath..."

/datum/round_event/lack_of_energy/apply_event()
	for(var/obj/machinery/power/supermatter/SM in world)
		qdel(SM)
	for(var/obj/machinery/the_singularitygen/LORDSINGULO in world)
		qdel(LORDSINGULO)

/datum/round_event/old_times
	id = "oldtimes"
	event_message = "The ghosts of the past drag the staff down, showing them what was unheard of. The station's waste in the person of the \"olds\" has decided to open the curtain of darkness to those who still have to find out and understand everything.."

/datum/round_event/old_times/apply_event()
	for(var/atom/movable/lighting_overlay/LO in world)
		LO.icon = 'icons/effects/lighting_overlay_tile.dmi'
		LO.update_overlay()
		CHECK_TICK

/datum/round_event/assclowns
	id = "assclowns"
	event_message = "Life is bananas. Time is pie. The essence is the HONK. On this wild shift, the members of the grey brotherhood decided to fold their clothes to raise the banner of absurdity and demonstrate the real meaning of \"Space Station\" to the plebians!"

/datum/round_event/ghetto_medbay
	id = "ghettomedbay"
	event_message = "NanoTrasen back on the line! Nothing will stop brave doctors from showing their competence again and proving that they are the best of their kind!.. Even despite the low budget."

/datum/round_event/ghetto_medbay/apply_event()
	for(var/area/medical/M in world)
		for(var/obj/item/weapon/storage/firstaid/o2/FO in M)
			var/obj/item/weapon/reagent_containers/syringe/inaprovaline/SI = new(FO.loc)
			SI.desc = "Who needs a oxygen deprivation first-aid kit?"
			qdel(FO)
		for(var/obj/item/weapon/reagent_containers/spray/sterilizine/SS in M)
			var/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/BV = new(SS.loc)
			BV.name = "Sterilizine"
			qdel(SS)
		for(var/obj/structure/morgue/SM in M)
			var/obj/structure/closet/coffin/CC = new(SM.loc)
			CC.name = "Morgue"
			CC.desc = "Why does it look like a coffin?"
			qdel(SM)
		for(var/obj/structure/closet/secure_closet/medical1/M1 in M)
			var/obj/structure/closet/wardrobe/medic_white/MW = new(M1.loc)
			MW.name = "Improvised Medical Closet"
			qdel(M1)
		for(var/obj/structure/closet/secure_closet/chemical/C in M)
			var/obj/structure/closet/wardrobe/medic_white/MW = new(C.loc)
			MW.name = "Improvised Chemical Closet"
			qdel(C)
		for(var/obj/item/clothing/glasses/hud/health/HH in M)
			var/obj/item/clothing/glasses/regular/GR = new(HH.loc)
			GR.desc = "Why are they without HUD?"
			qdel(HH)
		for(var/obj/structure/closet/secure_closet/medical_wall/SCMW in M)
			qdel(SCMW)
		for(var/obj/item/stack/material/phoron/MP in M)
			qdel(MP)
		for(var/obj/machinery/vending/medical/VM in M)
			qdel(VM)
		for(var/obj/item/weapon/storage/firstaid/regular/FAR in M)
			var/obj/item/device/healthanalyzer/HA = new(FAR.loc)
			HA.desc = "Where's my first aid kit?"
			qdel(FAR)
		for(var/obj/item/weapon/defibrillator/compact/loaded/DCL in M)
			qdel(DCL)
		for(var/obj/item/weapon/rig/medical/RM in M)
			qdel(RM)
		for(var/obj/structure/closet/radiation/CR in M)
			qdel(CR)
		for(var/obj/item/weapon/storage/firstaid/surgery/FAS in M)
			var/obj/item/weapon/storage/toolbox/mechanical/TM = new(FAS.loc)
			TM.name = "Surgery Kit"
			qdel(FAS)
		for(var/obj/machinery/bodyscanner/BS in M)
			qdel(BS)
		for(var/obj/machinery/body_scanconsole/BSC in M)
			qdel(BSC)
		for(var/obj/machinery/chemical_dispenser/CD in M)
			var/obj/machinery/chemical_dispenser/lower_budget/CDLB = new(CD.loc)
			CDLB.desc = "For some reason, without most chemicals."
			qdel(CD)
		for(var/obj/machinery/organ_printer/flesh/mapped/OP in M)
			qdel(OP)
		for(var/obj/machinery/sleeper/S in M)
			qdel(S)
		for(var/obj/item/bodybag/cryobag/CB in M)
			var/obj/item/bodybag/B = new(CB.loc)
			B.name = "Cryobag Replacement"
			B.desc = "You wouldn't have saved him anyway."
			qdel(CB)
		for(var/obj/item/weapon/scalpel/SC in M)
			var/obj/item/weapon/material/knife/K = new(SC.loc)
			K.name = "Improvised scalpel"
			qdel(SC)
		for(var/obj/machinery/resleever/RE in M)
			qdel(RE)
		for(var/obj/item/weapon/storage/firstaid/fire/FAF in M)
			var/obj/item/stack/medical/ointment/MO = new(FAF.loc)
			MO.desc = "Who needs a fire first-aid kit?"
			qdel(FAF)
		for(var/obj/item/weapon/storage/firstaid/toxin/FAT in M)
			var/obj/item/weapon/reagent_containers/syringe/antitoxin/SAT = new(FAT.loc)
			SAT.desc = "Who needs a toxin first-aid kit?"
			qdel(FAT)
		for(var/obj/item/weapon/reagent_containers/spray/cleaner/SC in M)
			var/obj/item/weapon/soap/deluxe/SD = new(SC.loc)
			SD.name = "Space Cleaner Soap Deluxe"
			SD.desc = "In 2563 someone need space cleaners?"
			qdel(SC)
	for(var/area/crew_quarters/medbreak/M in world)
		for(var/obj/item/weapon/reagent_containers/spray/cleaner/SC in M)
			var/obj/item/weapon/soap/deluxe/SD = new(SC.loc)
			SD.name = "Space Cleaner Soap Deluxe"
			SD.desc = "In 2563 someone need space cleaners?"
			qdel(SC)

/datum/round_event/clumpsy_dumbasses
	id = "clumpsydumbasses"
	event_message = "By a really wild coincidence, most of the staff makes a lot of effort to concentrate the flow of their thoughts, and even the targeting of those spend a huge amount of effort. As long as their heels are safe!"

/datum/round_event/clumpsy_dumbasses/apply_event()
	for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
		if(prob(69))
			H.mutations.Add(MUTATION_CLUMSY)

/datum/round_event/can_you_hear_me_major_tom
	id = "CANYOUHEARMEMAJTOM"
	event_message = "Absence of a specialized headset will never prevent the brave employee of NanoTrasen from working. At least they still have walkie-talkies..."

/datum/round_event/can_you_hear_me_major_tom/apply_event()
	for(var/obj/item/device/radio/headset/RH in world)
		qdel(RH)

/datum/round_event/partyhard
	id = "partyhard"
	event_message = "The future is long overdue. Unfortunately, the desire to burn the \"city\" with neon candles appeared only recently, as well as the opportunity for this."

/datum/round_event/partyhard/apply_event()
	for(var/obj/machinery/light/L in world)
		L.lightbulb.brightness_color = pick(COLOR_DEEP_SKY_BLUE, COLOR_PINK, COLOR_RED_LIGHT, COLOR_LIME, COLOR_RED, COLOR_PAKISTAN_GREEN, COLOR_VIOLET, COLOR_BLUE, COLOR_PALE_GREEN_GRAY, COLOR_LUMINOL, COLOR_GUNMETAL, COLOR_LIGHT_CYAN)
		L.on = L.powered()
		L.update_icon()

/datum/round_event/randomnames
	id = "randomnames"
	event_message = "Who would have thought that the people you had tea with just before you arrived at the station were completely unfamiliar to you. Just like you for them."

/datum/round_event/pussy_riot
	id = "pussyriot"
	event_message = "Today the Security Department is acting especially gently. This tenderness is expressed by the general attitude of the department...  As well as its equipment."

/datum/round_event/pussy_riot/apply_event()
	for(var/obj/item/weapon/melee/baton/B in world)
		B.color = COLOR_LIGHT_PINK
	for(var/obj/item/weapon/handcuffs/H in world)
		H.icon = 'icons/obj/pinkcuffs.dmi'
		H.icon_state = "pinkcuffs"
		H.update_icon()
	for(var/area/security/S in world)
		for(var/obj/machinery/light/L in S)
			L.lightbulb.brightness_color = COLOR_PINK
			L.on = L.powered()
			L.update_icon()
		for(var/obj/structure/table/T in S)
			T.color = COLOR_LIGHT_PINK
		for(var/obj/structure/bed/chair/C in S)
			C.color = COLOR_LIGHT_PINK
		for(var/obj/structure/window/W in S)
			W.color = COLOR_LIGHT_PINK
		for(var/obj/machinery/door/window/W in S)
			W.color = COLOR_LIGHT_PINK
		for(var/obj/machinery/door/airlock/A in S)
			A.color = COLOR_LIGHT_PINK

/datum/round_event/wherecams
    id = "wherecams"
    event_message = "idk"

/datum/round_event/wherecams/apply_event()
    for(var/obj/machinery/camera/C in world)
        qdel(C)

/datum/round_event/whereaccess
    id = "whereaccess"
    event_message = "idk"

/datum/round_event/whereaccess/apply_event()
    for(var/obj/machinery/door/airlock/A in world)
        A.req_access = list()
        A.req_one_access = list()
    for(var/obj/machinery/door/window/W in world)
        W.req_access = list()
        W.req_one_access = list()