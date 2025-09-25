# EventBus.gd

> A structured and extensible Event Bus system for Godot 4  
> For production use in small and medium games

---

## 🚀 Setup (Autoload Recommended)

Add the script as an **Autoload singleton**:

Go to  
**Project → Project Settings → Globals → Autoload**

| Name      | Path to Script              |
|-----------|-----------------------------|
| `EventBus` | `res://path/to/EventBus.gd` |

---

## 🧠 Usage

```gdscript
# Register a persistent listener
EventBus.on("my_event", _on_my_event)

# Register a one-time listener
EventBus.once("init_done", _init_once)

# Emit an event with optional payload/meta
EventBus.emit("my_event", payload_data, meta_data)

# Remove a listener — only works with **named methods**
EventBus.off("my_event", _on_my_event)

# Global listeners
EventBus.on_any(_some_on_any_handler)
EventBus.once_any(_some_once_any_handler)
EventBus.off_any(_some_on_any_handler)
```

❗ **Note:**  
If you want to use `off(...)`, do **not** pass lambdas/anonymous functions.  
Only **named functions/methods** can be unregistered reliably.

---

## 🧾 Event Shape

Every emitted event is passed as a `Dictionary` to the handler.

### Without Debug (`EventBus.enable_debug(false)` — default)

```gdscript
{
  "event_name": "my_event",
  "payload": { "score": 42 },
  "timestamp": 1699999999,
  "meta": { "source": "player_1" }
}
```

### With Debug (`EventBus.enable_debug(true)`)

```gdscript
{
  "event_name": "my_event",
  "payload": { "score": 42 },
  "timestamp": 1699999999,
  "meta": { "source": "player_1" },
  "debug_info": {
    "function": "_on_my_event",
    "file": "res://some/path/to/script.gd",
    "line": 1337
  }
}
```

---

Event fields explained like you're five:

- `event_name`: What was emitted.
- `payload`: The data you're passing around.
- `timestamp`: When it happened (UNIX time).
- `meta`: Optional extra stuff you attach.
- `debug_info`: Only there if debugging is on. Tells you **where** the event was emitted.

---

## 🔧 Extras

```gdscript
EventBus.has("some_event")      # Check if any listeners exist
EventBus.clear("some_event")    # Clear one event's listeners
EventBus.clear_all()            # Wipe everything
EventBus.enable_debug(true)     # Include debug info in emitted events
```

---

## 📄 License

MIT No Attribution  
© 2025 Jason Posch (https://github.com/technikhighknee)
