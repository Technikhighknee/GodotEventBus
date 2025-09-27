# EventBus.gd
#
# A complete, structured and extensible event bus system for Godot 4
# Designed for production use in small and medium sized games
# Recommended: Use as Autoload; Project -> Project Settings 
# -> Globals -> Autoload -> Set name to "EventBus" and script location
#
# License: MIT-0
# GitHub: github.com/Technikhighknee/EventBus
# Author: Jason Posch (Technikhighknee)


extends Node

# Internal structure:
# _listeners[event_name] = {
#     "persistent": [Callable],
#     "once": [Callable]
# }
# key "*" is reserved for global 'on_any' listeners

var _listeners: Dictionary = {}
var debug_enabled: bool = false;

# =====================
# === Public API ======
# =====================

func on(event_name: String, handler: Callable) -> void:
  _ensure(event_name, {"persistent": [], "once": []})
  _listeners[event_name]["persistent"].append(handler)


func once(event_name: String, handler: Callable) -> void:
  _ensure(event_name, {"persistent": [], "once": []})
  _listeners[event_name]["once"].append(handler)


func off(event_name: String, handler: Callable) -> void:
  if _listeners.has(event_name):
    _listeners[event_name]["persistent"].erase(handler)
    _listeners[event_name]["once"].erase(handler)


func on_any(handler: Callable) -> void:
  on("*", handler)


func once_any(handler: Callable) -> void:
  once("*", handler)


func off_any(handler: Callable) -> void:
  off("*", handler)


func emit(event_name: String, payload: Variant = null, meta := {}) -> void:
  var event = {
    "event_name": event_name,
    "payload": payload,
    "timestamp": Time.get_unix_time_from_system(),
    "meta": meta
  }
  
  if debug_enabled:
      event["debug_info"] = _get_debug_location()

  if _listeners.has("*"):
    _dispatch_group("*", event)

  if _listeners.has(event_name):
    _dispatch_group(event_name, event)

# =====================
# === Helper API ======
# =====================

func has(event_name: String) -> bool:
  return _listeners.has(event_name) and (
    _listeners[event_name]["persistent"].size() > 0 or
    _listeners[event_name]["once"].size() > 0
  )


func clear(event_name: String) -> void:
  _listeners.erase(event_name)


func clear_all() -> void:
  _listeners.clear()


func enable_debug(enabled := true) -> void:
  debug_enabled = enabled


# =====================
# === Internal Logic ==
# =====================

func _dispatch_group(event_name: String, event: Dictionary) -> void:
  var group = _listeners[event_name]

  for handler in group["persistent"]:
    _dispatch(handler, event)

  for handler in group["once"]:
    _dispatch(handler, event)

  group["once"].clear()


func _dispatch(handler: Callable, event: Dictionary) -> void:
  if not _is_valid_callable(handler):
    push_warning("Callable is not valid\nEvent:", event)
    return

  if handler.get_argument_count() > 0:
    handler.call(event)
  else:
    handler.call()


func _is_valid_callable(c: Callable) -> bool:
  return c.is_valid()


func _ensure(key: String, default: Dictionary) -> Dictionary:
  if not _listeners.has(key):
    _listeners[key] = default
  return _listeners[key]


func _get_debug_location() -> Dictionary:
  var stack = get_stack()
  if stack.size() > 1:
    var origin = stack[2]
    return {
      "function": origin["function"],
      "file": origin["source"],
      "line": origin["line"],
    }
  return {}
