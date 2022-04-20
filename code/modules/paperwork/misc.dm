/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes as specified, the offender is sentenced to:\[br]\[br]"

/obj/item/paper/crumpled
	name = "paper scrap"
	crumpled = TRUE
	dynamic_icon = TRUE

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/eng_wires
	name = "Airlock Wires"
	readonly = TRUE

/obj/item/paper/eng_wires/Initialize()
	var/list/airlock_wires = same_wires[/obj/machinery/door/airlock].Copy()

	info = ""
	info += "\[center]\[large]There is some information about standart airlock wires:\[/large]\[/center]"

	var/list/wire_to_wire_purpose_list = list(
		num2text(AIRLOCK_WIRE_DOOR_BOLTS) = "Door bolts wire",
		num2text(AIRLOCK_WIRE_IDSCAN) = "ID scan wire",
		num2text(AIRLOCK_WIRE_MAIN_POWER1) = "First Power wire",
		num2text(AIRLOCK_WIRE_MAIN_POWER2) = "Second Power wire",
		num2text(AIRLOCK_WIRE_BACKUP_POWER1) = "First Backup Power wire",
		num2text(AIRLOCK_WIRE_BACKUP_POWER2) = "Second Backup Power wire",
		num2text(AIRLOCK_WIRE_OPEN_DOOR) = "Open door wire",
		num2text(AIRLOCK_WIRE_AI_CONTROL) = "AI control wire",
		num2text(AIRLOCK_WIRE_ELECTRIFY) = "Electrify door wire",
		num2text(AIRLOCK_WIRE_SAFETY) = "Door safety mechanism power wire",
		num2text(AIRLOCK_WIRE_SPEED) = "Door timing mechanism power wire",
		num2text(AIRLOCK_WIRE_LIGHT) = "Door bolt lights power wire"
		)

	for(var/wire_color in airlock_wires)
		var/airlock_num = airlock_wires[wire_color]
		info += "\[br]\[i][wire_color]\[/i] - [wire_to_wire_purpose_list[num2text(airlock_num)]]"
	. = ..()

/obj/item/paper/exodus_armory
	name = "armory inventory"
	readonly = TRUE

