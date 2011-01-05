#define	LIST_MODE		1
#define	PARAMS_MODE		2

#define	SILENT_FAIL		1
#define	LOUD_FAIL		2

xml_handler
	var
		file
		file_text
		length

		data_mode = LIST_MODE
		error_mode = SILENT_FAIL

		xml_child/child

	proc
		SetChild(xml_child/c)
			child = c

		SetErrorMode(m)
			error_mode = m

		Error(msg, position)
			if(error_mode == LOUD_FAIL)
				world.log << "XML Error"
				world.log << "  File: [file]"
				world.log << "  Error: [msg]"

				if(position)
					var/list/p = get_position_data(position)
					world.log << "  Line: [p[1]]"
					world.log << "  Column: [p[2]]"
					world.log << "  Location: [p[3]]"

			del src

		get_position_data(n)
			. = list(0, 0, 0)

			var
				p = 1
				q = 1
			do
				p = q
				.[1] ++

				q = findtext(file_text, "\n", q + 1)
			while(q && q <= n)

			.[2] = n - p + 1

			.[3] = copytext(file_text, p, findtext(file_text, "\n", p + 1))
			.[3] = html_encode(copytext(.[3], 1, .[2])) + "<b>" + html_encode(copytext(.[3], .[2], .[2] + 1)) + "</b>" + \
				html_encode(copytext(.[3], .[2] + 1))

		IsListMode() return data_mode == LIST_MODE
		IsParamsMode() return data_mode == PARAMS_MODE

		SetMode(m)
			if(m == LIST_MODE)
				data_mode = LIST_MODE
				if(child) child.ToList()

				return 1

			if(m == PARAMS_MODE)
				data_mode = PARAMS_MODE
				if(child) child.ToParams()

				return 1

			return 0