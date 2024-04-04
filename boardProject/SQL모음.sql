/* 계정 생성(관리자 계정으로 접속) */
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

CREATE USER SPRING_JTG IDENTIFIED BY SPRING1234;

GRANT CONNECT, RESOURCE TO SPRING_JTG;

ALTER USER SPRING_JTG
DEFAULT TABLESPACE USERS
QUOTA 20M ON USERS;

--> 계정 생성 후 접속 방법(새 데이터베이스) 추가

-----------------------------------------------------------------------

/* SPRING 계정 접속 */

-- "" : 내부에 작성된 글(모양) 그대로 인식 -> 대/소문자 구분
--> "" 작성 권장

-- CHAR(10)			: 고정 길이 문자열 10바이트 (최대 2000바이트)
-- VARCHAR2(10) : 가변 길이 문자열 10바이트 (최대 4000바이트)

-- NVARCHAR(10) : 가변 길이 문자열 10글자 (유니코드,최대 4000바이트)
-- CLOB : 가변 길이 문자열 (최대 4GB)

/* MEMBER 테이블 생성 */
CREATE TABLE "MEMBER"(
	"MEMBER_NO" NUMBER CONSTRAINT "MEMBER_PK" PRIMARY KEY,
	"MEMBER_EMAIL"    NVARCHAR2(50) NOT NULL,
	"MEMBER_PW"       NVARCHAR2(100) NOT NULL,
	"MEMBER_NICKNAME" NVARCHAR2(10) NOT NULL,
	"MEMBER_TEL"      CHAR(11) NOT NULL,
	"MEMBER_ADDRESS"  NVARCHAR2(150),
	"PROFILE_IMG"     VARCHAR2(300),
	"ENROLL_DATE"     DATE     DEFAULT SYSDATE NOT NULL,
	"MEMBER_DEL_FL"   CHAR(1) DEFAULT 'N'
										CHECK("MEMBER_DEL_FL" IN('Y','N')),
	"AUTHORITY"       NUMBER  DEFAULT 1
										CHECK("AUTHORITY" IN (1,2))
);


-- 회원 번호 시퀀스 만들기
CREATE SEQUENCE SEQ_MEMBER_NO NOCACHE;

-- 샘플 회원 데이터 삽입
INSERT INTO "MEMBER"
VALUES(SEQ_MEMBER_NO.NEXTVAL,
			 'member01@kh.or.kr',
			 '$2a$10$Xj0lgZWRiRrYSZ9eAKRkXOl6Q2S9RUeybf0GAdNRaFOBiygmc/A3S',
			 '샘플1',
			 '01012341234',
			 NULL,
			 NULL,
			 DEFAULT,
			 DEFAULT,
			 DEFAULT
);

COMMIT;

SELECT * FROM "MEMBER";


-- 로그인
-- -> BCrypt 암호화 사용 중
-- -> DB에서 비밀번호 비교 불가능!!!
-- -> 그래서 비밀번호(MEMBER_PW)를 조회\

-- --> 이메일이 일치하는 회원 + 탈퇴 안한 회원 조건만 추가

SELECT MEMBER_NO, MEMBER_EMAIL, MEMBER_NICKNAME, MEMBER_PW,
			 MEMBER_TEL,MEMBER_ADDRESS,PROFILE_IMG,AUTHORITY,
			 TO_CHAR(ENROLL_DATE,
			 				 'YYYY"년" MM"월" DD"일" HH24"시" MI"분" SS"초"')ENROLL_DATE
FROM "MEMBER"
WHERE MEMBER_EMAIL = ?
AND   MEMBER_DEL_FL = 'N';


-- 이메일 중복 검사(탈퇴 안한 회원중 같은 이메일이 있는지 조회)
SELECT COUNT(*) 
FROM "MEMBER"
WHERE MEMBER_DEL_FL = 'N'
AND MEMBER_EMAIL = 'member01@kh.or.kr'
;


DELETE FROM "MEMBER"
WHERE MEMBER_EMAIL = 'tgjeon1104@naver.com';
COMMIT;


/* 이메일, 인증키 저장 테이블 생성 */
CREATE TABLE "TB_AUTH_KEY"(
	"KEY_NO"    NUMBER PRIMARY KEY,
	"EMAIL"	    NVARCHAR2(50) NOT NULL,
	"AUTH_KEY"  CHAR(6)	NOT NULL,
	"CREATE_TIME" DATE DEFAULT SYSDATE NOT NULL
);

COMMENT ON COLUMN "TB_AUTH_KEY"."KEY_NO"  IS '인증키 구분 번호(시퀀스)';
COMMENT ON COLUMN "TB_AUTH_KEY"."EMAIL"  IS '인증 이메일';
COMMENT ON COLUMN "TB_AUTH_KEY"."AUTH_KEY"  IS '인증 번호';
COMMENT ON COLUMN "TB_AUTH_KEY"."CREATE_TIME"  IS '인증 번호 생성 시간';

CREATE SEQUENCE SEQ_KEY_NO NOCACHE; -- 인증키 구분 번호 시퀀스

SELECT * FROM "TB_AUTH_KEY";

SELECT * COUNT(*)
FROM "TB_AUTH_KEY"
WHERE EMAIL = #{가입하려는 이메일 입력값}
AND AUTH_KEY = #{위 이메일로 보낸 인증번호}

ROLLBACK;


UPDATE "MEMBER" 
SET  MEMBER_ADDRESS = 'A^^^B^^^C' 
WHERE MEMBER_NO = '10';

COMMIT;

SELECT *
FROM "MEMBER" m ;




























