class_name BoardSpace

var board_state: BoardState
var name: String
var type: SpaceType
var pieces: Array[GamePiece] = []
var light: bool
var row: int = 0
var column: int = 0

func _init(_board_state: BoardState, _name: String, _type: SpaceType, _light: bool, _row: int, _column: int):
	board_state = _board_state
	name = _name
	type = _type
	light = _light
	row = _row
	column = _column

func get_texture() -> Texture2D:
	return type.light_texture if light else type.dark_texture

func get_adjacent_spaces(distance: int=1) -> Array[BoardSpace]:
	var spaces: Array[BoardSpace] = []

	if row > distance - 1:
		spaces.append(board_state.spaces[row - distance][column])

	if row < len(board_state.spaces) - distance:
		spaces.append(board_state.spaces[row + distance][column])

	if column > distance - 1:
		spaces.append(board_state.spaces[row][column - distance])

	if column < len(board_state.spaces[row]) - distance:
		spaces.append(board_state.spaces[row][column + distance])

	return spaces

func get_space_relative(_row: int, _column: int) -> BoardSpace:
	if row + _row >= 0 and row + _row < len(board_state.spaces) and column + _column >= 0 and column + _column < len(board_state.spaces[row]):
		return board_state.spaces[row + _row][column + _column]
	return null

func get_diagonal_spaces(distance: int=1) -> Array[BoardSpace]:
	var spaces: Array[BoardSpace] = []

	if row > distance - 1 and column > distance - 1:
		spaces.append(board_state.spaces[row - distance][column - distance])

	if row > distance - 1 and column < len(board_state.spaces[row]) - distance:
		spaces.append(board_state.spaces[row - distance][column + distance])

	if row < len(board_state.spaces) - distance and column > distance - 1:
		spaces.append(board_state.spaces[row + distance][column - distance])

	if row < len(board_state.spaces) - distance and column < len(board_state.spaces[row]) - distance:
		spaces.append(board_state.spaces[row + distance][column + distance])

	return spaces

func get_copy(_board_state) -> BoardSpace:
	var new_space = BoardSpace.new(_board_state, name, type, light, row, column)

	for piece in pieces:
		new_space.pieces.append(piece.get_copy(new_space))

	return new_space

func piece_num() -> int:
	return len(pieces)

func get_potential_moves() -> Array[Array]:
	var moves: Array[Array] = []

	if board_state.complete:
		return moves
	if pieces[- 1] is Kili:
		if len(board_state.get_unused_pieces_for_player(board_state.get_current_player())) > 0:
			moves.append(pieces[- 1].get_potential_moves(board_state.get_current_player(), false))#Add kili promotion if there's one on top and there is a piece available
	else:
		var noCarry = pieces[- 1].get_potential_moves(board_state.get_current_player(), false)

		if len(noCarry) > 0:
			moves.append(noCarry)#Add an array of non-carrying moves if there are any

		var carry = pieces[- 1].get_potential_moves(board_state.get_current_player(), true)

		if len(carry) > 0:
			moves.append(carry)#Add an array of carrying moves if there are any
	
		if len(pieces) > 1 and pieces[0] is Kili and len(board_state.get_unused_pieces_for_player(board_state.get_current_player())) > 0:
			moves.append(pieces[0].get_potential_moves(board_state.get_current_player(), false))#Add kili promotion if there's one on bottom and there is a piece availabl

	return moves
