class_name AI_Chain
extends Node

var _links := []

var _index := 0

func add(object: Object, method: String, args: Array, finish_signal: String) -> void:
	var link := {
		object = object,
		method = method,
		 args = args.duplicate(),
		finish_signal = finish_signal,
	}
	
	_links.push_back(link)

func run() -> void:
	if _index != 0:
		_index = 0
	
	_run_link(_index)
	_index += 1

func _run_link(index: int) -> void:
	if index >= _links.size(): return
	
	var link := _links[index] as Dictionary
	ObjEct.connect_once(link.object, link.finish_signal, self, '_on_finish_signal', [link.object, link.finish_signal])
	link.object.callv(link.method, link.args)

func _on_finish_signal(sender: Object, finish_signal: String) -> void:
	ObjEct.disconnect_once(sender, finish_signal, self, '_on_finish_signal')
	
	yield(get_tree(), 'idle_frame')
	
	if _index >= _links.size():
		_index = 0
	_run_link(_index)
	_index += 1











