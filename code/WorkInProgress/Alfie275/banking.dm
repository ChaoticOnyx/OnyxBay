var/datum/banksystem/bank/sbank

/datum/banksystem/account
	var/aname
	var/PIN
	var/list/obj/item/weapon/money/monies = list()


/datum/banksystem/bank
	var/bname = "Space Bank"
	var/list/datum/banksystem/account/accounts = list()




/datum/banksystem/bank/New()
	postsetuphooks.Add(src)



/datum/banksystem/bank/proc/post_setup()
	for(var/mob/living/m in world)
		if(m.client)
			var/datum/banksystem/account/a = new
			a.aname = m.real_name
			a.PIN = rand(0,9)+(rand(0,9)*10)+(rand(0,9)*100)+(rand(0,9)*1000)
			var/obj/item/weapon/money/mon = new
			mon.value = 10000
			a.monies[mon.currency]=mon
			m.mind.memory += "<BR> Pin number: [a.PIN]"
			accounts[m.real_name]=a


/datum/banksystem/bank/proc/get_monies(var/name,var/PIN,var/currency,var/amount)
	if(accounts[name])
		var/datum/banksystem/account/a = accounts[name]
		if(a.PIN !=PIN)
			return "Wrong PIN"
		if(a.monies[currency])
			var/obj/item/weapon/money/monies = a.monies[currency]
			if(monies.value>=amount)
				var/obj/item/weapon/money/mon = new monies.type
				mon.value = amount
				monies.value-=amount
				return mon

	else
		return "No account of that name"