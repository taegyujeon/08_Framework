/* 모든 책 조회 */
const selectBookList = document.querySelector("#selectBookList");

const bookList = document.querySelector("#bookList");

const createTd = (text) =>{
    const td = document.createElement("td");
    td.innerText = text;
    return td;
}

// 조회 버튼 클릭 시
selectBookList.addEventListener("click", () => {

    // 1) 비동기로 회원 목록 조회
    //   (포함될 회원 정보 : 회원번호, 이메일, 닉네임, 탈퇴여부)
    fetch("book/selectBookList")
    .then(response => response.json())
    .then(list => {
      console.log(list);
  
      // 이전 내용 삭제
      bookList.innerHTML = "";
  
      // tbody에 들어갈 요소를 만들고 값 세팅 후 추가
      list.forEach( (book, index) => {
        // member : 반복 접근한 요소(순서대로 하나씩 꺼낸 요소)
        // index : 현재 접근 중인 index
  
        // tr 만들어서 그 안에 td 만들어서 append 후
        // tr을 tbody에 append
  
        const keyList = ['bookNo', 'bookTitle', 'bookWriter', 'bookPrice','regDate'];
  
        const tr = document.createElement("tr"); 
  
        // keyList에서 key를 하나씩 얻어온 후
        // 해당 key에 맞는 member 객체 값을 얻어와
        // 생성되는 td 요소에 innerText로 추가 후
        // tr요소의 자식으로 추가
        keyList.forEach( key => tr.append( createTd(book[key]) ) );
        
        // tbody 자식으로 tr 추가
        bookList.append(tr);
      })
    });
  
  
    //   첫 번째 then(response => response.json()) ->
    //   JSON Array -> JS 객체 배열로 변환 [{}, {}, {}, {}] 
  
    // 2) 두 번째 then
    //    tbody에 이미 작성되어 있던 내용(이전에 조회한 목록) 삭제
  
    // 3) 두 번째 then
    //    조회된 JS 객체 배열을 이용해
    //    tbody에 들어갈 요소를 만들고 값 세팅 후 추가
  
});