# 202322111 임상인
# This script is for pathfinding logic for the tilemap.

extends TileMapLayer

var astar = AStarGrid2D.new()

# Initialize the astar pathfinding settings.
func _ready():
	# get the tilemap size
	var tilemap_size = get_used_rect().end - get_used_rect().position
	var map_rect = Rect2i(Vector2i.ZERO, tilemap_size)
	
	# set the tile size as 32x32
	var tile_size = Vector2i(32, 32)
	
	# setup the astar settings
	astar.region = map_rect
	astar.cell_size = tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	# for each tile in the tilemap
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coords = Vector2i(i, j)
			var tile_data = get_cell_tile_data(coords)
			# set the tile to solid if it is not walkable
			if !(tile_data and tile_data.get_custom_data("walkable")):
				astar.set_point_solid(coords)
	

# This function checks if the position is walkable in the tilemap.
func is_point_walkable(position):
	var map_position = local_to_map(position)
	
	# if the position is in the map and is walkable
	if astar.region.has_point(map_position) and !astar.is_point_solid(map_position):
		return true
	
	return false
