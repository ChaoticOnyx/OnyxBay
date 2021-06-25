'use strict';
// the only functional programming in the whole project
class Matrix {
	constructor(a, b, c, d, e, f) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.e = e;
		this.f = f;
		Object.freeze(this);
	}

	multiply(m2) {
		let a1 = this.a, b1 = this.b, c1 = this.c, d1 = this.d, e1 = this.e, f1 = this.f;
		if(m2 instanceof Array) {
			return [
				(m2[0] * a1) + (m2[1] * c1) + e1,
				(m2[0] * b1) + (m2[1] * d1) + f1
			];
		}
		let a2 = m2.a, b2 = m2.b, c2 = m2.c, d2 = m2.d, e2 = m2.e, f2 = m2.f;
		// https://www.wolframalpha.com/input/?i=%7B%7Ba,c,e%7D,%7Bb,d,f%7D,%7B0,0,1%7D%7D+*+%7B%7BA,C,E%7D,%7BB,D,F%7D,%7B0,0,1%7D%7D
		return new Matrix(
			(a1*a2) + (b2*c1),
			(a2*b1) + (b2*d1),
			(a1*c2) + (c1*d2),
			(b1*c2) + (d1*d2),
			e1 + (a1*e2) + (c1*f2),
			(b1*e2) + f1 + (d1*f2)
		);
	}

	inverse() {
		let a = this.a, b = this.b, c = this.c, d = this.d, e = this.e, f = this.f;
		// https://www.wolframalpha.com/input/?i=inverse+of+%7B%7Ba,c,e%7D,%7Bb,d,f%7D,%7B0,0,1%7D%7D
		return new Matrix(
			d / ((a * d) - (b * c)),
			b / ((b * c) - (a * d)),
			c / ((b * c) - (a * d)),
			a / ((a * d) - (b * c)),
			((d * e) - (c * f)) / ((b * c) - (a * d)),
			((b * e) - (a * f)) / ((a * d) - (b * c))
		);
	}

	translate(dx = 0, dy) {
		return new Matrix(this.a, this.b, this.c, this.d, this.e+this.a*dx+this.c*dy, this.f+this.b*dx+this.d*dy);
	}

	rotate(angle, ox = 0, oy = 0) {
		let c = Math.cos(angle);
		let s = Math.sin(angle);
		return this.translate(ox, oy).multiply(new Matrix(c, s, -s, c, 0, 0)).translate(-ox, -oy);
	}

	scale(sx, sy, ox = 0, oy = 0) {
		if(sy == undefined)
			sy = sx;
		return this.translate(ox, oy).multiply(new Matrix(sx, 0, 0, sy, 0, 0)).translate(-ox, -oy);
	}

	equals(other) {
		return other.a == this.a && other.b == this.b && other.c == this.c && other.d == this.d && other.e == this.e && other.f == this.f;
	}
}

Matrix.identity = new Matrix(1, 0, 0, 1, 0, 0);

module.exports = Matrix;
