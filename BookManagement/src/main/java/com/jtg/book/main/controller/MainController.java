package com.jtg.book.main.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.jtg.book.main.model.dto.Book;
import com.jtg.book.main.model.service.MainService;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MainController {
	
	private final MainService service;
	
	@RequestMapping("/") // "/" 요청 매핑(method 가리지 않음)
	public String mainPage() {

		return "common/main";
	}
	
	/* 모든 책 조회 */
	@ResponseBody
	@GetMapping("selectBookList")
	public List<Book> selectBookList(){
		
		return service.selectBookList();
	}
	
}