/obj/item/paper/exodus_armory/Initialize()
	info = "\[center]\[logo]\[br]\[b]\[large][station_name()]\[/large]\[/b]\[br]\[i]\[date]\[/i]\[br]\[i]Armoury Inventory - Revision \[field]\[/i]\[/center]\[hr]\[center]Armoury\[/center]\[list]\[*]\[b]Deployable barriers\[/b]: 4\[*]\[b]Biohazard suit(s)\[/b]: 1\[*]\[b]Biohazard hood(s)\[/b]: 1\[*]\[b]Face Mask(s)\[/b]: 1\[*]\[b]Extended-capacity emergency oxygen tank(s)\[/b]: 1\[*]\[b]Bomb suit(s)\[/b]: 1\[*]\[b]Bomb hood(s)\[/b]: 1\[*]\[b]Security officer's jumpsuit(s)\[/b]: 1\[*]\[b]Brown shoes\[/b]: 1\[*]\[b]Handcuff(s)\[/b]: 14\[*]\[b]R.O.B.U.S.T. cartridges\[/b]: 7\[*]\[b]Flash(s)\[/b]: 4\[*]\[b]Can(s) of pepperspray\[/b]: 4\[*]\[b]Gas mask(s)\[/b]: 6\[field]\[/list]\[hr]\[center]Secure Armoury\[/center]\[list]\[*]\[b]LAEP90 Perun energy guns\[/b]: 4\[*]\[b]Stun Revolver(s)\[/b]: 1\[*]\[b]Taser Gun(s)\[/b]: 4\[*]\[b]Stun baton(s)\[/b]: 4\[*]\[b]Airlock Brace\[/b]: 3\[*]\[b]Maintenance Jack\[/b]: 1\[*]\[b]Stab Vest(s)\[/b]: 3\[*]\[b]Riot helmet(s)\[/b]: 3\[*]\[b]Riot shield(s)\[/b]: 3\[*]\[b]Corporate security heavy armoured vest(s)\[/b]: 4\[*]\[b]NanoTrasen helmet(s)\[/b]: 4\[*]\[b]Portable flasher(s)\[/b]: 3\[*]\[b]Tracking implant(s)\[/b]: 4\[*]\[b]Chemical implant(s)\[/b]: 5\[*]\[b]Implanter(s)\[/b]: 2\[*]\[b]Implant pad(s)\[/b]: 2\[*]\[b]Locator(s)\[/b]: 1\[field]\[/list]\[hr]\[center]Tactical Equipment\[/center]\[list]\[*]\[b]Implanter\[/b]: 1\[*]\[b]Death Alarm implant(s)\[/b]: 7\[*]\[b]Security radio headset(s)\[/b]: 4\[*]\[b]Ablative vest(s)\[/b]: 2\[*]\[b]Ablative helmet(s)\[/b]: 2\[*]\[b]Ballistic vest(s)\[/b]: 2\[*]\[b]Ballistic helmet(s)\[/b]: 2\[*]\[b]Tear Gas Grenade(s)\[/b]: 7\[*]\[b]Flashbang(s)\[/b]: 7\[*]\[b]Beanbag Shell(s)\[/b]: 7\[*]\[b]Stun Shell(s)\[/b]: 7\[*]\[b]Illumination Shell(s)\[/b]: 7\[*]\[b]W-T Remmington 29x shotgun(s)\[/b]: 2\[*]\[b]NT Mk60 EW Halicon ion rifle(s)\[/b]: 2\[*]\[b]Hephaestus Industries G40E laser carbine(s)\[/b]: 4\[*]\[b]Flare(s)\[/b]: 4\[field]\[/list]\[hr]\[b]Warden (print)\[/b]:\[field]\[b]Signature\[/b]:\[br]"
	. = ..()

/obj/item/paper/exodus_cmo
	name = "outgoing CMO's notes"
	readonly = TRUE

/obj/item/paper/exodus_cmo/Initialize()
	info = "\[i]\[center]To the incoming CMO of [station_name()]:\[/i]\[/center]\[br]\[br]i wish you and your crew well. Do take note:\[br]\[br]\[br]The Medical Emergency Red Phone system has proven itself well. Take care to keep the phones in their designated places as they have been optimised for broadcast. The two handheld green radios (i have left one in this office, and one near the Emergency Entrance) are free to be used. The system has proven effective at alerting Medbay of important details, especially during power outages.\[br]\[br]I think I may have left the toilet cubicle doors shut. It might be a good idea to open them so the staff and patients know they are not engaged.\[br]\[br]The new syringe gun has been stored in secondary storage. I tend to prefer it stored in my office, but 'guidelines' are 'guidelines'.\[br]\[br]Also in secondary storage is the grenade equipment crate. I've just realised I've left it open - you may wish to shut it.\[br]\[br]There were a few problems with their installation, but the Medbay Quarantine shutters should now be working again  - they lock down the Emergency and Main entrances to prevent travel in and out. Pray you shan't have to use them.\[br]\[br]The new version of the Medical Diagnostics Manual arrived. I distributed them to the shelf in the staff break room, and one on the table in the corner of this room.\[br]\[br]The exam/triage room has the walking canes in it. I'm not sure why we'd need them - but there you have it.\[br]\[br]Emergency Cryo bags are beside the emergency entrance, along with a kit.\[br]\[br]Spare paper cups for the reception are on the left side of the reception desk.\[br]\[br]I've fed Runtime. She should be fine.\[br]\[br]\[br]\[center]That should be all. Good luck!\[/center]"
	. = ..()

/obj/item/paper/exodus_bartender
	name = "shotgun permit"
	readonly = TRUE
	info = "This permit signifies that the Bartender is permitted to posess this firearm in the bar, and ONLY the bar. Failure to adhere to this permit will result in confiscation of the weapon and possibly arrest."

