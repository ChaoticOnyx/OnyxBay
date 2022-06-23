/datum/configuration_section/admin
	name = "admin"

	var/admin_legacy_system = TRUE
	var/allow_admin_ooccolor = TRUE
	var/allow_admin_jump = TRUE
	var/allow_admin_rev = TRUE
	var/allow_admin_spawning = TRUE
	var/autostealth = 0
	var/popup_admin_pm = FALSE
	var/forbid_singulo_possession = FALSE
	var/debug_paranoid = FALSE
	var/delist_when_no_admins = FALSE

/datum/configuration_section/admin/load_data(list/data)
	CONFIG_LOAD_BOOL(admin_legacy_system, data["admin_legacy_system"])
	CONFIG_LOAD_BOOL(allow_admin_ooccolor, data["allow_admin_ooccolor"])
	CONFIG_LOAD_BOOL(allow_admin_jump, data["allow_admin_jump"])
	CONFIG_LOAD_BOOL(allow_admin_rev, data["allow_admin_rev"])
	CONFIG_LOAD_BOOL(allow_admin_spawning, data["allow_admin_spawning"])
	CONFIG_LOAD_NUM(autostealth, data["autostealth"])
	CONFIG_LOAD_BOOL(popup_admin_pm, data["popup_admin_pm"])
	CONFIG_LOAD_BOOL(forbid_singulo_possession, data["forbid_singulo_possession"])
	CONFIG_LOAD_BOOL(debug_paranoid, data["debug_paranoid"])
	CONFIG_LOAD_BOOL(delist_when_no_admins, data["delist_when_no_admins"])
