package com.kh.test.board.model.service;

import java.util.List;

import com.kh.test.board.model.dto.Board;

public interface BoardService {
	
	/** 게시글 조회
	 * @param searchBoard
	 * @return result
	 */
	List<Board> searchSuccess(String searchBoard);

}
