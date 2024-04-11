package com.jtg.book.main.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Book {
	private int bookNo;
	private String bookTitle;
	private String bookWriter;
	private int bookPrice;
	private String regDate;
}
