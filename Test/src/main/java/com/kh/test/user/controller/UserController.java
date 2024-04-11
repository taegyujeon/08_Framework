package com.kh.test.user.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.kh.test.user.model.dto.User;
import com.kh.test.user.model.service.UserService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class UserController {
	
	private final UserService service;
	
	@GetMapping("search")
	public String search(
			@RequestParam("searchUserId") String searchUserId,
			Model model) {
		
		User user = service.searchSuccess(searchUserId);
		
		String path = null;
		
		if(user != null) {
			
			path = "/searchSuccess";
			model.addAttribute("user",user);
			
			
		}else {
			path = "/searchFail";
		}
		
		return path;
	}
	
	
	
	
}
