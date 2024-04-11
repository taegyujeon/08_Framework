package com.kh.test.customer.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;

import com.kh.test.customer.model.dto.Customer;
import com.kh.test.customer.model.service.CustomerService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class CustomerController {
	
	private final CustomerService service;
	
	@PostMapping("resultPage")
	public String resultPage(
			Customer inputCustomer
			) {
		
		int result = service.resultPage(inputCustomer);
		
		String path = null;
		
		if(result > 0) {
			path = "result";
		}else {
			path = "error";
		}
		
		
		return path;
		
	}
	
}
