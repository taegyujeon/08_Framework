package edu.kh.project.myPage.model.service;

import java.io.File;
import java.io.IOException;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

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
			// 다를 경우
			return 0;
		}else {
			
			// 같을 경우
			
			// 새 비밀번호를 암호화 
			String encPw = bcrypt.encode(newPw);
			
			loginMember.setMemberPw(encPw);
			
			return mapper.changePw(loginMember);
		}
		
	}
	
	
	@Override
	public int selectPw(String memberPw, Member loginMember) {
		
		String inputPw = mapper.inputPw(loginMember);
		
		if(!bcrypt.matches(memberPw,inputPw)) {
			// 다를 경우
			return 0;
		}else {
			// 같을 경우
			
			return mapper.secession(loginMember);
		}
		
	}
	
	// 파일 업로드 테스트
	@Override
	public String fileUpload1(MultipartFile uploadFile) throws IllegalStateException, IOException {
		
		// MultipartFile이 제공하는 메서드
		// - getSize() : 파일 크기
		// - isEmpty() : 업로드한 파일이 없을 경우 true
		// - getOriginalFileName(): 원본 파일 명
		// - transferTo(경로):
		//   메모리 또는 임시 저장 경로에 업로드된 파일을 
		//   원하는 경로에 전송(서버 어떤 폴더에 저장할 지 지정)
		
		if(uploadFile.isEmpty()) { // 업로드한 파일이 없을 경우
			
			return null;
		}
			// 업로드한 파일이 있을 경우
			// C:\\uploadFiles\\test\\파일명 으로 서버에 저장
			uploadFile.transferTo(new File("C:\\uploadFiles\\test\\" + uploadFile.getOriginalFilename()));
			
			// 웹에서 해당 파일에 접근 할 수 있는 경로를 반환
			
			// 서버 : C:\\uploadFiles\\test\\a.jpg
			// 웹 접근 주소 : /myPage/file/a.jpg 
			return "/myPage/file/" + uploadFile.getOriginalFilename();
		}
		
	

}













































