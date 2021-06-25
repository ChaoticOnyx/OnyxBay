class Appearance {
	constructor(o) {
		if(!o) o = {};
		this.icon = o.icon || null;
		this.icon_state = o.icon_state || null;
		this.name = o.name || null;
		this.appearance_flags = o.appearance_flags || 0;
		this.layer = o.layer !== undefined ? o.layer : 2;
		this.plane = o.plane !== undefined ? o.plane : -32767;
		this.dir = o.dir !== undefined ? o.dir : 2;
		this.color = o.color || "#ffffff";
		this.alpha = o.alpha !== undefined ? o.alpha : 255 ;
		this.pixel_x = o.pixel_x || 0;
		this.pixel_y = o.pixel_y || 0;
		this.blend_mode = o.blend_mode || 0;
		this.transform = o.transform || [1,0,0,0,1,0];
		this.invisibility = o.invisibility || 0;
		this.pixel_w = o.pixel_w || 0;
		this.pixel_z = o.pixel_z || 0;
		this.overlays = o.overlays || [];
		this.underlays = o.underlays || [];
		this.sorted_overlays = null;
		Object.seal(this);
	}
}

module.exports = Appearance;
