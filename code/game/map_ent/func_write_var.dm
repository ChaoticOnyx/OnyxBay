/obj/map_ent/func_write_var
	name = "func_write_var"
	icon_state = "func_write_var"

	var/ev_read_tag
	var/ev_write_tag
	var/ev_table = list()
	var/ev_activate_writer = FALSE
	var/ev_activate_reader = FALSE

/obj/map_ent/func_write_var/activate()
	var/read_table

	if(ev_read_tag == "")
		read_table = GLOB.map_ent_vars
	else
		var/atom/read_atom = locate(ev_read_tag)

		if(istype(read_atom))
			read_table = read_atom.vars

		if(ev_activate_reader && istype(read_atom, /obj/map_ent))
			var/obj/map_ent/E = read_atom
			E.activate()

	var/write_table
	var/atom/write_atom

	if(ev_write_tag == "")
		write_table = GLOB.map_ent_vars
	else
		write_atom = locate(ev_write_tag)

		if(!istype(write_atom))
			crash_with("ev_write_tag is invalid")
			return

		write_table = write_atom.vars
	
	if(!read_table)
		for(var/var_name in ev_table)
			write_table[var_name] = ev_table[var_name]
	else
		for(var/var_name in ev_table)
			write_table[var_name] = read_table[ev_table[var_name]]
	
	if(ev_activate_writer)
		var/obj/map_ent/E = write_atom

		if(!istype(E))
			crash_with("ev_write_tag is not an entity")
			return
		
		E.activate()
