package edu.kh.project.myPage.model.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.kh.project.member.model.dto.Member;
import edu.kh.project.myPage.model.mapper.MyPageMapper;
import lombok.RequiredArgsConstructor;

@Service
@Transactional
@RequiredArgsConstructor
public class MyPageServiceImpl implements MyPageService{
	
	private final BCryptPasswordEncoder bcrypt;
	private final MyPageMapper mapper;
	
	// @RequiredArgsConstructor 를 이용했을 때 자동 완성 되는 구문
	//	@Autowired
	//	public MyPageServiceImpl(MyPageMapper mapper) {
	//		this.mapper = mapper;
	//	}
	
	@Override
	public int updateInfo(Member inputMember, String[] memberAddress) {
		
		// 입력된 주소가 있을 경우 
		// memberAddress를 A^^^B^B^^^C 형태로 가공
		
		// 주소 입력 X -> inputMember.getMemberAddress()  -> ",,"
		if( inputMember.getMemberAddress().equals(",,") ) {
			
			// 주소에 null 대입
			inputMember.setMemberAddress(null);
		}else {
		//  memberAddress를 A^^^B^^^C 형태로 가공
			String address = String.join("^^^", memberAddress);
			
			// 주소에 가공된 데이터 대입
			inputMember.setMemberAddress(address);
		}
		
		//SQL 수행 후 결과 반환
		return mapper.updateInfo(inputMember);
	}
	
	
	@Override
	public int memberPw(String currentPw, String newPw, Member loginMember) {
		
		String currPw = mapper.currPw(loginMember);
		
		if(!bcrypt.matches(currentPw, currPw)) {
			return 0;
		}else {
			String encPw = bcrypt.encode(newPw);
			
			loginMember.setMemberPw(encPw);
			
			return mapper.changePw(loginMember);
		}
		
	}
	

}













































