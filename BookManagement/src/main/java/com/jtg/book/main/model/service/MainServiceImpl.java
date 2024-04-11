package com.jtg.book.main.model.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.jtg.book.main.model.dto.Book;
import com.jtg.book.main.model.mapper.MainMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MainServiceImpl implements MainService{
	
	private final MainMapper mapper;
	
	
	/* 모든 책 조회 */
	@Override
	public List<Book> selectBookList() {
		
		return mapper.selectBookList();
	}
	
}