/obj/item/paper/exodus_holodeck
	name = "holodeck disclaimer"
	readonly = TRUE
	info = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/item/paper/jungle_colt_note
	name = "note"
	readonly = TRUE
	info = "Director, this morning they tried to break through lockdown gate. We managed to push them back, but they'll return. One of the officers noticed someone lurking near the cave entrance, I'm afraid we'll have to blow up the tunnels. These are no ordinary mercenaries, sir, I think they are trying to get the speciments. \[br]\ I ran out of ammo on my way here, so I had to borrow your Colt Python. Find me at the research site when this all ends. Wish us luck. \[br]\ \[i]Security Chief Denster\[/i]  "

/obj/item/paper/workvisa
	name = "Sol Work Visa"
	desc = "A flimsy piece of laminated cardboard issued by the Sol Central Government."
	icon_state = "workvisa" //Has to be here or it'll assume default paper sprites.
	dynamic_icon = TRUE
	readonly = TRUE
	info = "\[center]\[b]\[large]Work Visa of the Sol Central Government\[/large]\[/b]\[/center]\[br]\[center]\[solcrest]\[br]\[br]\[i]\[small]Issued on behalf of the Secretary-General.\[/small]\[/i]\[/center]\[hr]\[br]This paper hereby permits the carrier to travel unhindered through Sol territories, colonies, and space for the purpose of work and labor."

/* Message from CC */
/obj/item/paper/psychoscope
	name = "paper - 'Psychoscope'"
	readonly = TRUE
	rawhtml = TRUE

/obj/item/paper/psychoscope/Initialize()
	. = ..()

	set_content("\[center]\[logo]\[BR]\[b]\[large]NanoTrasen's Research Directorate\[/large]\[/b]\[BR]\[h2]Psychoscope\[/h2]Greetings, Research Director. We provide [station_name()] with our new prototype of \the psychoscope. Since this moment you are responsible for the prototype and you must not let lose or damage it, or you will get reproval. We will await any discorveries, if you got one - send on a transport shuttles.\[h2]Remarks\[/h2]We permit any safe experiments on crew members that will be helpful in your researchings, for any invasive experiments you should get a permit from the subject and do it under medical surveillance, otherwise it will be regarded as a contravene of job's contract.")

/obj/item/paper/trade_lic
	name = "Trade License"
	desc = "A flimsy piece of laminated cardboard."
	icon_state = "trade_license"
	dynamic_icon = TRUE
	readonly = TRUE
	var/dest_station = ""
	var/possible_mis = list("nt_code", "org_code", "date", "dest", "department")
	var/true_departaments = list("NanoTrasen Supply Department", \
	 "NanoTrasen Trading Department",\
	 "NanoTrasen External Affairs Department",\
	 "NanoTrasen Trading Affairs Department",\
	 "NanoTrasen External Trading Department",\
	 "NanoTrasen Supply Affairs Department")
	var/fake_departaments = list("NanoTrosin Supply HeadQuarter", \
	 "NanoTrason License Department",\
	 "NanoTrasen Affairs Department For Traiders",\
	 "NanoTrasen Trading Union",\
	 "NanoTrasen Department",\
	 "NanoTrasen Supply Union")
	var/org_names = list("Salis & Mercury Trading Company",\
	 "Milky Way Trade Union",\
	 "Ben-Perzman Tradeband",\
	 "SteelGoose Supplies",\
	 "Brown Moose Trading Company",\
	 "Snail Lovers Union",\
	 "EpicSeven Supply Company",\
	 "Do Star Tradeband",\
	 "Goliath Intergalactic Shop")
	var/another_stations = list("NSV Caduceus",\
	  "NSV Luna",\
	  "NTV Sierra Otago",\
	  "NTV Millenium",\
	  "NTV Duke",\
	  "NTV Verum",\
	  "NHV Savior",\
	  "NSV Preserver",\
	  "NSS Avalon",\
	  "NSS Orion",\
	  "NSS Ontigo",\
	  "NSS Redemption",\
	  "NSS Zagreus")
	var/trade_category = list("Продовольствие" = 100, \
	"Предметы одежды" = 100,\
	"Сырье и материалы" = 100,\
	"Медикаменты" = 90,\
	"Личные вещи и аксессуары" = 90,\
	"Инженерное оборудование для работы в пределах станции" = 75,\
	"Медицинское оборудование для работы в пределах станции" = 75,\
	"Исследовательское оборудование" = 75,\
	"Скафандры и иное оборудование, предназначенное для проведения работ в открытом космосе" = 50,\
	"Антиквариат" = 50,\
	"Домашние питомцы" = 50,\
	"Мелкокалиберное огнестрельное или слабое энергетическое оружие" = 5,\
	"Крупнокалиберное огнестрельное или мощное энергетическое оружие" = 0.1,\
	"Взрывчатые или сильногорючие вещества, гранаты, в том числе нестандартного действия" = 0.1)


