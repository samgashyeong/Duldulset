extends TextureRect

@onready var giiyoung = $"../../Giiyoung"


# Tween을 사용하여 오프셋 애니메이션을 관리합니다.
var offset_tween: Tween = null


func _ready() -> void:
	# 초기 위치를 Giiyoung의 위치로 바로 설정하여 튀는 현상을 방지합니다.
	self.position = giiyoung.position+Vector2(1, 10)
	default_move_animation()

func _process(delta: float) -> void:
	# 1. 최종 목표 위치 계산: Giiyoung의 위치 + 애니메이션 오프셋
	var target_position: Vector2 = giiyoung.position + Vector2(-5, -24)
	
	# 2. Lerp (선형 보간)를 사용하여 현재 위치를 목표 위치로 부드럽게 이동
	# Lerp는 '현재 값'과 '목표 값' 사이를 '양'만큼 보간합니다. (delta와 무관하게 부드러운 이동)
	self.position = target_position
	
	# 참고: delta를 사용한 Lerp (속도를 일정하게 유지)
	# self.position = self.position.lerp(target_position, 1.0 - pow(0.0001, delta))
	# 이 방법도 있지만, 단순한 '부드러운 따라가기'에는 위의 상수 속도 Lerp가 더 직관적입니다.


# 애니메이션 함수 (이제 이 함수는 position 대신 anim_offset을 Tween 합니다)
func default_move_animation():
	if offset_tween and offset_tween.is_running():
		offset_tween.kill()
		
	offset_tween = create_tween()
	
	# 3. Tween을 사용하여 anim_offset을 애니메이션 (위로 올라갔다 내려오는 효과)
	# 목표 위치는 Giiyoung의 position이 아닌, Giiyoung 위치에 더해질 '오프셋' 값입니다.
	offset_tween.tween_property(self, "anim_offset", Vector2(0, -10), 0.5)
	offset_tween.tween_property(self, "anim_offset", Vector2(0, 0), 0.5)
	
	await offset_tween.finished
	default_move_animation() # 반복
