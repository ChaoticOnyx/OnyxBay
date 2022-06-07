/datum/event/money_hacker/polar/announce()
	var/message = "A brute force hack has been detected (in progress since [stationtime2text()]). The target of the attack is: Financial accounts, \
	without intervention this attack will succeed in approximately 10 minutes. Possible solutions: suspension of accounts, disabling NTnet server, \
	increase account security level. Notifications will be sent as updates occur."
	command_announcement.Announce(
		message,
		"[location_name()] Firewall Subroutines",
		zlevels = affecting_z,
		new_sound = 'sound/AI/polar/money_hack_announce.ogg'
	)

/datum/event/money_hacker/polar/end()
	var/list/datum/money_account/affected_accounts = list()
	for(var/datum/money_account/M in all_money_accounts)
		if(M.suspended)
			continue
		if(M.security_level >= 1)
			continue
		if(M.off_station)
			continue
		if(M.money <= 0)
			continue
		affected_accounts |= M

	if(ntnet_global?.check_function() && length(affected_accounts))
		//hacker wins
		var/target_name = pick("","yo brotha from anotha motha","el Presidente","chieF smackDowN")
		var/purpose = pick("Ne$ ---ount fu%ds init*&lisat@*n","PAY BACK YOUR MUM","Funds withdrawal","pWnAgE","l33t hax","liberationez")
		var/d1 = "31 December, 1999"
		var/d2 = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [rand(1000,3000)]"
		var/date = pick("", stationdate2text(), d1, d2)
		var/t1 = rand(0, 99999999)
		var/t2 = "[round(t1 / 36000)+12]:[(t1 / 600 % 60) < 10 ? add_zero(t1 / 600 % 60, 1) : t1 / 600 % 60]"
		var/time = pick("", stationtime2text(), t2)

		//create a taunting log entry
		spawn()
			var/amount = rand(1, length(affected_accounts))
			while(amount)
				var/datum/money_account/affected_account = pick_n_take(affected_accounts)
				var/datum/transaction/T = new()
				T.target_name = target_name
				T.purpose = purpose
				T.amount = -affected_account.money
				T.date = date
				T.time = time
				T.source_terminal = pick("","[pick("Biesel","New Gibson")] GalaxyNet Terminal #[rand(111,999)]","your mums place","nantrasen high CommanD")
				affected_account.do_transaction(T)
				amount--

		command_announcement.Announce(
			"The hack attempt has succeeded.",
			"[location_name()] Firewall Subroutines",
			zlevels = affecting_z,
			new_sound = 'sound/AI/polar/money_hack_loose_end.ogg'
		)
	else
		//crew wins
		command_announcement.Announce(
			"The attack has ceased, the affected accounts can now be brought online.",
			"[location_name()] Firewall Subroutines",
			zlevels = affecting_z,
			new_sound = 'sound/AI/polar/money_hack_win_end.ogg'
		)
