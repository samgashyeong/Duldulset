#202322158 이준상
extends RichTextLabel

var max_lines = 10
var log_history = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트1")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트2")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트3")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트4")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	await get_tree().create_timer(0.5).timeout
	add_log("테스트")
	add_log("테스트")
	add_log("테스트")
	
	pass # Replace with function body.



#add log
func add_log(message : String):
	log_history.append(message)
	
	# 3. 최대 줄 수를 넘으면 가장 오래된 것(0번 인덱스) 삭제
	if log_history.size() > max_lines:
		log_history.pop_front()
	
	# 4. RichTextLabel에 내용 갱신
	# 배열을 줄바꿈 문자(\n)로 합쳐서 한 번에 넣습니다.
	text = "\n".join(log_history)
