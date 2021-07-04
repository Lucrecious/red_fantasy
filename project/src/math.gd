extends Node

class_name Math

static func get_closest_point_on_rect(rect: Rect2, point: Vector2) -> Vector2:
	rect = rect.abs()
	
	var l := rect.position.x
	var t := rect.position.y
	var r := l + rect.size.x
	var b := t + rect.size.y
	
	var x := point.x
	var y := point.y
	
	x = clamp(x, l, r)
	y = clamp(y, t, b)
	
	var dl := abs(x - l)
	var dr := abs(x - r)
	var dt := abs(y - t)
	var db := abs(y - b)
	
	var m := min(dl, min(dr, min(dt, db)))
	
	if m == dt: return Vector2(x, t)
	if m == db: return Vector2(x, b)
	if m == dl: return Vector2(l, y)
	if m == dr: return Vector2(r, y)
	
	assert(false, 'this is impossible')
	return Vector2(NAN, NAN)

static func distance_to_rect(rect: Rect2, point: Vector2) -> float:
	if rect.has_point(point): return 0.0
	
	var x := min(abs(point.x - rect.position.x), abs(point.x - (rect.position.x + rect.size.x)))
	var y := min(abs(point.y - rect.position.y), abs(point.y - (rect.position.y + rect.size.y)))
	
	if point.x > rect.position.x and point.x < rect.position.x + rect.size.x:
		return y
	
	if point.y > rect.position.y and point.y < rect.position.y + rect.size.y:
		return x
	
	return Vector2(x, y).length()

static func inside_rect_distance(rect: Rect2, point: Vector2) -> float:
	if not rect.has_point(point): return 0.0
	
	var x := min(abs(point.x - rect.position.x), abs(point.x - (rect.position.x + rect.size.x)))
	var y := min(abs(point.y - rect.position.y), abs(point.y - (rect.position.y + rect.size.y)))
	
	return min(x, y)

