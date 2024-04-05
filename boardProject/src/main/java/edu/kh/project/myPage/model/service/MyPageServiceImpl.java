package edu.kh.project.myPage.model.service;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.multipart.MultipartFile;

import edu.kh.project.common.util.Utility;
import edu.kh.project.member.model.dto.Member;
import edu.kh.project.myPage.model.dto.UploadFile;
import edu.kh.project.myPage.model.mapper.MyPageMapper;
import lombok.RequiredArgsConstructor;

@Service
@Transactional(rollbackFor = Exception.class) // 모든 예외 발생 시 롤백
@RequiredArgsConstructor
@PropertySource("classpath:/config.properties")
public class MyPageServiceImpl implements MyPageService{
	
	private final BCryptPasswordEncoder bcrypt;
	private final MyPageMapper mapper;
	
	@Value("${my.profile.web-path}")
	private String profileWebPath;
	
	@Value("${my.profile.folder-path}")
	private String profileFolderPath;
	
	
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
		
	
	
	@Override
	public int fileUpload2(MultipartFile uploadFile, int memberNo) throws IllegalStateException, IOException {
		
		// 업로드된 파일이 없다면
		// == 선택된 파일이 없을 경우
		if(uploadFile.isEmpty()) {
			return 0;
		}
		
		/* DB에 파일 저장이 가능은 하지만
		 * DB 부하를 줄이기 위해서 
		 * 1) DB에는 서버에 저장할 파일 경로를 저장
		 * 2) DB 삽입/수정 성공 후 서버에 파일을 저장
		 * 3) 만약에 파일 저장 실패 시 
		 *    - 강제로 예외 발생
		 *    -> @Transactional을 이용해 rollback 수행
		 * 
		 */
		
		// 1. 서버에 저장할 파일 경로 만들기
		
		// 파일이 저장될 서버 폴더 경로
		String folderPath = "C:\\uploadFiles\\test\\";
		
		// 클라이언트가 파일이 저장된 폴더에 접근 할 수 있는 주소
		String webPath = "/myPage/file/";
		
		// 2. DB에 전달할 데이터를 DTO로 묶어서 INSERT 호출하기
		// webPath, memberNo, 원본 파일명, 변경된 파일명
		
		// 변경된 파일명
		String fileRename = Utility.fileRename(uploadFile.getOriginalFilename());
		
		// Builder 패턴을 이용해서 UploadFile 객체 생성
		// 장점 1) 반복되는 참조변수명, set 구문 생략
		// 장점 2) method chaining을 이용해서 한 줄로 작성 가능
		
		UploadFile uf = UploadFile.builder()
						.memberNo(memberNo)
						.filePath(webPath)
						.fileOriginalName(uploadFile.getOriginalFilename())
						.fileRename(fileRename)
						.build();
		
		int result = mapper.insertUploadFile(uf);
		
		// 3. 삽입(INSERT) 성공 시 파일을 지정된 서버 폴더에 저장
		
		// 삽입 실패 시
		if(result == 0) return 0;
		
		// 삽입 성공 시
		
		// C:\\uploadFiles\\test\\변경된파일명 으로 
		// 파일을 서버에 저장
		
		uploadFile.transferTo(new File(folderPath + fileRename));
		// -> ChekcedException 발생 -> 예외 처리 필수
		
		// @Transactional은 UnCheckedExcpetion만 처리
		//  -> rollbackFor 속성을 이용해서
		//   롤백할 예외 범위를 수정
		
		return result; // 1
	}
	
	
	// 파일 목록 조회 
	@Override
	public List<UploadFile> fileList() {
		
		return mapper.fileList();
	}
	
	// 여러 파일 업로드
	@Override
	public int fileUpload3(List<MultipartFile> aaaList, List<MultipartFile> bbbList, int memberNo)
			throws IllegalStateException, IOException {
		
		// 1. aaaList 처리
		
		int result1 = 0;
		
		// 업로드된 파일이 없을 경우를 제외하고 업로드
		for(MultipartFile file : aaaList) {
			if(file.isEmpty()) { // 파일 없으면 다음 파일
				continue;
			}
			
			//fileUpload2() 메서드 호출
			// -> 파일 하나 업로드 + DB INSERT
			result1 += fileUpload2(file,memberNo);
		}
		
		
		// 2. bbbList 처리
		
		int result2 = 0;
		
		// 업로드된 파일이 없을 경우를 제외하고 업로드
		for(MultipartFile file : bbbList) {
			if(file.isEmpty()) { // 파일 없으면 다음 파일
				continue;
			}
			
			//fileUpload2() 메서드 호출
			// -> 파일 하나 업로드 + DB INSERT
			result2 += fileUpload2(file,memberNo);		
	  }
		
		return result1 + result2;
		
    }
	
	
	// 프로필 이미지 변경
	@Override
	public int profile(MultipartFile profileImg, Member loginMember) throws IllegalStateException, IOException {
		
		// 수정할 경로
		String updatePath = null;
		
		// 변경명 저장
		String rename = null;
		
		// 업로드한 이미지
		if( !profileImg.isEmpty() ) {
			
			// updatePath 조합
			
			// 파일명 변경
			rename = Utility.fileRename(profileImg.getOriginalFilename());
			
			//   /myPage/profile/변경된파일명.jpg
			updatePath = profileWebPath + rename;
			
			
		}
		
		
		// 수정된 프로필 이미지 경로 + 회원 번호를 저장할 DTO 객체
		Member mem = Member.builder()
						.memberNo(loginMember.getMemberNo())
						.profileImg(updatePath)
						.build();
		
		// UPDATE 수행
		int result = mapper.profile(mem);
		
		if(result > 0) { // 수정 성공 시
			
			// 프로필 이미지를 없앤 경우 (NULL로 수정한 경우)를 제외
			// -> 업로드한 이미지가 있을 경우
			if(!profileImg.isEmpty()) {
				
				// 파일을 서버 지정된 폴더에 저장
				profileImg.transferTo(new File(profileFolderPath + rename));
			}
			
			// 세션 회원 정보에서 프로필 이미지 경로를
			// 업데이트한 경로로 변경
			loginMember.setProfileImg(updatePath);
		}
		
		return result;
	}
	
	
	
	
	
	

}













































