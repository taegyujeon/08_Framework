package edu.kh.project.member.model.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import edu.kh.project.member.model.dto.Member;
import edu.kh.project.member.model.mapper.MemberMapper;

@Service // 비즈니스 로직 처리 역할 + Bean 등록
public class MemberServiceImpl implements MemberService{

	// 등록된 bean 중에서 같은 타입 또는 상속관계인 bean을
	// 자동으로 의존성 주입(DI)
	@Autowired 
	private MemberMapper mapper;
	
	// BCrypt 암호화 객체 의존성 주입(SecurityConfig 참고)
	@Autowired
	private BCryptPasswordEncoder bcrypt;
	
	
	// 로그인 서비스
	@Override
	public Member login(Member inputMember) {
		
		// 테스트(디버그 모드)
		
		// bcrypt.encode(문자열) : 문자열을 암호화하여 반환
		// String bcryptPassword = bcrypt.encode(inputMember.getMemberPw());
		
		// 1. 이메일이 일치하면서 탈퇴하지 않은 회원 조회
		Member loginMember = mapper.login(inputMember.getMemberEmail());
		
		// 2. 만약에 일치하는 이메일이 없어서 조회 결과가 null 인 경우
		if(loginMember == null) return null;
		
		// 3. 입력 받은 비밀번호 (inputMember.getMemberPw() (평문))와 
		//    암호화된 비밀번호(loginMember.getMemverPw() 
		//    두 비밀번호가 일치하는지 확인
		
		// 일치하지 않으면
		if(bcrypt.matches(inputMember.getMemberPw(), loginMember.getMemberPw())) {
			return null;
		}
		
		// 로그인 결과에서 비밀번호 제거
		loginMember.setMemberPw(null);
		
		return loginMember;
	}
	
}




/* BCrypt 암호화 (Spring Security 제공)
 * 
 * - 입력된 문자열(비밀번호)에 salt를 추가한 후 암호화
 * -> 암호화 할 때 마다 결과가 다름
 * 
 * ex) 1234 입력      -> $12!asdfg
 * ex) 1234 다시 입력 -> $12!qwexs
 * 
 * - 비밀번호 확인 방법
 *  -> BCryptPasswordEncoder.matches(평문 비밀번호,암호화된 비밀번호)
 *     -> 평문 비밀번호와
 *     	  암호화된 비밀번호가 같은 경우 true
 *     	  아니면 false 반환
 * 
 *  * 로그인/ 비밀번호 변경/ 탈퇴 등 비밀번호가 입력되는 경우
 *    DB에 저장된 암호화된 비밀번호를 조회 해서
 *    matches() 메서드로 비교해야 한다!!
 */




















































