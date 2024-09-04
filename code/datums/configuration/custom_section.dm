/datum/configuration_section/custom
	name = "custom"

	/// sprite_type = list(/datum/custom_sprite, ...)
	var/list/sprites = list()

	/// ckey = list(/datum/custom_item, ...)
	var/list/items = list()

/datum/configuration_section/custom/load_data(list/data)
	var/list/new_sprites = data["sprites"]

	for(var/key in new_sprites)
		var/list/sprite = new_sprites[key] || list()

		if(isnull(sprites[key]))
			sprites[key] = list()

		for(var/list/sprite_info in sprite)
			sprites[key] += new /datum/custom_sprite(sprite_info["ckey"], sprite_info["sprite"], sprite_info["footstep_sound"])

	var/list/new_items = data["items"]

	for(var/list/player_info in new_items)
		var/ckey = player_info["ckey"]

		if(isnull(items[ckey]))
			items[ckey] = list()

		for(var/list/item_info in player_info["items"])
			var/item_path = text2path(item_info["path"])

			if(isnull(item_path))
				util_crash_with("The given item path, [item_info["path"]], is invalid and does not exist.")

			var/character_name = item_info["character_name"]
			var/patreon_type = item_info["patreon_type"]
			var/list/req_job = item_info["req_job"]
			var/list/flags = item_info["flags"]

			items[ckey] += new /datum/custom_item(character_name, item_path, patreon_type, req_job, flags)
