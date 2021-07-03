class_name AI_Chain
extends Node

signal run_ended()

var _links := []

var _index := 0
var _running := false

func add(object: Object, method: String, args: Array, finish_signal: String) -> void:
	var link := {
		object = object,
		method = method,
		 args = args.duplicate(),
		finish_signal = finish_signal,
	}
	
	_links.push_back(link)

func run() -> void:
	if _running: return
	_running = true
	
	_index = 0
	
	_run_link(_index)
	
	_index += 1

func _run_link(index: int) -> bool:
	if index >= _links.size(): return false
	
	var link := _links[index] as Dictionary
	ObjEct.connect_once(link.object, link.finish_signal, self, '_on_finish_signal', [link.object, link.finish_signal])
	
	var args_realized := link.args.duplicate() as Array
	for i in args_realized.size():
		if not args_realized[i] is FuncRef: continue
		args_realized[i] = args_realized[i].call_func()
	
	link.object.callv(link.method, args_realized)
	return true

func _on_finish_signal(sender: Object, finish_signal: String) -> void:
	ObjEct.disconnect_once(sender, finish_signal, self, '_on_finish_signal')
	
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
	for link in _links:
		ObjEct.disconnect_once(link.object, link.finish_signal, self, '_on_finish_signal')
	_links.clear()
	_index = 0
	
	if not was_running: return
	
	if not signal_end: return
	
	emit_signal('run_ended')









