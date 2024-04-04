package edu.kh.project.myPage.model.service;

import java.io.IOException;

import org.springframework.web.multipart.MultipartFile;

import edu.kh.project.member.model.dto.Member;

public interface MyPageService {

	/** 회원 정보 수정
	 * @param inputMember
	 * @param memberAddress
	 * @return result
	 */
	int updateInfo(Member inputMember, String[] memberAddress);
	
	
	/** 비밀번호 수정
	 * @param currentPw
	 * @param newPw
	 * @param loginMember
	 * @return result
	 */
	int memberPw(String currentPw, String newPw, Member loginMember);


	/** 회원 탈퇴
	 * @param memberPw
	 * @param loginMember
	 * @return result
	 */
	int selectPw(String memberPw, Member loginMember);


	/** 파일 업로드 테스트1
	 * @param uploadFile
	 * @return path
	 */
	String fileUpload1(MultipartFile uploadFile) throws IllegalStateException, IOException;
	
	

}
