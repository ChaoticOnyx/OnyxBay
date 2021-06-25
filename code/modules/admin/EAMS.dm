// Epic Anti-Multiaccount System

/datum/eams_info
	var/loaded 			= FALSE
	var/whitelisted 	= FALSE

	var/ip
	var/ip_as
	var/ip_isp
	var/ip_org
	var/ip_country
	var/ip_countryCode
	var/ip_region
	var/ip_regionCode
	var/ip_city
	var/ip_lat
	var/ip_lon
	var/ip_timezone
	var/ip_zip
	var/ip_reverse
	var/ip_mobile
	var/ip_proxy

SUBSYSTEM_DEF(eams)
	name = "EAMS"
	init_order = SS_INIT_EAMS
	flags = SS_NO_FIRE

	var/__allowed_countries = list("RU", "AM", "AZ", "BY", "KZ", "KG", "MB", "TI", "UZ", "UA", "TM")
	var/__acceptable_count_of_errors = 5

	var/__active = FALSE
	var/__errors_counter = 0

	var/list/__postponed_clients = new

/datum/controller/subsystem/eams/Initialize(timeofday)
	if(!config.eams)
		log_debug("EAMS is disabled by configuration!")
		return ..()

	if(!config.sql_enabled)
		log_debug("EAMS system is disabled with SQL!")
		return ..()

	Toggle()
	return ..()

/datum/controller/subsystem/eams/proc/Toggle(mob/user)
	if (!initialized && user)
		to_chat(user, SPAN("adminnotice", "Wait until EAMS initialized!"), confidential = TRUE)
		return
	if(!__active && !establish_db_connection())
		to_chat(user, SPAN("adminnotice", "EAMS can't be enabled because there is no DB connection!"), confidential = TRUE)
		return

	__active = !__active
	if (__active)
		var/list/clients_to_check = __postponed_clients.Copy()
		__postponed_clients.Cut()
		for (var/client/C in clients_to_check)
			CollectDataForClient(C)
			CHECK_TICK
	log_debug("EAMS is [__active ? "enabled" : "disabled"]!")
	return __active

