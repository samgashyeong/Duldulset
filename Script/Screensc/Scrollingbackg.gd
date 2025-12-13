#202221035현동우
extends ParallaxBackground


var scroll_speed = 200.0

# 매 프레임마다 호출되어 배경을 업데이트 (Called every frame to update the background)
func _process(delta):
	# 현재 스크롤 위치(x축)를 속도에 따라 왼쪽으로 이동 (Move the current scroll offset (x-axis) to the left based on speed)
	scroll_offset.x -= scroll_speed * delta
