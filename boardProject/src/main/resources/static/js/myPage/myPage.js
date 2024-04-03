/* 회원 정보 수정 페이지 */
const updateInfo = document.querySelector("#updateInfo"); // form 태그

// #updateInfo 요소가 존재 할 때만  수행
if(updateInfo != null){

    updateInfo.addEventListener("submit",e=>{

        const memeberNickname = document.querySelector("#memberNickname");
        const memberTel = document.querySelector("#memberTel");
        const memeberAddress = document.querySelector("[name='memeberAddress']");

        // 닉네임 유효성 검사
        if(memeberNickname.value.trim().length == 0){
            alert("닉네임을 입력해주세요.");
            e.preventDefault(); // 제출 막기
            return;
        }
        
        // 정규식에 맞지 않으면
        let regExp = /^[가-힣\w\d]{2,10}$/;
        if( !regExp.test(memberNickname.value) ){
        alert("닉네임이 유효하지 않습니다");
        e.preventDefault(); // 제출 막기
        return;
        }

        // *****************************************************
        // 중복 검사는 나중에 추가 예정
        // (테스트 시 닉네임 중복 안되게 조심!!!)
        // *****************************************************

        // 전화 번호 유효성 검사
        if(memberTel.value.trim().length == 0){
            alert("전화번호를 입력해주세요.");
            e.preventDefault(); // 제출 막기
            return;
        }

        // 정규식에 맞지 않으면
        regExp = /^01[0-9]{1}[0-9]{3,4}[0-9]{4}$/;
        if( !regExp.test(memberTel.value) ){
        alert("전화번호가 유효하지 않습니다");
        e.preventDefault(); // 제출 막기
        return;
        }

        // 주소 유효성 검사
        // 입력을 안하면 전부 안해야되고
        // 입력을 하면 전부 해야된다

        const addr0 = memeberAddress[0].value.trim().length == 0; // t/f
        const addr1 = memeberAddress[1].value.trim().length == 0; // t/f
        const addr2 = memeberAddress[2].value.trim().length == 0; // t/f

        // 모두 true인 경우만 true 저장
        const result1 = addr0 && addr1 && addr2; // 아무것도 입력 x
        
        // 모두 false인 경우만 true 저장
        const result2 = !(addr0 || addr1 || addr2); // 모두 다 입력

        // 모두 입력 또는 모두 미입력이 아니면
        if(result1 || result2){
            alert("주소를 모두 작성 또는 미작성 해주세요.")
            e.preventDefault(); // 제출 막기
        }



        e.preventDefault(); // 제출 막기
    });

}