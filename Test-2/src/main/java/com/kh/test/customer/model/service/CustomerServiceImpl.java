package com.kh.test.customer.model.service;

import org.springframework.stereotype.Service;

import com.kh.test.customer.model.dto.Customer;
import com.kh.test.customer.model.mapper.CustomerMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CustomerServiceImpl implements CustomerService{
	
	private final CustomerMapper mapper;
	
	@Override
	public int resultPage(Customer inputCustomer) {
		
		return mapper.resultPage(inputCustomer);
	}
	
}
