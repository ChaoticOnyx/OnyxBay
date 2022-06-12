
/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/suspended = 0
	var/off_station = FALSE
	var/security_level = BANK_SECURITY_MODERATE	// BANK_SECURITY_MINIMUM  - auto-identify from worn ID, require only account number
												// BANK_SECURITY_MODERATE - require manual login / account number and pin
												// BANK_SECURITY_MAXIMUM  - require card and manual login

/datum/money_account/proc/do_transaction(datum/transaction/T)
	money = max(0, money + T.amount)
	transaction_log += T

/datum/money_account/proc/get_balance()
	. = 0
	for(var/datum/transaction/T in transaction_log)
		if(T.purpose == "Account creation")
			continue
		T.sanitize_amount()
		. += T.amount

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/datum/transaction/New(_target, _purpose, _amount, _source)
	..()
	date = stationdate2text()
	time = stationtime2text()
	target_name = _target
	purpose = _purpose
	amount = _amount
	source_terminal = _source

/datum/transaction/proc/sanitize_amount() //some place still uses (number) for negative amounts and I can't find it
	if(!istext(amount))
		return

	// Check if the text is numeric.
	var/text = amount
	amount = text2num(text)

	// Otherwise, the (digits) thing is going on.
	if(!amount)
		var/regex/R = regex("\\d+")
		R.Find(text)
		amount = -text2num(R.match)

/proc/create_account(new_owner_name = "Default user", starting_funds = 0, obj/machinery/computer/account_database/source_db, _off_station)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 9999)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	M.off_station = _off_station
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(8,18)]"
		T.time = "[rand(0,24)]:[rand(11,59)]"
		T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		M.account_number = random_id("station_account_number", 111111, 999999)
	else
		T.source_terminal = source_db.machine_id

		M.account_number = next_account_number
		next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/t1 = "<b>Account details (confidential)</b><br><hr><br>"
		t1 += "<i>Account holder:</i> [M.owner_name]<br>"
		t1 += "<i>Account number:</i> [M.account_number]<br>"
		t1 += "<i>Account pin:</i> [M.remote_access_pin]<br>"
		t1 += "<i>Starting balance:</i> T[M.money]<br>"
		t1 += "<i>Date and time:</i> [stationtime2text()], [stationdate2text()]<br><br>"
		t1 += "<i>Creation terminal ID:</i> [source_db.machine_id]<br>"
		t1 += "<i>Authorised NT officer overseeing creation:</i> [source_db.held_card.registered_name]<br>"

		var/obj/item/paper/R = new /obj/item/paper(P)
		R.set_content( t1, "Account information: [M.owner_name]", TRUE)
		P.wrapped = R

		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/stamp
		R.overlays += stampoverlay
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	M.transaction_log.Add(T)
	all_money_accounts.Add(M)

	return M

/proc/charge_to_account(attempt_account_number, source_name, purpose, terminal_id, amount)
	var/datum/money_account/D = get_account(attempt_account_number)
	if(!D || D.suspended)
		return 0
	D.money = max(0, D.money + amount)

	//create a transaction log entry
	var/datum/transaction/T = new(source_name, purpose, amount, terminal_id)
	D.transaction_log.Add(T)

	return 1

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(attempt_account_number, attempt_pin_number, security_level_passed = 0)
	var/datum/money_account/D = get_account(attempt_account_number)
	if(D && D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number) )
		return D

/proc/get_account(account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D
