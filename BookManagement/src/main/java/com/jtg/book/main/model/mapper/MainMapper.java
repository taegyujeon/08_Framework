package com.jtg.book.main.model.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.jtg.book.main.model.dto.Book;

@Mapper
public interface MainMapper {

	/** 모든 책 조회
	 * @return result
	 */
	List<Book> selectBookList();

}
