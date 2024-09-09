/datum/configuration_section/admin
	name = "admin"

	var/allow_admin_ooccolor
	var/allow_admin_jump
	var/allow_admin_rev
	var/allow_admin_spawning
	var/autostealth
	var/popup_admin_pm
	var/forbid_singulo_possession
	var/debug_paranoid
	var/delist_when_no_admins
	var/promote_localhost
	var/admin_legacy_system

/datum/configuration_section/admin/load_data(list/data)
	CONFIG_LOAD_BOOL(allow_admin_ooccolor, data["allow_admin_ooccolor"])
	CONFIG_LOAD_BOOL(allow_admin_jump, data["allow_admin_jump"])
	CONFIG_LOAD_BOOL(allow_admin_rev, data["allow_admin_rev"])
	CONFIG_LOAD_BOOL(allow_admin_spawning, data["allow_admin_spawning"])
	CONFIG_LOAD_NUM(autostealth, data["autostealth"])
	CONFIG_LOAD_BOOL(popup_admin_pm, data["popup_admin_pm"])
	CONFIG_LOAD_BOOL(forbid_singulo_possession, data["forbid_singulo_possession"])
	CONFIG_LOAD_BOOL(debug_paranoid, data["debug_paranoid"])
	CONFIG_LOAD_BOOL(delist_when_no_admins, data["delist_when_no_admins"])
	CONFIG_LOAD_BOOL(promote_localhost, data["promote_localhost"])
	CONFIG_LOAD_BOOL(admin_legacy_system, data["admin_legacy_system"])
