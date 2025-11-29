extends TileMapLayer

var astar = AStarGrid2D.new()

func _ready():
	var tilemap_size = get_used_rect().end - get_used_rect().position
	var map_rect = Rect2i(Vector2i.ZERO, tilemap_size)
	
	var tile_size = Vector2i(32, 32)
	
	astar.region = map_rect
	astar.cell_size = tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coords = Vector2i(i, j)
			var tile_data = get_cell_tile_data(coords)
			if !(tile_data and tile_data.get_custom_data("walkable")):
				astar.set_point_solid(coords)
	

func is_point_walkable(position):
	var map_position = local_to_map(position)
	print(map_position)
	if astar.region.has_point(map_position) and !astar.is_point_solid(map_position):
		return true
	return false
