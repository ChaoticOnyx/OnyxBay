#define	ENDING_CLOSE	1
#define	BEGINNING_CLOSE	2

xml_handler
	var
		xml_child/current
		list/close_series[0]

	New(f)
		if(isfile(f) || (istext(f) && fexists(f)))
			LoadFile(f)
			ParseFile(f)

	proc
		LoadFile(f)
			if(!fexists("[f]") && !isfile(f)) return  0

			file = f
			file_text = file2text(file)
			length = length(file_text)

			return 1

		ParseFile()
			if(!file_text && file)
				file_text = file2text(file)
				length = length(file_text)

			close_series = new

			var
				location = 0
				last_location = 0
				n = findtext(file_text, "<", location + 1)
			while(n && location <= length)
				if(n)
					last_location = location
					location = parse_tag(n)

					if(location == last_location) break

				n = findtext(file_text, "<", location + 1)

			if(close_series.len)
				Error("Unclosed tag(s).")

			current = null

		parse_tag(m)
			var
				close_tag = 0

				tag
				value

				equal_reached

				list/attributes[0]

			for(var/n = m, n <= length, n ++)
				switch(text2ascii(file_text, n))
					if(47) // /
						if(!tag)
							if((n - m) > 1)
								Error("No tag specified.", m + 1)

							else
								tag = copytext(file_text, n + 1, findtext(file_text, ">", n + 1))
								if(is_invalid(tag))
									Error("Invalid tag.", n + 1)

						close_tag = ((n - m) > 1) ? ENDING_CLOSE : BEGINNING_CLOSE
						m = n
						break

					if(60) //<
						continue

					if(62) //>
						if(!tag)
							Error("No tag specified.", m + 1)

						m = n
						break

					if(48 to 57) //0 through 9
						Error("Invalid value tag.", n)

					if(33) //!
						var/end = findtext(file_text, "-->", n)
						if(!end) Error("Comments not ended.", n)
						return end

					if(65 to 90, 97 to 122, 95) //A-Z, a-z, _
						var
							end

							equal = findtext(file_text, "=", n)
							space = findtext(file_text, " ", n)
							bracket = findtext(file_text, ">", n)

							list/l[0]
						if(equal) l += equal
						if(space) l += space
						if(bracket) l += bracket
						end = min(l)

						if(!tag) tag = copytext(file_text, n, end)
						else if(!value) value = copytext(file_text, n, end)

						if(!value && is_invalid(tag))
							Error("Invalid tag.", n)

						else if(value && is_invalid(value))
							Error("Invalid attribute.", n)

						n = end - 1

					if(61) //=
						if(!value) Error("Unexpected equal sign reached.", n)
						equal_reached = 1

					if(34, 39) //", '
						if(!value || !equal_reached) Error("Unexpected attribute reached.", n)

						var
							char = copytext(file_text, n, n + 1)
							end = findtext(file_text, char, n + 1)

						if(!end) Error("Unclosed attribute found.", n)
						attributes[value] = format_string(copytext(file_text, n + 1, end), n)

						n = end

					if(32) //  (Space)
						if(value && (!equal_reached || !value))
							Error("Unvalued attributed found.", n)

						value = null

						equal_reached = null

					else
						Error("Unknown character reached.", n)

			make_child(tag, close_tag, attributes, m)
			return findtext(file_text, ">", m)

		is_invalid(n)
			var/length = length(n)
			for(var/a = 1, a <= length, a ++)
				var/ascii = text2ascii(n, a)
				if((ascii >= 65 && ascii <= 90) || (ascii >= 97 && ascii <= 122) || (ascii >= 48 && ascii <= 57) || \
				  (ascii == 95))
					continue

				return 1

			return 0

		format_string(string, n)
			. = ""

			var/error = findtext(string, "<") || findtext(string, ">") || findtext(string, "\"") || findtext(string, "'")
			if(error)
				return Error("Invalid character found in attribute.", n + error)

			var
				length = length(string)
				location = 0
				previous = 1

			do
				location = findtext(string, "&", location + 1)
				if(location)
					var/end = findtext(string, ";", location)
					if(!end) Error("Unclosed entity.", n + location)

					. += copytext(string, previous, location)

					var/component = copytext(string, location + 1, end)
					switch(component)
						if("amp") . += "&"
						if("apos") . += "'"
						if("quot") . += "\""
						if("lt") . += "&lt;"
						if("gt") . += "&gt;"

					previous = end + 1

			while(location && location <= length)

			. += copytext(string, previous)

		make_child(tag, close, list/attributes, n)
			if(!close || close == ENDING_CLOSE)
				var/xml_child/c = new(tag, src, current)
				c.SetAttributesList(attributes)

				if(!current) child = c
				if(!close)
					current = c
					close_series += tag
					close_series[tag] = n + 1

			else if(close == BEGINNING_CLOSE && current)
				if(!(tag in close_series))
					Error("Uncorresponded tag.", n)

				if(tag != close_series[close_series.len])
					Error("Premature tag closure.", n)

				current.content = clear_comments(copytext(file_text, close_series[tag], n - 1))

				close_series -= tag
				current = current.GetParent()

		clear_comments(string)
			var/start = findtext(string, "<!--", 1)
			while(start)
				var/end = findtext(string, "-->", start)
				string = copytext(string, 1, start) + copytext(string, end + 3)

				start = findtext(string, "<!--", 1)

			return string