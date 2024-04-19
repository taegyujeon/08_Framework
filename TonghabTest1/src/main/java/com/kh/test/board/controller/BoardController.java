package com.kh.test.board.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;

import com.kh.test.board.model.dto.Board;
import com.kh.test.board.model.service.BoardService;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@Controller
@RequiredArgsConstructor
public class BoardController {
	
	private final BoardService service;
	
	
	@GetMapping("search")
	public String search(
	        @RequestParam("searchBoard") String searchBoard,
	        Model model
	) {
	    List<Board> board = service.searchSuccess(searchBoard);
	    if (!board.isEmpty()) {
	        model.addAttribute("board", board);
	        return "/searchSuccess";
	    } else {
	        return "/searchFail";
	    }
	}
	
	
}
