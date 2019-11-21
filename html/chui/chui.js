chui = {
	minWidth: 200,
	minHeight: 200,
	flags: 0
};

var escaper = encodeURIComponent || escape;

var CHUI_FLAG_SIZABLE = 1;
var CHUI_FLAG_MOVABLE = 2;
var CHUI_FLAG_FADEIN = 4;

chui.setLabel = function( id, label ){
	$("a").contents().filter(function() {return this.nodeType === 3;})[0].textContent = label;
};

chui.bycall = function( method, data ){
	data = data || {};
	data._cact = method;
	document.location = "?src=" + chui.window + "&" + $.param( data );
};

chui.close = function( ){
	document.location = "byond://winset?command=" + escaper( ".chui-close " + chui.window );
	chui.winset( "is-visible", "false" );
};

chui.winset = function( key, value ){
	document.location = "byond://winset?" + chui.window + "." + key + "=" + escape( value );
};

chui.setPos = function( x, y ){
	chui.winset( "pos", x + "," + y );
};

chui.setSize = function( w, h ){
	chui.winset( "size", w + "," + h );
};

chui.initialize = function(){
	chui.data = {};

	$("meta").each( function(){
		var key = $(this).attr( "name" );
		if( key )
			chui.data[ key ] = $(this).attr( "value" );
	} );
	chui.window = chui.data.ref;//BYOND reference to this window.
	chui.flags = Number( chui.data.flags );//Window flags. Look at top for more info.

//Scrollbar
	$('#content').nanoScroller({});

	chui.winset( "transparent-color", "#FF00E4" );//Sets the window transparent color for 1 bit transparency.

//Window Movement
///////ALIGNMENT
	//Check for offset cookie
	//Save opening position
	var prevX = window.screenLeft;
	var prevY = window.screenTop;
	//Put the window at top left
	chui.setPos( 0, 0 );
	//Get any offsets still present
	chui.offsetX = window.screenLeft;
	chui.offsetY = window.screenTop;

	//Put the window back where it came from
	chui.setPos( prevX - chui.offsetX, prevY - chui.offsetY );
///////ALIGNMENT FIN

////Titlebar
	$('body').on('mousemove', '#titlebar', function(ev) {
		ev = ev || window.event;
		if (!chui.lastX) {
			chui.lastX = ev.screenX;
			chui.lastY = ev.clientY;
		}
		if (chui.titlebarMousedown == 1) {
			var dx = (ev.screenX - chui.lastX);
			var dy = (ev.screenY - chui.lastY);
			dx += window.screenLeft - chui.offsetX;
			dy += window.screenTop - chui.offsetY;

			chui.setPos( dx, dy );
		}
		chui.lastX = ev.screenX;
		chui.lastY = ev.screenY;
	});
	$('body').on('mousedown', '#titlebar', function() {
		chui.titlebarMousedown = 1;
		if ($(this)[0].setCapture) {$(this)[0].setCapture();}
	});
	$('body').on('mouseup', '#titlebar', function() {
		chui.titlebarMousedown = 0;
		if ($(this)[0].releaseCapture) {$(this)[0].releaseCapture();}
	});
////FIN Titlebar

////Size handles
	if( (chui.flags & CHUI_FLAG_SIZABLE) > 0 ){
		$('body').on('mousemove', 'div.resizeArea', function(ev) {
			if (chui.resizeWorking) {return;}
			chui.resizeWorking = true;
			ev = ev || window.event;
			if (!chui.lastX) {
				chui.lastX = ev.screenX - chui.offsetX;
				chui.lastY = ev.screenY - chui.offsetY;
			}
			if (chui.resizeMousedown == 1) { //TODO: Handle sizing under minimum and coming back up being funny.
				var width = document.body.offsetWidth;
				var height = document.body.offsetHeight;
				var rx = Number($(this).attr( "rx" ));
				var ry = Number($(this).attr( "ry" ));

				var dx = ((ev.screenX-chui.offsetX) - chui.lastX);
				var dy = ((ev.screenY-chui.offsetY) - chui.lastY);

				var newX = window.screenLeft - chui.offsetX;
				var newY = window.screenTop - chui.offsetY;

				var newW = width + (dx * rx);
				if( rx == -1 ){
					newX += dx;
				}
				var newH = height + (dy * ry);
				if( ry == -1 ){
					newY += dy;
				}

				newW = Math.max( chui.minWidth, newW );
				newH = Math.max( chui.minHeight, newH );

				chui.setPos( newX, newY );
				chui.setSize( newW, newH );
			}
			chui.lastX = ev.screenX - chui.offsetX;
			chui.lastY = ev.screenY - chui.offsetY;

			chui.resizeWorking = false;//Prevent odd occasions where this gets called multiple times while working.
		});
		$('body').on('mousedown', 'div.resizeArea', function() {
			chui.resizeMousedown = 1;
			if (this.setCapture) this.setCapture();
		});
		$('body').on('mouseup', 'div.resizeArea', function() {
			chui.resizeMousedown = 0;
			if (this.releaseCapture) this.releaseCapture();
		});
	}else{
		$("div.resizeArea").remove();
	}
//FIN Window Movement

	$('body').on('click', 'a.button', function() {
		chui.bycall( "click", {id: this.id} );
	});

	$(".close").click(function(){
		if( chui.flags & CHUI_FLAG_FADEIN )
			chui.fadeOut();
		else
			chui.close();
	});
	if( chui.flags & CHUI_FLAG_FADEIN )
		chui.fadeIn();
};

chui.fadeIn = function(){
	var width = document.body.offsetWidth;
	var height = document.body.offsetHeight;

	var x = window.screenLeft - chui.offsetX;
	var y = window.screenTop - chui.offsetY;

	chui.setSize( width + 80, height + 80 );
	chui.setPos( x - 40, y - 40 );
	chui.winset( "alpha", "0" );
	setTimeout( function(){
		$({foo:0}).animate({foo:1}, {
			duration: 1000,
			step: function( val ){
				//prompt(""+val);
				chui.winset( "alpha", 255 * val );
				var neg = 1 - val;
				chui.setSize( width + 80 * neg, height + 80 * neg );
				chui.setPos( x - 40 * neg, y - 40 * neg );
			}
		});
	}, 1000 );
};

chui.fadeOut = function(){
	var width = document.body.offsetWidth;
	var height = document.body.offsetHeight;

	var x = window.screenLeft - chui.offsetX;
	var y = window.screenTop - chui.offsetY;
	//setTimeout( function(){
		$({foo:1}).animate({foo:0}, {
			duration: 1000,
			step: function( val ){
				//prompt(""+val);
				chui.winset( "alpha", 255 * val );
				var neg = 1 - val;
				chui.setSize( width + 80 * neg, height + 80 * neg );
				chui.setPos( x - 40 * neg, y - 40 * neg );
			},
			complete: function(){
				chui.close();
			}
		});
	//}, 1000 );
};

chui.templateSet = function( id, value ){
	var templateItem = document.getElementById( "chui-tmpl-" + id );
	if( !templateItem )
		return;
	templateItem.innerText = value;
};

var activeRequests = [];
var reqID          = 0;
chui.request = function( path, data, callback ){
	activeRequests.push( {id: ++reqID, callback: callback} );
	data._id = reqID;
	data._path = path;
	chui.bycall( "request", data );
};

$(chui.initialize);