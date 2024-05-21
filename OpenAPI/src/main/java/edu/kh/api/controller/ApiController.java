package edu.kh.api.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.boot.configurationprocessor.json.JSONException;
import org.springframework.boot.configurationprocessor.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class ApiController {

	
	/** Ajax로 Open API 요청하는 페이지로 포워드
	 * @return
	 */
	@GetMapping("ex1")
	public String ex1() {
		return "ex1";
	}
	
	@GetMapping("ex2")
	public String ex2(
			@RequestParam(value="regionName",
			              required=false,
			              defaultValue="서울") String regionName,
			Model model) throws IOException, JSONException {
		
		String serviceKey = "BTjX5Rqk5SZSwrW687YxxqoqoH7FbYV/BKqfde1PPn0jiIoOy6aYAUb1MuK7h9izWzM/YX6SVOjBBUMIuwRRIg==";
		int numOfRows = 1000; // 조회할 데이터 개수
		int pageNo = 1; // 조회할 페이지
		String dataType = "JSON"; // 응답 데이터 타입(JSON/XML)

		
		// 지역 좌표가 저장된 map
		final Map<String, String> coordinateList = new HashMap<>();
		
		coordinateList.put("서울", "60/127");
		coordinateList.put("경기", "60/120");
		coordinateList.put("인천", "55/38");
		coordinateList.put("제주", "52/38");
		coordinateList.put("세종", "66/103");
		coordinateList.put("광주", "58/74");
		coordinateList.put("대구", "89/90");
		coordinateList.put("대전", "67/100");
		coordinateList.put("부산", "98/76");
		coordinateList.put("울산", "102/84");
		coordinateList.put("강원", "73/134");
		coordinateList.put("경북", "89/91");
		coordinateList.put("경남", "91/77");
		coordinateList.put("전북", "63/89");
		coordinateList.put("전남", "51/67");
		coordinateList.put("충북", "69/107");
		coordinateList.put("충남", "68/100");
		
		
		
		// 현재 시간 얻어와 baseDate, baseTime가공
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd/HH/mm");
		String[] arr = (sdf.format(new Date())).split("/");
		
		String baseDate = arr[0];
		
		int hour = Integer.parseInt(arr[1]);
		int minute  = Integer.parseInt(arr[2]);
		
		// 매시간 30분에 생성되고 10분마다 최신 정보로 업데이트(기온, 습도, 바람)
		String baseTime = "";
		if(minute <= 45) { 
			if(hour == 0) hour = 24;
			
			baseTime = String.format("%02d30", hour-1);
		}else {
			
			baseTime = String.format("%02d30", hour );
		}
		
		String[] coordinate = (coordinateList.get(regionName)).split("/");
		String nx = coordinate[0];
		String ny = coordinate[1];
		
		// 샘플 코드 활용해서 데이터 요청
		
		// StringBuilder: String의 단점(불변성)을 해결한 객체
		StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"); /*URL*/
		
		
		urlBuilder.append("?" + URLEncoder.encode("serviceKey","UTF-8") 	+ "=" + serviceKey); /*Service Key*/
		
        urlBuilder.append("&" + URLEncoder.encode("pageNo","UTF-8") 		+ "=" + URLEncoder.encode(String.valueOf(pageNo), "UTF-8")); /*페이지번호*/
        
        urlBuilder.append("&" + URLEncoder.encode("numOfRows","UTF-8") 		+ "=" + URLEncoder.encode(String.valueOf(numOfRows), "UTF-8")); /*한 페이지 결과 수*/
        
        urlBuilder.append("&" + URLEncoder.encode("dataType","UTF-8") 		+ "=" + URLEncoder.encode(dataType, "UTF-8")); /*요청자료형식(XML/JSON) Default: XML*/
        
        urlBuilder.append("&" + URLEncoder.encode("base_date","UTF-8") 		+ "=" + URLEncoder.encode(baseDate, "UTF-8")); /*‘21년 6월 28일 발표*/
        
        urlBuilder.append("&" + URLEncoder.encode("base_time","UTF-8") 		+ "=" + URLEncoder.encode(baseTime, "UTF-8")); /*06시 발표(정시단위) */
        
        urlBuilder.append("&" + URLEncoder.encode("nx","UTF-8") 			+ "=" + URLEncoder.encode(nx, "UTF-8")); /*예보지점의 X 좌표값*/
        
        urlBuilder.append("&" + URLEncoder.encode("ny","UTF-8") 			+ "=" + URLEncoder.encode(ny, "UTF-8")); /*예보지점의 Y 좌표값*/
        
        // 위에서 조합한 요청주소 + 쿼리스트링 문자열로 
        // 요청을 보낼 수 있는 형태의 객체로 변환
        URL url = new URL(urlBuilder.toString());
        
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        
        conn.setRequestMethod("GET");// 요청 메서드 GET
        
        conn.setRequestProperty("Content-type", "application/json");
        
        // 응답 상태 코드(200 : 성공, 404 : 페이지 찾을 수 없음 ...)
        System.out.println("Response code: " + conn.getResponseCode());
        
        // 입력 보조 스트림
        BufferedReader rd;
        
        // 응답 상태 코드가 200~300인 경우(요청/응답 성공인 경우)
        if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 300) {
        	
        	// InputStreamReader: 바이트 기반 입력 스트림을 문자 기반으로 변경
        	
        	// 문자 형태로 빨리 입력 받기 위한 준비(응답 데이터 빨리 받기)
            rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        } else {
            rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
        }
        
        StringBuilder sb = new StringBuilder();
        String line;
        
        // 데이터를 한 줄 씩 계속 읽어 들여서 sb에 추가
        // 더 이상 읽을 내용이 없으면 반복문 종료
        while ((line = rd.readLine()) != null) {
            sb.append(line);
        }
        rd.close();        // 다 쓴 스트림 자원 반환
        conn.disconnect(); // 외부 요청 연결 끊기
        System.out.println(sb.toString()); // 결과 출력
        
        //-----------------------------------------------------------------------------------
        
        // JSONObject : Spring에서 제공하는 JSON 다루기 객체
        JSONObject j1 = new JSONObject(sb.toString());
        
        // j1에서 얻어온 response 데이터를 JSONObject로 변환
        JSONObject j2 = new JSONObject(j1.getString("response"));

        JSONObject j3 = new JSONObject(j2.getString("body"));

        JSONObject j4 = new JSONObject(j3.getString("items"));

        String item = j4.getString("item"); // JSON(문자열)
        
        // JSON -> Map으로 변경 (Jackson 라이브러리 이용)
        
        // (Jackson : JSON <-> DTO/map 라이브러리)
        ObjectMapper objectMapper = new ObjectMapper();

        // item(JSON)을 List<Map>으로 변경
        List<Map<String, String>> List = objectMapper.readValue(item, List.class);
        
        
        
        // list에서 필요한 데이터만 꺼내는 작업
        
        Map<String, String> weatherMap = new HashMap<>();
        
        // 현재 시간으로 부터 가장 가까운 시간대 얻어오기
        weatherMap.put("fcstDate", List.get(0).get("fcstDate"));
        weatherMap.put("fcstTime", List.get(0).get("fcstTime"));
        
        // 조회된 많은 데이터 중
        // 현재 시간으로 부터 가장 까가운 시간대의 데이터만 모아두기
        for(Map<String, String> map : List){
            if(map.get("fcstDate").equals(weatherMap.get("fcstDate")) &&
        		map.get("fcstTime").equals(weatherMap.get("fcstTime"))){

            	weatherMap.put((String)map.get("category"), map.get("fcstValue"));
            }
        }
        
        String sky = null;
        switch(weatherMap.get("SKY")){
        case "1": sky = "맑음";    	break;
        case "3": sky = "구름많음"; break;
        case "4": sky = "흐림"; 	break;
        }
        
        
        String pty = null;
        switch(weatherMap.get("PTY")){
        case "0": pty = "없음";    	break;
        case "1": pty = "비";    	break;
        case "2": pty = "비/눈";    	break;
        case "3": pty = "눈";    	break;
        case "5": pty = "빗방울"; break;
        case "6": pty = "빗방울눈날림"; 	break;
        case "7": pty = "눈날림"; 	break;
        }
        
        weatherMap.put("SKY", sky);
        weatherMap.put("PTY", pty);
        
	    
	    model.addAttribute("weatherMap", weatherMap);
        
		return "ex2";
	}
	
	
}










































