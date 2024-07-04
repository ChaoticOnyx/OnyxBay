/proc/is_in_whitelist(ckey)
	return db.is_in_whitelist(ckey, "game")

/proc/is_species_whitelisted(ckey, species_name)
	return db.is_in_whitelist(ckey, "species_[species_name]")