/datum/controller/subsystem/eams/proc/GetPlayerPanelButton(datum/admins/source, client/player)
	var/result = {"<br><br><b>EAMS whitelisted:</b>
		[player.eams_info.whitelisted ? "<A href='?src=\ref[src];removefromwhitelist=\ref[player]'>Yes</A>" : "<A href='?src=\ref[src];addtowhitelist=\ref[player]'>No</A>"]
		"}
	return result

/datum/controller/subsystem/eams/Topic(href, href_list)
	var/mob/user = usr

	if(!check_rights(0, FALSE, user))
		href_exploit(user.ckey, href)
		return

	var/client/player = null
	if (href_list["addtowhitelist"])
		player = locate(href_list["addtowhitelist"])
		__SetClientWhitelistedValue(player, TRUE)
	else if (href_list["removefromwhitelist"])
		player = locate(href_list["removefromwhitelist"])
		__SetClientWhitelistedValue(player, FALSE)
	else
		return

	if (user.client)
		user.client.holder.show_player_panel(player.mob) // update panel

/datum/controller/subsystem/eams/proc/__DBError()
	__active = FALSE
	log_and_message_admins("The Database Error has occured! EAMS was deactivated!", 0)

/datum/controller/subsystem/eams/proc/__IsClientWhitelisted(client/C)
	ASSERT(istype(C))

	if (!__active)
		return FALSE

	if(!establish_db_connection())  // Database isn't connected
		__DBError()
		return FALSE

	var/DBQuery/query = sql_query("SELECT ckey FROM whitelist_ckey WHERE ckey = $ckey LIMIT 0,1", dbcon, list(ckey = C.ckey))
	if (!query)
		__DBError()
		return FALSE

	if (query.NextRow())
		return TRUE

	return FALSE

/datum/controller/subsystem/eams/proc/__SetClientWhitelistedValue(client/C, value)
	ASSERT(istype(C))

	if (!__active)
		return FALSE

	if(!establish_db_connection())  // Database isn't connected
		__DBError()
		return FALSE

	var/DBQuery/query = null

	if (value)
		query = sql_query("INSERT INTO whitelist_ckey (ckey) VALUES ($ckey)", dbcon, list(ckey = C.ckey))
	else
		query = sql_query("DELETE FROM whitelist_ckey WHERE ckey=$ckey", dbcon, list(ckey = C.ckey))

	if (!query)
		__DBError()
		return FALSE

	if (value)
		log_and_message_admins("added [C.ckey] to EAMS whitelist!")
	else
		log_and_message_admins("removed [C.ckey] from EAMS whitelist!")

	C.eams_info.whitelisted = value
	return TRUE

/datum/controller/subsystem/eams/proc/__LoadResponseFromCache(ip)
	ASSERT(istext(ip))

	if(!establish_db_connection())  // Database isn't connected
		__DBError()
		return FALSE

	var/DBQuery/query = sql_query("SELECT response FROM eams_cache WHERE ip = $ip LIMIT 1", dbcon, list(ip = ip))

	if (!query)
		__DBError()
		return FALSE

	if (!query.NextRow())
		return FALSE

	return json_decode(query.item[1])

/datum/controller/subsystem/eams/proc/__CacheResponse(ip, raw_response)
	ASSERT(istext(ip))
	ASSERT(istext(raw_response))

	if(!establish_db_connection())  // Database isn't connected
		__DBError()
		return FALSE

	var/DBQuery/query = sql_query("INSERT INTO eams_cache(ip, response) VALUES ($ip, $raw_response)", dbcon, list(ip = ip, raw_response = raw_response))

	if (!query)
		__DBError()
		return FALSE

	return TRUE

/datum/controller/subsystem/eams/proc/CollectDataForClient(client/C)
	ASSERT(istype(C))

	if(!__active)
		__postponed_clients.Add(C)
		return

	C.eams_info.whitelisted = __IsClientWhitelisted(C)

	if(!C.address || C.address == "127.0.0.1") // host
		return

	var/list/response = __LoadResponseFromCache(C.address)
	if(response)
		log_debug("EAMS data for [C] ([C.address]) is loaded from cache!")

	while(!response && __active && __errors_counter < __acceptable_count_of_errors)
		var/list/http = world.Export("http://ip-api.com/json/[C.address]?fields=262143")

		if(!http)
			log_and_message_admins("EAMS could not check [C.key]: connection failed")
			__errors_counter += 1
			sleep(2) // If error occured, let's wait until it will be fixed ;)
			continue

		var/raw_response = file2text(http["CONTENT"])

		try
			response = json_decode(raw_response)
		catch (var/exception/e)
			log_and_message_admins("EAMS could not check [C.key] due JSON decode error, EAMS will not be disabled! JSON decode error: [e.name]")
			return

		if(response["status"] == "fail")
			log_and_message_admins("EAMS could not check [C.key] due request error, EAMS will not be disabled! CheckIP response: [response["message"]]")
			return

		log_debug("EAMS data for [C] ([C.address]) is loaded from external API!")
		__CacheResponse(C.address, raw_response)

	if(__errors_counter >= __acceptable_count_of_errors && __active)
		log_and_message_admins("EAMS was disabled due connection errors!")
		__active = FALSE
		return

	C.eams_info.ip             = C.address
	C.eams_info.ip_as          = response["as"]
	C.eams_info.ip_isp         = response["isp"]
	C.eams_info.ip_org         = response["org"]
	C.eams_info.ip_country     = response["country"]
	C.eams_info.ip_countryCode = response["countryCode"]
	C.eams_info.ip_region      = response["regionName"]
	C.eams_info.ip_regionCode  = response["region"]
	C.eams_info.ip_city        = response["city"]
	C.eams_info.ip_lat         = response["lat"]
	C.eams_info.ip_lon         = response["lon"]
	C.eams_info.ip_timezone    = response["timezone"]
	C.eams_info.ip_zip         = response["zip"]
	C.eams_info.ip_reverse     = response["reverse"]
	C.eams_info.ip_mobile      = response["mobile"]
	C.eams_info.ip_proxy       = response["proxy"]

	C.eams_info.loaded = TRUE
	return

//
//	Check for access before joining the game
//
/datum/controller/subsystem/eams/proc/CheckForAccess(client/C)
	ASSERT(istype(C))
	if (!__active)
		return TRUE

	if(!C.address || C.holder) // admin or host
		return TRUE

	if (C.eams_info.whitelisted) // check whitelist
		return TRUE

	if (C.eams_info.loaded)
		if ((C.eams_info.ip_countryCode in __allowed_countries) && !C.eams_info.ip_proxy)
			return TRUE

		// Bad IP and player isn't whitelisted.. so create a warning
		if (C.eams_info.ip_country == "")
			C.eams_info.ip_country = "unknown"

		to_chat(C, SPAN_WARNING("You were blocked by EAMS! Please, contact Administrators."), confidential = TRUE)
		log_and_message_admins("Blocked by EAMS: [C.key] ([C.address]) connected from [C.eams_info.ip_country] ([C.eams_info.ip_countryCode])", 0)

		return FALSE

	log_and_message_admins("EAMS failed to load info for [C.key]", 0)
	return TRUE

//
//	Toggle Verb
//

/client/proc/EAMS_toggle()
	set category = "Server"
	set name = "Toggle EAMS"

	if (!establish_db_connection())
		to_chat(usr, SPAN("adminnotice", "The Database is not connected!"), confidential = TRUE)
		return

	var/eams_status = SSeams.Toggle()
	log_and_message_admins("has [eams_status ? "enabled" : "disabled"] the Epic Anti-Multiaccount System!")
