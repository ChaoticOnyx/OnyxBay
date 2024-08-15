/datum/configuration_section/database
	name = "database"
	protection_state = PROTECTION_PRIVATE

	// MySQL configuration
	var/address
	var/port
	var/database
	var/login
	var/password

	// Feedback gathering sql connection
	var/feedback_database
	var/feedback_login
	var/feedback_password

	// Donations DB
	var/donation_address
	var/donation_port
	var/donation_database
	var/donation_login
	var/donation_pass

/datum/configuration_section/database/load_data(list/data)
	CONFIG_LOAD_STR(address, data["address"])
	CONFIG_LOAD_STR(port, data["port"])
	CONFIG_LOAD_STR(database, data["db"])
	CONFIG_LOAD_STR(login, data["login"])
	CONFIG_LOAD_STR(password, data["password"])

	CONFIG_LOAD_STR(feedback_database, data["feedback_database"])
	CONFIG_LOAD_STR(feedback_login, data["feedback_login"])
	CONFIG_LOAD_STR(feedback_password, data["feedback_password"])

	CONFIG_LOAD_STR(donation_address, data["donation_address"])
	CONFIG_LOAD_STR(donation_port, data["donation_port"])
	CONFIG_LOAD_STR(donation_database, data["donation_database"])
	CONFIG_LOAD_STR(donation_login, data["donation_login"])
	CONFIG_LOAD_STR(donation_pass, data["donation_pass"])
