/// Vector Script Functions


//Main Vector Struct
function vector(_x, _y) constructor {
	x = _x;
	y = _y;
	
	static add = function(_vector) {
		x += _vector.x;
		y += _vector.y;
	}
	
	static added = function(_vector) {
		return new vector(x + _vector.x, y + _vector.y)
	}
	
	static subtract = function(_vector) {
		x -= _vector.x;
		y -= _vector.y;
	}
	
	static subtracted = function(_vector) {
		return new vector(x - _vector.x, y - _vector.y)
	}
	
	static negate = function() {
		x = -x;
		y = -y;
	}
	
	static multiply = function(_scalar) {
		x *= _scalar;
		y *= _scalar;
	}
	
	static multiplied = function(_scalar) {
		return new vector(x*_scalar, y*_scalar)
	}
	
	static divide = function(_scalar) {
		x /= _scalar;
		y /= _scalar;
	}
	
	static divided = function(_scalar) {
		return new vector(x/_scalar, y/_scalar)
	}
      
	static get_magnitude = function() {
		return sqrt((x * x) + (y * y));
    }
	static get_direction = function() {
		return point_direction(0, 0, x, y);
	}

	static normalize = function() {
		if ((x != 0) || (y != 0)) {
			//var _factor = 1/sqrt((x * x) + (y *y));
			//x = _factor * x;
			//y = _factor * y;	
			divide(get_magnitude())
		}
	}
	static normalized = function() {
		if ((x != 0) || (y != 0)) {
			var v = new vector(x,y)
			v.divide(v.get_magnitude())
			return v
		}
		return new vector(0,0)
	}
	static set_magnitude = function(_scalar) {
		normalize();
		multiply(_scalar);	
	}	
	static limit_magnitude = function(_limit) {
		if (get_magnitude() > _limit) {
			set_magnitude(_limit);
		}
	}
	static clamped = function(min, max) {
		return new vector(clamp(x, min.x, max.x), clamp(y, min.y, max.y))
	}
	
	static equal = function(v) {
		return x == v.x and y == v.y
	}
}

function vector_random(_length) {
	var _dir = random(360);
	if (is_undefined(_length)) {
		_length = 1;
	}
	var v = new vector(lengthdir_x(_length, _dir),lengthdir_y(_length, _dir))
	return v
}