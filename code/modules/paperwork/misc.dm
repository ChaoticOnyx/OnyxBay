// Some premade papers lies here.

/obj/item/weapon/paper/eng_wires
	name = "Airlock Wires"

/obj/item/weapon/paper/eng_wires/Initialize()
	. = ..()
	var/list/airlock_wires = same_wires[/obj/machinery/door/airlock].Copy()

	var/message = ""
	message += "\[center]\[large]There is some information about standart airlock wires:\[/large]"

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
		message += "\[br]\[i][wire_color]\[/i] - [wire_to_wire_purpose_list[num2text(airlock_num)]]"
	message += "\[/center]"
	set_content(message)
	make_readonly()

/obj/item/weapon/paper/trade_lic
	name = "Trade License"
	icon_state = "trade_license"
	item_state = "trade_license"
	var/fake_chance = 15
	var/dest_station = "NSS Exodus"
	var/possible_mis = list("nt_code","org_code","date", "dest","department")
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
	 "Snail Lovers Union")
	var/another_stations = list("NSV Caduceus",\
	  "NSV Luna", "NTV Sierra Otago",\
	  "NTV Millenium","NTV Duke",\
	  "NTV Verum","NHV Savior",\
	  "NSV Preserver","NSS Avalon",\
	  "NSS Orion","NSS Ontigo",\
	  "NSS Redemption","NSS Zagreus")
	var/trade_category = list("Продовольствие" = 100,\
	"Предметы одежды" = 100, "Сырье и материалы" = 100,\
	"Медикаменты" = 90, "Личные вещи и аксессуары" = 90,\
	"Инженерное оборудование для работы в пределах станции" = 75,\
	"Медицинское оборудование для работы в пределах станции" = 75,\
	"Исследовательское оборудование" = 75,\
	"Скафандры и иное оборудование, предназначенное для проведения работ в открытом космосе" = 50,\
	"Антиквариат" = 50, "Домашние питомцы" = 50, \
	"Мелкокалиберное огнестрельное или слабое энергетическое оружие" = 5, \
	"Крупнокалиберное огнестрельное или мощное энергетическое оружие" = 0.1,\
	"Взрывчатые или сильногорючие вещества, гранаты, в том числе нестандартного действия" = 0.1)


/obj/item/weapon/paper/trade_lic/Initialize()
	. = ..()
	var/department = pick(true_departaments)
	var/org_name = pick(org_names)
	var/date = list("day" = rand(1,30), "month" = rand(1,12), "year" = rand(2562,2564), "dur" = rand(3,5))
	var/nt_code = "[rand(100,999)]-[rand(100,999)]-[rand(100,999)]"
	var/org_code = "[rand(1,999)]-[rand(1,999)]-[rand(1,999)]"
	if(prob(fake_chance))
		var/mistake = pick(possible_mis)
		switch(mistake)
			if("nt_code")
				nt_code = "[rand(1000,9999)]-[rand(100,999)]-[rand(999,99999)]"
			if("org_code")
				org_code = "[rand(100,999)]-[rand(1000,9999)]-[rand(100,999)]"
			if("date")
				date = list("day" = rand(1,37), "month" = rand(1,13), "year" = rand(2565), "dur" = rand(3,10))
			if("dest")
				dest_station = pick(another_stations)
			if("department")
				department = pick(fake_departaments)

	var/message = ""
	message += "\[center]\[large]Разрешение на торговлю\[/large]\[/center]"
	message += "\[center]\[large]\[logo]\[/large]\[/center]"
	message += "\[small]Выдана агентом [pick(GLOB.first_names_female)] [pick(GLOB.last_names)] от лица [department]"
	message += "\[br]Код агента: [nt_code]\[br] Код организации: [org_code]"
	message += "\[br]Дата выдачи: [date["day"]].[date["month"]].[date["year"]]\[br] Срок действия: [date["dur"]] лет"
	message += "\[hr]"
	message += "Данная лицензия дает разрешение всем сотрудникам торговой \
	 компании [org_name] обслуживать станцию [dest_station] корпорации НаноТрейзен, осуществляя услуги по \
	 сбыту и приобретению перечисленных категорий товара:"
	message += "\[small]"
	for(var/tr_cat in trade_category)
		if(prob(trade_category[tr_cat]))
			message += "\[br]\[b][tr_cat]\[/b]"
	// TODO: Добавить печати
	set_content(message)
	make_readonly()
