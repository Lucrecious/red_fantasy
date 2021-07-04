class_name AI_Chain
extends Node

signal run_ended()

var _links := []

var _index := 0
var _running := false

var _generation := 0

func add(object: Object, method: String, args: Array) -> void:
	var link := {
		object = object,
		method = method,
		args = args.duplicate(),
	}
	
	_links.push_back(link)

func run() -> void:
	if _links.empty(): return
	if _running: return
	_running = true
	
	_index = 0
	
	_run_link(_index)
	
	_index += 1

func _run_link(index: int) -> bool:
	if index >= _links.size(): return false
	
	var link := _links[index] as Dictionary
	
	var args_realized := link.args.duplicate() as Array
	for i in args_realized.size():
		if not args_realized[i] is FuncRef: continue
		args_realized[i] = args_realized[i].call_func()
	
	args_realized.push_back(FuncREf.new(self, '_notify_next', [_generation]))
	link.object.callv(link.method, args_realized)
	return true

func _notify_next(generation: int) -> void:
	if _generation != generation: return
	
	if _index >= _links.size():
		clear()
		return
	
	yield(get_tree(), 'idle_frame')
	
	if not _run_link(_index):
		clear()
		return
	
	_index += 1

func clear(signal_end := true) -> void:
	var was_running := _running
	
	_running = false
	_generation += 1
	_links.clear()
	_index = 0
	
	if not was_running: return
	
	if not signal_end: return
	
	emit_signal('run_ended')









