package edu.kh.project.myPage.model.service;

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

}
