#define	LIST_MODE		1
#define	PARAMS_MODE		2

#define	POST			1
#define	PRE				2
#define	SIDE			3

xml_child
	var
		xml_handler/master
		xml_child/parent

		list
			children
			attributes[0]

			comments

		name
		content
		write_content = 0

	New(n, xml_handler/m, xml_child/p)
		name = n

		master = m
		if(!master.child)
			master.SetChild(src)

		parent = p

		if(parent)
			parent.AddChild(src)

	Del()
		for(var/xml_child/a in children)
			del a

		..()

	proc
		AddComment(comment, position = PRE)
			if(!comments) comments = new
			comments[comment] = position

		RemoveComment(n)
			if(istext(n)) comments -= n
			if(isnum(n)) comments.Cut(n, n + 1)

			if(!comments.len) del comments

		SetName(n)
			name = n

		AddChild(xml_child/c)
			if(!children) children = new
			children += c

		NextChild(xml_child/c)
			var/index = children.Find(c)
			if(index) return children[(index % children.len) + 1]

		PreviousChild(xml_child/c)
			var/index = children.Find(c)
			if(index) return children[(index - 1) || children.len]

		ToList()
			if(master.IsListMode() && istype(attributes, /list))
				attributes = list2params(attributes)
				for(var/xml_child/child in children) child.ToList()

		ToParams()
			if(master.IsParamsMode() && istype(attributes, /list))
				attributes = params2list(attributes)
				for(var/xml_child/child in children) child.ToParams()

		GetAttributesList(mode = 0)
			if((mode && mode == LIST_MODE) || master.IsListMode())
				if(istype(attributes, /list)) return attributes
				return params2list(attributes)
			if((mode && mode == PARAMS_MODE) || master.IsParamsMode()) return params2list(attributes)

		SetAttributesList(list/l)
			if(master.IsListMode()) attributes = l
			else if(master.IsParamsMode()) attributes = list2params(l)

			return 1

		SetAttribute(attribute, value)
			if(!attributes) attributes = new
			attributes[attribute] = value

			return 1

		AddAttribute(attribute, value) return SetAttribute(attribute, value)

		RemoveAttribute(attribute)
			var/list/l = GetAttributesList()
			l -= attributes

			return SetAttributesList(l)

		SetContent(c)
			content = c
			return 1

		ClearContent() return SetContent(null)
		AddContent(c) return SetContent(content + c)

		GetParent() return parent
		GetChild(n = 1)
			if(isnum(n)) return children && children[n]

			if(istext(n))
				for(var/xml_child/a in children)
					if(a.name == n)
						return a

			return null

		GetName() return name
		GetContent(c = 0)
			if(c) return content
			return content || children
		GetChildren() return children

		GetValue(a)
			if(master.IsListMode()) return (a in attributes) ? attributes[a] : null
			if(master.IsParamsMode())
				var/list/l = params2list(attributes)
				return (a in l) ? l[a] : null

		GetValueAsText(a) return GetValue(a)
		GetValueAsNum(a)
			. = GetValue(a)
			if(.) return text2num(.)
		GetValueAsFile(a)
			. = GetValue(a)
			if(.) return file(.)
		GetValueAsPath(a)
			. = GetValue(a)
			if(.) return text2path(.)