package com.jtg.book.main.model.service;

import java.util.List;

import com.jtg.book.main.model.dto.Book;

public interface MainService {

	/** 모든 책 조회
	 * @return result
	 */
	List<Book> selectBookList();

}
