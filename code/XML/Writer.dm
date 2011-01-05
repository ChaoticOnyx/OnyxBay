xml_handler
	proc
		SetFile(f)
			file = f

		WriteFile(f)
			if(f)
				SetFile(f)

			if(fexists(file)) fdel(file)

			if(file)
				var/text = child_loop(child)
				text2file(text, file)

				return LoadFile(file)

		multiply_text(t, n)
			. = ""
			for(var/a = 1, a <= n, a ++) . += t

		child_loop(xml_child/c, t = 0)
			for(var/a in c.comments)
				if(c.comments[a] == PRE)
					. += "[t > 0 ? "\n" : null][multiply_text("\t", t)]<!-- [a] -->[t > 0 ? null : "\n"]"

			. += "[t > 0 ? "\n" : null][multiply_text("\t", t)]<[c.name]"
			for(var/a in c.attributes)
				. += " [a]=\"[c.attributes[a]]\""

			if(!c.children && !c.content) . += " />"
			else if(c.content && (c.write_content || !c.children)) . += ">[c.content]</[c.name]>"
			else . += ">"

			for(var/a in c.comments)
				if(c.comments[a] == SIDE)
					. += " <!-- [a] -->"

			for(var/a in c.children) . += .(a, t + 1)

			if(c.children) . += "\n[multiply_text("\t", t)]</[c.name]>"

			for(var/a in c.comments)
				if(c.comments[a] == POST)
					. += "\n[multiply_text("\t", t)]<!-- [a] -->"

		FindChild(path)
			var
				list/p = explode(copytext(path, 2))
				xml_child/c = child

			for(var/a = 2, a <= p.len, a ++)
				for(var/xml_child/e in c.children)
					if(e.name == p[a])
						c = e
						break

				if(c.name != p[a]) return 0

			return c && (p.len > 1 ? c : (c.name == p[1] && c))

		explode(string, delimiter = "/")
			. = list()

			var
				start = 1
				end = findtext(string, delimiter)

			while(end)
				. += copytext(string, start, end)

				start = end + 1
				end = findtext(string, delimiter, start)

			. += copytext(string, start)

		AddChild(path, name)
			var/xml_child/c = FindChild(path)
			if(c) return new/xml_child(name, src, c)

		DeleteChild(path)
			var/xml_child/c = FindChild(path)
			if(c)
				del c
				return 1

			return 0

		SetChildAttributesList(path, list/attributes)
			var/xml_child/c = FindChild(path)
			if(c)
				c.SetAttributesList(attributes)
				return 1

			return 0

		SetChildAttribute(path, attribute, value)
			var/xml_child/c = FindChild(path)
			if(c)
				c.SetAttribute(attribute, value)
				return 1

			return 0

		AddChildAttribute(path, attribute, value)
			var/xml_child/c = FindChild(path)
			if(c)
				c.AddAttribute(attribute, value)
				return 1

			return 0

		RemoveChildAttribute(path, attribute)
			var/xml_child/c = FindChild(path)
			if(c)
				c.RemoveAttribute(attribute)
				return 1

			return 0