/obj/item/paper/trade_lic/Initialize()
	dest_station = "[station_name()]"
	var/department = pick(true_departaments)
	var/org_name = pick(org_names)
	var/date = list("day" = rand(1,30), "month" = rand(1,12), "year" = rand(2562,2564), "dur" = rand(3,5))
	var/nt_code = "[rand(100,999)]-[rand(100,999)]-[rand(100,999)]"
	var/org_code = "[rand(100,999)]-[rand(10,999)]-[rand(100,999)]"
	if(GLOB.merchant_illegalness)
		var/mistake = pick(possible_mis)
		switch(mistake)
			if("nt_code")
				nt_code = "[rand(1000,9999)]-[rand(100,999)]-[rand(999,99999)]"
			if("org_code")
				org_code = "[rand(100,999)]-[rand(1000,9999)]-[rand(100,999)]"
			if("date")
				date = list("day" = rand(1, 37), "month" = rand(1, 13), "year" = rand(2565), "dur" = rand(3, 10))
			if("dest")
				dest_station = pick(another_stations)
			if("department")
				department = pick(fake_departaments)

	info = ""
	info += "\[center]\[large]\[b]Разрешение на торговлю\[/b]\[/large]\[/center]"
	info += "\[center]\[large]\[bluelogo]\[/large]\[/center]"
	info += "\[small]Выдана агентом [pick(GLOB.first_names_female)] [pick(GLOB.last_names)] от лица [department]"
	info += "\[br]Код агента: [nt_code]\[br] Код организации: [org_code]"
	info += "\[br]Дата выдачи: [date["day"]].[date["month"]].[date["year"]]\[br] Срок действия: [date["dur"]] года\[/small]"
	info += "\[hr]"
	info += "\[small]Данная лицензия дает разрешение всем сотрудникам торговой \
	 компании \[i][org_name]\[/i] обслуживать станцию \[i][dest_station]\[/i] корпорации НаноТрейзен, осуществляя услуги по \
	 сбыту и приобретению перечисленных категорий товара:"
	info += "\[list]"
	for(var/tr_cat in trade_category)
		if(prob(trade_category[tr_cat]))
			info += "\[item]\[b][tr_cat]\[/b]\[/item]"
	info += "\[/list]"
	info += "\[i]This paper has been stamped with the [department] stamp.\[/i]"
	info += "\[br]\[i]This paper has been stamped with the [org_name] stamp.\[/i]"
	info += "\[/small]"
	. = ..()

/obj/item/paper/trade_lic/trade_guide
	name = "Trade License Template"
	dynamic_icon = FALSE

/obj/item/paper/trade_lic/trade_guide/Initialize()
	info = ""
	info += "Departments:\[small]\[list]"
	for(var/tr_deps in true_departaments)
		info += "\[item]\[b][tr_deps]\[/b]\[/item]"
	info += "\[/small]\[/list]"
	info += "NT departments codes: XXX-XXX-XXX\[br]"
	info += "Organizations codes: XXX-(XX or XXX)-XXX\[br]"
	. = ..()
