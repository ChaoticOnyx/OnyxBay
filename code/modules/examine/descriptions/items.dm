
/obj/item/get_description_combat()
	. = ""

	if(force)
		. = "Weight: "
		switch(mod_weight)
			if(0 to 0.4)
				. += "Very light"
			if(0.4 to 0.8)
				. += "Light"
			if(0.8 to 1.25)
				. += "Moderate"
			if(1.25 to 1.65)
				. += "Heavy"
			else
				. += "Very heavy"

		. += "\nReach: "
		switch(mod_reach)
			if(0 to 0.4)
				. += "Very short"
			if(0.4 to 0.8)
				. += "Short"
			if(0.8 to 1.25)
				. += "Average"
			if(1.25 to 1.65)
				. += "Long"
			else
				. += "Very long"

		. += "\nConvenience: "
		switch(mod_handy)
			if(0 to 0.4)
				. += "Unhandy"
			if(0.4 to 0.8)
				. += "Not that handy"
			if(0.8 to 1.25)
				. += "Handy"
			if(1.25 to 1.65)
				. += "Really handy"
			else
				. += "Outstandingly handy"

		if(armor_penetration)
			switch(armor_penetration)
				if(1 to 19)
					. += "\nIt's good for penetrating light armor."
				if(20 to 39)
					. += "\nIt's good for penetrating medium armor."
				if(40 to 59)
					. += "\nIt's good for penetrating above-average armor."
				if(60 to 79)
					. += "\nIt's good for penetrating heavy armor."
				if(80 to 99)
					. += "\nIt's exceptionally good for penetrating most armor."
				if(100 to INFINITY)
					. += "\nIt goes through most armor as a hot knife through butter."
		else
			. += "\nIt's not that good at penetrating armor."

		. += "\nAttack Cooldown: [round((attack_cooldown + DEFAULT_WEAPON_COOLDOWN * (mod_weight / mod_handy)) * mod_speed * 0.1, 0.1)]s"
		. += "\nParry Window: [round(mod_handy * 12 * 0.1, 0.1)]s"
	if(block_tier == BLOCK_TIER_ADVANCED)
		. += "\nIt may block or reflect projectiles really well."
	else if(mod_shield == BLOCK_TIER_PROJECTILE)
		. += "\nIt may block projectiles."
