/* 서비스키(인증키) */
const serviceKey = "BTjX5Rqk5SZSwrW687YxxqoqoH7FbYV/BKqfde1PPn0jiIoOy6aYAUb1MuK7h9izWzM/YX6SVOjBBUMIuwRRIg==";

const numOfRows = 1000; // 조회할 데이터 개수
const pageNo = 1; // 조회할 페이지
const dataType = "JSON"; // 응답 데이터 타입(JSON/XML)


// 화면 요소 얻어오기
const region = document.getElementById("region");
const regionName = document.querySelector("#regionName");
const currentWeather = document.querySelector(".current-weather");




/* ****** 초단기 예보 비동기 요청할 함수 정의 ****** */
// regionValue : 지역명(서울, 부산, 제주...)
const getUltraSrtFcst = (regionValue) => {

  // 데이터를 요청해서 응답 받을 주소(Callback URL)
  const curl = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst";

  // 예보지점 X/Y 좌표
  //const nx = 60;
  //const ny = 127;
  const nx = coordinateList[regionValue].nx; // x좌표
  const ny = coordinateList[regionValue].ny; // y좌표

  // base_time, base_date를 얻어오는 함수
  const base = getBase();

  // 쿼리스트링을 관리하는 객체 생성
  const searchParams = new URLSearchParams();

  // 쿼리스트링에 k=v 추가
  searchParams.append("serviceKey", serviceKey);
  searchParams.append("numOfRows", numOfRows);
  searchParams.append("pageNo", pageNo);
  searchParams.append("dataType", dataType);
  searchParams.append("base_date", base.baseDate);
  searchParams.append("base_time", base.baseTime);
  searchParams.append("nx", nx);
  searchParams.append("ny", ny);


  /* ajax 코드 (fetch api) 작성 */
  fetch(`${curl}?${searchParams.toString()}`)
  .then(resp => resp.json()) // 응답 받은 JSON을 JS Object로 변환 
  .then(result => {

    console.log(result);

    // [위] 공공 데이터 Open API를 이용한 데이터 요청 및 응답
    //-----------------------------------------------------------------------------------------------------------
    // [아래] 개발자가 응답 받은 데이터 활용

    // 요청 데이처 중 item (객체 배열)
    const list = result.response.body.items.item;

    // 현재 시간으로 부터 가장 가까운 예보를 저장할 빈 객체 생성
    const weatherObj = {};

    // 예보 날짜/시간을 weatherObj에 추가
    weatherObj.fcstDate = list[0].fcstDate;
    weatherObj.fcstTime = list[0].fcstTime;
    
    // fcstDate, fcstTime 이 일치하는 정보만 weatherObj에 저장
    // -> 가장 가까운 시간대의 예보만 저장
    for(let item of list){
        if(item.fcstDate == weatherObj.fcstDate && 
            item.fcstTime == weatherObj.fcstTime){

            weatherObj[item.category] = item.fcstValue;
        }
    }

    console.log(weatherObj);

    currentWeather.innerHTML = "";

    const h1 = document.createElement("h1");
    h1.innerText = weatherObj["T1H"] + "℃";

    const p1 = document.createElement("p");
    p1.innerText = getSkyState(weatherObj["SKY"] );

    const p2 = document.createElement("p");
    p2.innerText = "습도(%) :" + weatherObj["REH"];

	  // 강수 형태
    const p3 = document.createElement("p");
    p3.innerText = "강수 형태 : " + getUltraSrtPtyState(weatherObj["PTY"]);

    const p4 = document.createElement("p");
    p4.innerText = "강수 확률(%) : " + weatherObj["RN1"];

    currentWeather.append(h1, p1, p2, p3, p4);

  });
}


// 지역별 좌표(기상청 api excel 파일 참고)
const coordinateList = {
  "서울" : {"nx":60, "ny":127},
  "경기" : {"nx":60, "ny":120},
  "인천" : {"nx":55, "ny":124},
  "제주" : {"nx":52, "ny":38},
  "세종" : {"nx":66, "ny":103},
  "광주" : {"nx":58, "ny":74},
  "대구" : {"nx":89, "ny":90},
  "대전" : {"nx":67, "ny":100},
  "부산" : {"nx":98, "ny":76},
  "울산" : {"nx":102, "ny":84},
  "강원" : {"nx":73, "ny":134},
  "경북" : {"nx":89, "ny":91},
  "경남" : {"nx":91, "ny":77},
  "전북" : {"nx":63, "ny":89},
  "전남" : {"nx":51, "ny":67},
  "충북" : {"nx":69, "ny":107},
  "충남" : {"nx":68, "ny":100}
}


/* base_date, base_time 만드는 함수 */
const getBase = () => {
    
  const base = {};
  const now = new Date();

  // base_date(오늘 날짜 YYYYMMDD 형식) 계산
  const year = now.getFullYear();

  let month = now.getMonth() + 1;
  month = month < 10 ? "0" + month : month;

  let date = now.getDate();
  date = date < 10 ? "0" + date : date;

  base.baseDate = `${year}${month}${date}`;


  // 45분 이하인 경우 1시간 전을 baseTime으로 지정
  const hour = now.getMinutes() <= 45 ? now.getHours()-1 : now.getHours()

  if(hour < 10)    base.baseTime =  "0" + hour + "00";
  else             base.baseTime =  hour + "00";
  return base;
  
}



// 하늘 상태(SKY) 코드 변환
const getSkyState = (code) => {
  code = Number(code);
  switch(code){
  case 1: return "맑음";
  case 3: return "구름많음";
  case 4: return "흐림";
  }
}

// 초단기 강수 형태(PTY) 코드 변환
const getUltraSrtPtyState = (code) => {
  code = Number(code);
  switch(code){
      case 0: return "없음";
      case 1: return "비";
      case 2: return "비/눈";
      case 3: return "눈";
      case 5: return "빗방울";
      case 6: return "빗방울눈날림";
      case 7: return "눈날림";
  }
}



/* select 변경 시 해당 지역 날씨 조회 */
region.addEventListener("change", e => {
  regionName.innerText = e.target.value; // 화면 지역명 변경
  getUltraSrtFcst(e.target.value); // 해당 지역 날씨 조회
})

/* 화면 로딩이 종료된 후 "서울" 지역 날씨 조회 */
document.addEventListener("DOMContentLoaded", () => {
  getUltraSrtFcst("서울");
})