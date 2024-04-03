package edu.kh.project.myPage.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import edu.kh.project.member.model.dto.Member;
import edu.kh.project.myPage.model.service.MyPageService;
import lombok.RequiredArgsConstructor;
import oracle.jdbc.proxy.annotation.Post;

@Controller
@RequestMapping("myPage")
@RequiredArgsConstructor
public class MyPageController {
	
	private final MyPageService service;
	
	
	/** 내 정보 조회/수정 화면으로 전환
	 * 
	 * @param loginMember
	 * :세션에 존재하는 loginMember를 얻어와 매개 변수에 대입
	 * 
	 * @param model: 데이터 전달용 객체(기본 request scope)
	 * 
	 * @return myPage/myPage-info.html 요청 위임
	 */
	@GetMapping("info") //   /myPage/info (GET)
	public String info(
			@SessionAttribute("loginMember") Member loginMember,
			Model model
			) {
			
			// 주소만 꺼내옴
			String memberAddress = loginMember.getMemberAddress();
			
			// 주소가 있을 경우에만 동작
			if(memberAddress != null) {
				
				// 구분자 "^^^"를 기준으로
				// memberAddress 값을 쪼개어 String[]로 반환
				String[] arr = memberAddress.split("\\^\\^\\^");
				
				// "04540^^^서울시 중구 남대문로 120^^^2층 A강의장"
				// --> ["04540", "서울시 중구 남대문로 120", "2층 A강의장"]
				model.addAttribute("postcode"      , arr[0]);
				model.addAttribute("address"       , arr[1]);
				model.addAttribute("detailAddress" , arr[2]);
				
			}
			
			// /templates/myPage/myPage-info.html로 forward
			return "myPage/myPage-info";
		}
	
	
	/** 프로필 이미지 변경 화면 이동
	 */
	@GetMapping("profile")
	public String profile() {
		return "myPage/myPage-profile";
	}
	
	
	/** 비밀번호 변경 화면 이동
	 */
	@GetMapping("changePw")
	public String changePw() {
		return "myPage/myPage-changePw";
	}
	
	/** 회원 탈퇴 화면 이동
	 */
	@GetMapping("secession")
	public String secession() {
		return "myPage/myPage-secession";
	}
	
	
	/** 회원 정보 수정
	 * @param inputMember : 제출된 회원 닉네임, 전화번호, 주소
	 * @param loginMember : 로그인한 회원 정보(회원 번호 사용할 예정)
	 * @param memberAddress : 주소만 따로 받은 String[]
	 * @return
	 */
	@PostMapping("info")
	public String updateInfo(
			Member inputMember,
			@SessionAttribute("loginMember") Member loginMember,
			@RequestParam("memberAddress") String[] memberAddress,
			RedirectAttributes ra) {
		
		// inputMember에 로그인한 회원번호 추가
		int memberNo = loginMember.getMemberNo();
		inputMember.setMemberNo(memberNo);
		
		// 회원 정보 수정 서비스 호출
		int result = service.updateInfo(inputMember, memberAddress);
		
		String message = null;
		
		if(result > 0) {
			message = "회원 정보 수정 성공!!!";
			
			// loginMember는 
			// 세션에 저장된 로그인된 회원 정보가 저장된 객체를
			// 참고 하고 있다!!
			// -> loginMember를 수정하면
			//    세션에 저장된 로그인된 회원정보가 수정된다!!!
			// == 세션 데이터가 수정됨
			loginMember.setMemberNickname(inputMember.getMemberNickname());
			
			loginMember.setMemberTel(inputMember.getMemberTel());

			loginMember.setMemberAddress(inputMember.getMemberAddress());
			
			
		}else {
			message = "회원 정보 수정 실패...";
		}
		
		ra.addFlashAttribute("message",message);
		
		return "redirect:info";
	}
	
	
	/** 비밀번호 수정
	 * @param currentPw
	 * @param newPw
	 * @param loginMember : 세션 로그인한 회원 정보
	 * @param ra
	 * @return
	 */
	@PostMapping("changePw")
	public String changePw(
			@RequestParam("currentPw") String currentPw,
			@RequestParam("newPw") String newPw,
			@SessionAttribute("loginMember") Member loginMember,
			RedirectAttributes ra){
		
		int result = service.memberPw(currentPw, newPw, loginMember);
		
		String message = null;
		String path = null;
		
		if(result == 0) {
			message = "변경 실패";
			path = "myPage/changePw";
		}else {
			message = "변경 성공";
			path = "myPage/info";
		}
		
		ra.addFlashAttribute("message",message);
		
		return "redirect:/" + path;
	}
	
	
	
	
}















































