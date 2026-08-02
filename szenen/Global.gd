extends Node

func wait(wait_time: float = 1.0) -> void:
	if wait_time > 0:
		await await get_tree().create_timer(wait_time).timeout
		return
	else:
		await get_tree().process_frame
		return
