Sqrl.helpers.define('link', function(content, blocks, _) {
	var args = content.params[0] || {};
	var parameters = args.act;
	var body = args.body;
	var classes = args.class || 'linkActive';
	var dataHref = '';

	if (parameters) {
		dataHref = 'data-href="' + NanoUtility.generateHref(parameters);
	}

	if (Array.isArray(classes)) {
		classes = classes.join(' ');
	}

	for (var i = 0; i < blocks.length; i++) {
		var block = blocks[i];

		switch (block.name)
		{
			case 'body':
				body = block.exec();
				break;
			case 'class':
				classes = block.exec();
				break;
		}
	}

	return '<div unselectable="on" class="link ' + classes + '" ' + dataHref + '">' + body + '</div>';
});

Sqrl.helpers.define('icon', function(content, blocks, _) {
	var args = content.params[0] || {};
	iconName = args.icon;

	return '<span class="fas fa-' + iconName + '"></span>';
});

Sqrl.helpers.define('progressBar', function(content, _, __) {
	var args = content.params[0] || {};
	var value = args.value;
	var min = args.min;
	var max = args.max;
	var classes = args.class || '';
	var showText = args.text || '';

	if (Array.isArray(classes)) {
		classes = classes.join(' ');
	}

	if (min < max)
	{
		if (value < min)
		{
			value = min;
		}
		else if (value > max)
		{
			value = max;
		}
	}
	else
	{
		if (value > min)
		{
			value = min;
		}
		else if (value < max)
		{
			value = max;
		}
	}

	var percentage = Math.round((value - min) / (max - min) * 100);

	return '<div class="displayBar ' + classes + '"><div class="displayBar' + 'Fill ' + classes + '" style="width: ' + percentage + '%;"></div><div class="displayBar' + 'Text ' + classes + '">' + showText + '</div></div>';
});
