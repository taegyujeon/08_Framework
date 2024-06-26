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



ROLLBACK;

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

---------------------------------------------------------------------------

-- 파일 업로드 테스트용 테이블
CREATE TABLE "UPLOAD_FILE"(
	FILE_NO NUMBER PRIMARY KEY,
	FILE_PATH VARCHAR2(500) NOT NULL,
	FILE_ORIGINAL_NAME VARCHAR2(300) NOT NULL,
	FILE_RENAME VARCHAR2(100) NOT NULL,
	FILE_UPLOAD_DATE DATE DEFAULT SYSDATE,
	MEMBER_NO NUMBER REFERENCES "MEMBER"

);

COMMENT ON COLUMN "UPLOAD_FILE".FILE_NO    IS  '파일 번호(PK)';

COMMENT ON COLUMN "UPLOAD_FILE".FILE_PATH  IS  '클라이언트 요청 경로';

COMMENT ON COLUMN "UPLOAD_FILE".FILE_ORIGINAL_NAME  
IS  '파일 원본명';

COMMENT ON COLUMN "UPLOAD_FILE".FILE_RENAME  
IS  '변경된 파일';

COMMENT ON COLUMN "UPLOAD_FILE".FILE_UPLOAD_DATE  
IS  '업로드 날짜';

COMMENT ON COLUMN "UPLOAD_FILE".MEMBER_NO  
IS  'MEMBER 테이블의 PK(MEMBER_NO) 참조';

CREATE SEQUENCE SEQ_FILE_NO NOCACHE;

SELECT * FROM "UPLOAD_FILE";


-- 파일 목록 조회
SELECT FILE_NO, FILE_PATH, FILE_ORIGINAL_NAME, FILE_RENAME,
	TO_CHAR(FILE_UPLOAD_DATE, 'YYYY-MM-DD') FILE_UPLOAD_DATE,
	MEMBER_NICKNAME
FROM "UPLOAD_FILE"
JOIN "MEMBER" USING(MEMBER_NO) 
ORDER BY FILE_NO DESC;

SELECT * FROM
"MEMBER" m ;


----------------------------------------------------------------------------------------------------------------------


CREATE TABLE "MEMBER" (
	"MEMBER_NO"	NUMBER		NOT NULL,
	"MEMBER_EMAIL"	NVARCHAR(50)		NOT NULL,
	"MEMBER_PW"	NVARCHAR(100)		NOT NULL,
	"MEMBER_NICKNAME"	NVARCHAR(10)		NOT NULL,
	"MEMBER_TEL"	CHAR(11)		NOT NULL,
	"MEMBER_ADDRESS"	NVARCHAR2(300)		NULL,
	"PROFILE_IMG"	VARCHAR2(300)		NULL,
	"ENROLL_DATE"	DATE	DEFAULT SYSDATE	NOT NULL,
	"MEMBER_DEL_FL"	CHAR(1)	DEFAULT 'N'	NOT NULL,
	"AUTHORITY"	NUMBER	DEFAULT 1	NOT NULL
);

COMMENT ON COLUMN "MEMBER"."MEMBER_NO" IS '회원 번호(PK)';

COMMENT ON COLUMN "MEMBER"."MEMBER_EMAIL" IS '회원 이메일(ID 역할)';

COMMENT ON COLUMN "MEMBER"."MEMBER_PW" IS '회원 비밀번호(암호화)';

COMMENT ON COLUMN "MEMBER"."MEMBER_NICKNAME" IS '회원 닉네임';

COMMENT ON COLUMN "MEMBER"."MEMBER_TEL" IS '회원 전화번호';

COMMENT ON COLUMN "MEMBER"."MEMBER_ADDRESS" IS '회원 주소';

COMMENT ON COLUMN "MEMBER"."PROFILE_IMG" IS '프로필 이미지';

COMMENT ON COLUMN "MEMBER"."ENROLL_DATE" IS '회원 가입일';

COMMENT ON COLUMN "MEMBER"."MEMBER_DEL_FL" IS '탈퇴 여부(Y,N)';

COMMENT ON COLUMN "MEMBER"."AUTHORITY" IS '권한(1:일반,2:관리자)';

CREATE TABLE "BOARD" (
	"BOARD_NO"	NUMBER		NOT NULL,
	"BOARD_TITLE"	NVARCHAR2(100)		NOT NULL,
	"BOARD_CONTENT"	VARCHAR2(4000)		NOT NULL,
	"BOARD_WRITE_DATE"	DATE	DEFAULT SYSDATE	NOT NULL,
	"BOARD_UPDATE_DATE"	DATE		NULL,
	"READ_COUNT"	NUMBER	DEFAULT 0	NOT NULL,
	"BOARD_DEL_FL"	CHAR(1)	DEFAULT 'N'	NOT NULL,
	"BOARD_CODE"	NUMBER		NOT NULL,
	"MEMBER_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "BOARD"."BOARD_NO" IS '게시글 번호(PK)';

COMMENT ON COLUMN "BOARD"."BOARD_TITLE" IS '게시글 제목';

COMMENT ON COLUMN "BOARD"."BOARD_CONTENT" IS '게시글 내용';

COMMENT ON COLUMN "BOARD"."BOARD_WRITE_DATE" IS '게시글 작성일';

COMMENT ON COLUMN "BOARD"."BOARD_UPDATE_DATE" IS '게시글 마지막 수정일';

COMMENT ON COLUMN "BOARD"."READ_COUNT" IS '조회수';

COMMENT ON COLUMN "BOARD"."BOARD_DEL_FL" IS '게시글 삭제 여부(Y/N)';

COMMENT ON COLUMN "BOARD"."BOARD_CODE" IS '게시판 종류 코드 번호';

COMMENT ON COLUMN "BOARD"."MEMBER_NO" IS '작성한 회원번호(FK)';

CREATE TABLE "BOARD_TYPE" (
	"BOARD_CODE"	NUMBER		NOT NULL,
	"BOARD_NAME"	NVARCHAR2(20)		NOT NULL
);

COMMENT ON COLUMN "BOARD_TYPE"."BOARD_CODE" IS '게시판 종류 코드 번호';

COMMENT ON COLUMN "BOARD_TYPE"."BOARD_NAME" IS '게시판명';

CREATE TABLE "BOARD_LIKE" (
	"MEMBER_NO"	NUMBER		NOT NULL,
	"BOARD_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "BOARD_LIKE"."MEMBER_NO" IS '회원 번호(PK)';

COMMENT ON COLUMN "BOARD_LIKE"."BOARD_NO" IS '게시글 번호(PK)';

CREATE TABLE "UPLOAD_FILE" (
	"FILE_NO"	NUMBER		NOT NULL,
	"FILE_PATH"	VARCHAR2(500)		NOT NULL,
	"FILE_ORIGINAL_NAME"	VARCHAR2(300)		NOT NULL,
	"FILE_RENAME"	VARCHAR2(100)		NOT NULL,
	"FILE_UPLOAD_DATE"	DATE	DEFAULT SYSDATE	NOT NULL,
	"MEMBER_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "UPLOAD_FILE"."FILE_NO" IS '파일 번호(PK)';

COMMENT ON COLUMN "UPLOAD_FILE"."FILE_PATH" IS '파일 요청 경로';

COMMENT ON COLUMN "UPLOAD_FILE"."FILE_ORIGINAL_NAME" IS '파일 원본명';

COMMENT ON COLUMN "UPLOAD_FILE"."FILE_RENAME" IS '파일 변경명';

COMMENT ON COLUMN "UPLOAD_FILE"."FILE_UPLOAD_DATE" IS '업로드 날짜';

COMMENT ON COLUMN "UPLOAD_FILE"."MEMBER_NO" IS '업로드한 회원 번호';

CREATE TABLE "BOARD_IMG" (
	"IMG_NO"	NUMBER		NOT NULL,
	"IMG_PATH"	VARCHAR2(200)		NOT NULL,
	"IMG_ORIGINAL_NAME"	NVARCHAR2(50)		NOT NULL,
	"IMG_RENAME"	NVARCHAR2(50)		NOT NULL,
	"IMG_ORDER"	NUMBER		NULL,
	"BOARD_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "BOARD_IMG"."IMG_NO" IS '이미지 번호(PK)';

COMMENT ON COLUMN "BOARD_IMG"."IMG_PATH" IS '이미지 요청 경로';

COMMENT ON COLUMN "BOARD_IMG"."IMG_ORIGINAL_NAME" IS '이미지 원본명';

COMMENT ON COLUMN "BOARD_IMG"."IMG_RENAME" IS '이미지 변경명';

COMMENT ON COLUMN "BOARD_IMG"."IMG_ORDER" IS '이미지 순서';

COMMENT ON COLUMN "BOARD_IMG"."BOARD_NO" IS '게시글 번호(PK)';

CREATE TABLE "COMMENT" (
	"COMMENT_NO"	NUMBER		NOT NULL,
	"COMMENT_CONTENT"	VARCHAR2(4000)		NOT NULL,
	"COMMENT_WRITE_DATE"	DATE	DEFAULT SYSDATE	NOT NULL,
	"COMMENT_DEL_FL"	CHAR(1)	DEFAULT 'N'	NOT NULL,
	"BOARD_NO"	NUMBER		NOT NULL,
	"PARENT_COMMENT_NO"	NUMBER		NOT NULL,
	"MEMBER_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "COMMENT"."COMMENT_NO" IS '댓글 번호(PK)';

COMMENT ON COLUMN "COMMENT"."COMMENT_CONTENT" IS '댓글 내용';

COMMENT ON COLUMN "COMMENT"."COMMENT_WRITE_DATE" IS '댓글 작성일';

COMMENT ON COLUMN "COMMENT"."COMMENT_DEL_FL" IS '댓글 삭제 여부(Y/N)';

COMMENT ON COLUMN "COMMENT"."BOARD_NO" IS '게시글 번호(PK)';

COMMENT ON COLUMN "COMMENT"."PARENT_COMMENT_NO" IS '부모 댓글 번호';

COMMENT ON COLUMN "COMMENT"."MEMBER_NO" IS '회원 번호(PK)';


ALTER TABLE "MEMBER" ADD CONSTRAINT "PK_MEMBER" PRIMARY KEY (
	"MEMBER_NO"
);

ALTER TABLE "BOARD" ADD CONSTRAINT "PK_BOARD" PRIMARY KEY (
	"BOARD_NO"
);

ALTER TABLE "BOARD_TYPE" ADD CONSTRAINT "PK_BOARD_TYPE" PRIMARY KEY (
	"BOARD_CODE"
);

ALTER TABLE "BOARD_LIKE" ADD CONSTRAINT "PK_BOARD_LIKE" PRIMARY KEY (
	"MEMBER_NO",
	"BOARD_NO"
);

ALTER TABLE "UPLOAD_FILE" ADD CONSTRAINT "PK_UPLOAD_FILE" PRIMARY KEY (
	"FILE_NO"
);

ALTER TABLE "BOARD_IMG" ADD CONSTRAINT "PK_BOARD_IMG" PRIMARY KEY (
	"IMG_NO"
);

ALTER TABLE "COMMENT" ADD CONSTRAINT "PK_COMMENT" PRIMARY KEY (
	"COMMENT_NO"
);



ALTER TABLE "BOARD" ADD CONSTRAINT "FK_BOARD_TYPE_TO_BOARD_1" FOREIGN KEY (
	"BOARD_CODE"
)
REFERENCES "BOARD_TYPE" (
	"BOARD_CODE"
);


ALTER TABLE "BOARD" ADD CONSTRAINT "FK_MEMBER_TO_BOARD_1" FOREIGN KEY (
	"MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);

ALTER TABLE "BOARD_LIKE" ADD CONSTRAINT "FK_MEMBER_TO_BOARD_LIKE_1" FOREIGN KEY (
	"MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);

ALTER TABLE "BOARD_LIKE" ADD CONSTRAINT "FK_BOARD_TO_BOARD_LIKE_1" FOREIGN KEY (
	"BOARD_NO"
)
REFERENCES "BOARD" (
	"BOARD_NO"
);

ALTER TABLE "UPLOAD_FILE" ADD CONSTRAINT "FK_MEMBER_TO_UPLOAD_FILE_1" FOREIGN KEY (
	"MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);

ALTER TABLE "BOARD_IMG" ADD CONSTRAINT "FK_BOARD_TO_BOARD_IMG_1" FOREIGN KEY (
	"BOARD_NO"
)
REFERENCES "BOARD" (
	"BOARD_NO"
);

ALTER TABLE "COMMENT" ADD CONSTRAINT "FK_BOARD_TO_COMMENT_1" FOREIGN KEY (
	"BOARD_NO"
)
REFERENCES "BOARD" (
	"BOARD_NO"
);

ALTER TABLE "COMMENT" ADD CONSTRAINT "FK_COMMENT_TO_COMMENT_1" FOREIGN KEY (
	"PARENT_COMMENT_NO"
)
REFERENCES "COMMENT" (
	"COMMENT_NO"
);

ALTER TABLE "COMMENT" ADD CONSTRAINT "FK_MEMBER_TO_COMMENT_1" FOREIGN KEY (
	"MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);


------------------- CHECK ------------------------

-- 게시글 삭제 여부
ALTER TABLE "BOARD" ADD
CONSTRAINT "BOARD_DEL_CHECK"
CHECK("BOARD_DEL_FL" IN ('Y','N'));

-- 댓글 삭제 여부
ALTER TABLE "COMMENT" ADD
CONSTRAINT "COMMENT_DEL_CHECK"
CHECK("COMMENT_DEL_FL" IN ('Y','N'));




/* 게시판 종류(BOARD_TYPE) 추가 */
CREATE SEQUENCE SEQ_BOARD_CODE NOCACHE;

INSERT INTO "BOARD_TYPE" VALUES(SEQ_BOARD_CODE.NEXTVAL,'공지 게시판');
INSERT INTO "BOARD_TYPE" VALUES(SEQ_BOARD_CODE.NEXTVAL,'정보 게시판');
INSERT INTO "BOARD_TYPE" VALUES(SEQ_BOARD_CODE.NEXTVAL,'자유 게시판');

COMMIT;

-- 게시판 종류 조회 (표기법 변경)
SELECT BOARD_CODE "boardCode", BOARD_NAME "boardName"
FROM BOARD_TYPE 
ORDER BY BOARD_CODE;

--------------------------------------------------------------------------------
/* 게시글 번호 시퀀스 생성 */
CREATE SEQUENCE SEQ_BOARD_NO NOCACHE;


/* 게시판(BOARD) 테이블 샘플 데이터 삽입(PL/SQL) */
SELECT * FROM "MEMBER";

-- DBMS_RANDOM.VALUE(0,3) : 0.0 이상, 3.0 미만의 난수
-- CEIL( DBMS_RANDOM.VALUE(0,3) ) : 1,2,3 중 하나


-- ALT + X 로 실행
BEGIN
	FOR I IN 1..2000 LOOP
		
		INSERT INTO "BOARD"
		VALUES(SEQ_BOARD_NO.NEXTVAL,
					 SEQ_BOARD_NO.CURRVAL || '번째 게시글',
					 SEQ_BOARD_NO.CURRVAL || '번째 게시글 내용 입니다',
					 DEFAULT,DEFAULT,DEFAULT,DEFAULT,
					 CEIL(DBMS_RANDOM.VALUE(0,3)),
					 1
					 );
		
	END LOOP;
	
END;

-- 샘플 데이터 삽입 확인
SELECT COUNT(*) FROM "BOARD";

SELECT BOARD_CODE, COUNT(*)
FROM "BOARD"
GROUP BY BOARD_CODE
ORDER BY BOARD_CODE;

----------------------------------------------------------------------------------------
-- 부모 댓글 번호 NULL 허용
ALTER TABLE "COMMENT" 
MODIFY PARENT_COMMENT_NO NUMBER NULL;


/* 댓글 번호 시퀀스 생성 */
CREATE SEQUENCE SEQ_COMMENT_NO NOCACHE;

/* 댓글 ("COMMNET") 테이블에 샘플 데이터 추가*/

BEGIN
	FOR I IN 1..2000 LOOP
	
		INSERT INTO "COMMENT"	
		VALUES(
			SEQ_COMMENT_NO.NEXTVAL,
			SEQ_COMMENT_NO.CURRVAL || '번째 댓글 입니다',
			DEFAULT, DEFAULT,
			CEIL( DBMS_RANDOM.VALUE(0, 2000)),
			NULL, 
			1
		);
		
	END LOOP;
END;
;

-- 게시글 번호 최소값, 최대값
SELECT MIN(BOARD_NO), MAX(BOARD_NO) FROM "BOARD";

-- 댓글 삽입 확인
SELECT BOARD_NO, COUNT(*)
FROM "COMMENT"
GROUP BY BOARD_NO 
ORDER BY BOARD_NO; 

COMMIT;


------------------------------------------------------------------------------------
/* 특정 게시판(BOARD_CODE)에 
 * 삭제 되지 않은 게시글 목록 조회
 * 단, 최신글이 제일 위에 존재
 * 몇 초/분/시간 전 또는 YYYY-MM-DD 형식으로 작성일 조회
 * 
 * + 댓글 개수
 * + 좋아요 개수
 */

-- 번호 / 제목[댓글 개수 ] / 작성자 닉네임 / 조회수 / 좋아요 개수 / 작성일


-- 상관 서브 쿼리
-- 1) 메인 쿼리 1행 조회
-- 2) 1행 조회 결과를 이용해서 서브 쿼리 수행
--    (메인 쿼리 모두 조회할 때 까지 반복)
SELECT BOARD_NO , BOARD_TITLE , MEMBER_NICKNAME , READ_COUNT, 
	(SELECT COUNT(*) FROM "COMMENT" C
	WHERE C.BOARD_NO = B.BOARD_NO) COMMENT_COUNT,
	
	(SELECT COUNT(*) 
	FROM "BOARD_LIKE" L
	WHERE L.BOARD_NO = B.BOARD_NO) LIKE_COUNT,
	
	CASE 
		WHEN SYSDATE - BOARD_WRITE_DATE < 1 / 24 / 60
		THEN FLOOR((SYSDATE - BOARD_WRITE_DATE) * 24 * 60 * 60) || '초 전'

		WHEN SYSDATE - BOARD_WRITE_DATE < 1 / 24 
		THEN FLOOR((SYSDATE - BOARD_WRITE_DATE) * 24 * 60) || '분 전'
		
		WHEN SYSDATE - BOARD_WRITE_DATE < 1
		THEN FLOOR((SYSDATE - BOARD_WRITE_DATE) * 24) || '시간 전'
		
		ELSE TO_CHAR(BOARD_WRITE_DATE,'YYYY-MM-DD')
		
	END BOARD_WRITE_DATE 
	

FROM "BOARD" B
JOIN "MEMBER" USING(MEMBER_NO)
WHERE BOARD_DEL_FL = 'N'
AND BOARD_CODE = #{boardCode}
ORDER BY BOARD_NO DESC
;

-- 특정 게시글의 댓글 개수 조회
SELECT COUNT(*) FROM "COMMENT"
WHERE BOARD_NO = 2000
;

-- 현재 시간 - 하루 전 --> 정수 부분 == 일 단위
SELECT ( SYSDATE 
	- TO_DATE('2024-04-10 12:14:30', 'YYYY-MM-DD HH24:MI:SS') )
	* 60 * 60 * 24
FROM DUAL;





-----------------------------------------------------------------------------------------------------------------------
/* 책 관리 프로젝트 (연습용) */

CREATE TABLE "BOOK" (
	"BOOK_NO"	NUMBER		NOT NULL,
	"BOOK_TITLE"	NVARCHAR2(50)		NOT NULL,
	"BOOK_WRITER"	NVARCHAR2(20)		NOT NULL,
	"BOOK_PRICE"	NUMBER		NOT NULL,
	"REG_DATE"	DATE	DEFAULT SYSDATE	NOT NULL
);

COMMENT ON COLUMN "BOOK"."BOOK_NO" IS '책 번호';

COMMENT ON COLUMN "BOOK"."BOOK_TITLE" IS '책 제목';

COMMENT ON COLUMN "BOOK"."BOOK_WRITER" IS '글쓴이';

COMMENT ON COLUMN "BOOK"."BOOK_PRICE" IS '가격';

COMMENT ON COLUMN "BOOK"."REG_DATE" IS '등록일';

ALTER TABLE "BOOK" ADD CONSTRAINT "PK_BOOK" PRIMARY KEY (
	"BOOK_NO"
);

SELECT * FROM BOOK b ;

INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (1, '어린 왕자', '생텍쥐페리', 12000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (2, '데미안', '헤르만 헤세', 15000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (3, '백설 공주', '그림협회', 18000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (4, '흰', '한강', 13000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (5, '꽃을 보듯 너를 본다', '나태주', 13500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (6, '부활', '레프 톨스토이', 17000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (7, '그리스 로마 신화', '로버트 그레이브스', 22000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (8, '사람은 무엇으로 사는가', '톨스토이', 14500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (9, '어른을 위한 세계사', '신현준', 25000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (10, '나미야 잡화점의 기적', '히가시노 게이고', 16000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (11, '아몬드', '손원평', 14000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (12, '미움받을 용기', '기시미 이치로', 15500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (13, '해리 포터와 마법사의 돌', 'J.K. 롤링', 18000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (14, '노인과 바다', '어니스트 헤밍웨이', 12500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (15, '어제 일은 모두 괜찮습니다', '아베 코우키', 20000);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (16, '파리의 아파트', '기욤 뮈소', 16500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (17, '지적 대화를 위한 넓고 얕은 지식', '채사장', 13500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (18, '죽음이 두려워서는 안 된다', '곽재구', 14500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (19, '골든스프링', '최인호', 15500);
INSERT INTO "BOOK" ("BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE") VALUES (20, '포테이토 팜', '김영하', 13000);

SELECT "BOOK_NO", "BOOK_TITLE", "BOOK_WRITER", "BOOK_PRICE", "REG_DATE"
FROM BOOK 
ORDER BY BOOK_NO;



-----------------------------------------------------------------------------------------------------------------------------------------

/* 시험 */

-- TB_USER 테이블 생성 및 SEQ_UNO 시퀀스 생성

CREATE TABLE TB_USER(

USER_NO NUMBER PRIMARY KEY,

USER_ID VARCHAR2(50) UNIQUE NOT NULL,

USER_NAME VARCHAR2(50) NOT NULL,

USER_AGE NUMBER NOT NULL

);

CREATE SEQUENCE SEQ_UNO;

-- 샘플 데이터 삽입

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'gd_hong', '홍길동', 20);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'sh_han', '한소희', 28);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'jm_park', '지민', 27);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'jm123', '지민', 25);

COMMIT;

SELECT USER_NO,USER_ID,USER_NAME,USER_AGE 
FROM TB_USER ;


---------------------------------------------------------------------------------------------------

/* 시험2 */

CREATE TABLE CUSTOMER(

CUSTOMER_NO NUMBER PRIMARY KEY,

CUSTOMER_NAME VARCHAR2(60) NOT NULL,

CUSTOMER_TEL VARCHAR2(30) NOT NULL,

CUSTOMER_ADDRESS VARCHAR2(200) NOT NULL

);

CREATE SEQUENCE SEQ_CUSTOMER_NO NOCACHE;

COMMIT;

SELECT * FROM CUSTOMER c ;




-------------------------------------------------------------------------------------------------------

/* BOARD_IMG 테이블용 시퀀스 생성 */
CREATE SEQUENCE SEQ_IMG_NO NOCACHE;

/* BOARD_IMG 테이블에 샘플 데이터 삽입 */
INSERT INTO "BOARD_IMG" VALUES(
	SEQ_IMG_NO.NEXTVAL , '/images/board','원본1.jpg','test1.jpg',0,1997
);

INSERT INTO "BOARD_IMG" VALUES(
	SEQ_IMG_NO.NEXTVAL , '/images/board','원본2.jpg','test2.jpg',1,1997
);

INSERT INTO "BOARD_IMG" VALUES(
	SEQ_IMG_NO.NEXTVAL , '/images/board','원본3.jpg','test3.jpg',2,1997
);

INSERT INTO "BOARD_IMG" VALUES(
	SEQ_IMG_NO.NEXTVAL , '/images/board','원본4.jpg','test4.jpg',3,1997
);

INSERT INTO "BOARD_IMG" VALUES(
	SEQ_IMG_NO.NEXTVAL , '/images/board','원본5.jpg','test5.jpg',4,1997
);


COMMIT;


-----------------------------------------------------------------------------------------------
/* 게시글 상세 조회 */
SELECT BOARD_NO , BOARD_TITLE , BOARD_CONTENT , BOARD_CODE ,
			 BOARD_COUNT , MEMBER_NICKNAME ,PROFILE_IMG , 
			 TO_CHAR(BOARD_WRITE_DATE , 'YYYY"년" MM"월" DD"일" HH24:MI:SS') BOARD_WRITE_DATE 
			 TO_CHAR(BOARD_UPDATE_DATE , 'YYYY"년" MM"월" DD"일" HH24:MI:SS') BOARD_UPDATE_DATE
			 
			 (SELECT COUNT(*) FROM BOARD_LIKE
			 WHERE BOARD_NO = 1997) LIKE COUNT,
			 
			(SELECT IMG_PATH || IMG_RENAME 
			 FROM "BOARD_IMG"
			 WHERE BOARD_NO = 1997
			 AND   IMG_ORDER = 0) THUMBNAIL,
			 
			 (SELECT COUNT(*) FROM "BOARD_LIKE"
			  WHERE MEMBER_NO = NULL 
			  AND BOARD_NO = 1) LIKE_CHECK
			 
FROM "BOARD"
JOIN "MEMEBER" USING(MEMBER_NO)
WHERE BOARD_DEL_FL = 'N'
AND BOARD_CODE = 1
AND BOARD_NO = 1997
;



-------------------------------------------------------
/* 상세조회 되는 게시글의 모든 이미지 조회 */
SELECT *
FROM "BOARD_IMG"
WHERE BOARD_NO = 1997
ORDER BY IMG_ORDER;

/* 상세조회 되는 게시글의 모든 댓글 조회 */

/* 계층형 쿼리 */

SELECT LEVEL, C.* FROM
      (SELECT COMMENT_NO, COMMENT_CONTENT,
          TO_CHAR(COMMENT_WRITE_DATE, 'YYYY"년" MM"월" DD"일" HH24"시" MI"분" SS"초"') COMMENT_WRITE_DATE,
          BOARD_NO, MEMBER_NO, MEMBER_NICKNAME, PROFILE_IMG, PARENT_COMMENT_NO, COMMENT_DEL_FL
      FROM "COMMENT"
      JOIN MEMBER USING(MEMBER_NO)
      WHERE BOARD_NO = 1997) C
   WHERE COMMENT_DEL_FL = 'N'
   OR 0 != (SELECT COUNT(*) FROM "COMMENT" SUB
               WHERE SUB.PARENT_COMMENT_NO = C.COMMENT_NO
               AND COMMENT_DEL_FL = 'N')
   START WITH PARENT_COMMENT_NO IS NULL
   CONNECT BY PRIOR COMMENT_NO = PARENT_COMMENT_NO
   ORDER SIBLINGS BY COMMENT_NO;

  
-----------------------------------------------------------------------------------------

/* 좋아요 테이블(BOARD_LIKE) 샘플 데이터 추가 */
INSERT INTO "BOARD_LIKE"
VALUES(1,1997); -- 1번 회원이 1997번 글에 좋아요를 클릭함

COMMIT;

-- 좋아요 여부 확인 (  1:O  /  2:X  )
SELECT COUNT(*) FROM "BOARD_LIKE"
WHERE MEMBER_NO = 22
AND BOARD_NO = 1997;

SELECT * FROM "BOARD_LIKE";


/* 여러 행을 한번에 삽입하는 방법! -> INSERT + SUBQUERY */

-- ORA-02287: 시퀀스 번호는 이 위치에 사용할 수 없습니다
--> 시퀀스로 번호 생성하는 부분을 별도 함수로 분리 후 호출하면 문제 없음

INSERT INTO "BOARD_IMG"
(
SELECT NEXT_IMG_NO(),'경로1','원본1','변경1',1,1999 FROM DUAL
UNION
SELECT NEXT_IMG_NO(),'경로2','원본2','변경2',2,1999 FROM DUAL
UNION
SELECT NEXT_IMG_NO(),'경로3','원본3','변경3',3,1999 FROM DUAL
);

ROLLBACK;

-- SEQ_IMG_NO 시퀀스의 다음 값을 반환 하는 함수 생성
CREATE OR REPLACE FUNCTION NEXT_IMG_NO

-- 반환형
RETURN NUMBER 

-- 사용할 변수
IS IMG_NO NUMBER;

BEGIN 
	SELECT SEQ_IMG_NO.NEXTVAL
	INTO IMG_NO
	FROM DUAL;

	RETURN IMG_NO;
END;
;


SELECT NEXT_IMG_NO() FROM DUAL;


SELECT SEQ_BOARD_NO.NEXTVAL FROM DUAL;

SELECT MAX(BOARD_NO) FROM BOARD;



UPDATE BOARD SET BOARD_DEL_FL = 'Y' WHERE BOARD_NO = 1;



INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 댓글 1',
			  DEFAULT, DEFAULT, 1990, NULL, 2);
			 
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 댓글 2',
			  DEFAULT, DEFAULT, 1990, NULL, 2);
			 
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 댓글 3',
			  DEFAULT, DEFAULT, 1990, NULL, 2);
			 
-- 부모 댓글 1의 자식 댓글
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 1의 자식 1',
			  DEFAULT, DEFAULT,	1990, 2010 , 2);
			 
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 1의 자식 2',
			  DEFAULT, DEFAULT,	1990, 2010 , 2);
			 
			 
-- 부모 댓글 2의 자식 댓글			 
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 2의 자식 1',
			  DEFAULT, DEFAULT,	1990, 2011 , 2);
			 
-- 부모 댓글 2의 자식 1의 자식 댓글			 
INSERT INTO "COMMENT"	
VALUES( SEQ_COMMENT_NO.NEXTVAL, '부모 2의 자식 1의 자식!!!',
			  DEFAULT, DEFAULT,	1990, 2011 , 2);
			 
COMMIT;

SELECT LEVEL, COMMENT_NO, PARENT_COMMENT_NO, COMMENT_CONTENT 
FROM "COMMENT"
WHERE BOARD_NO = 1990

/*계층형 쿼리*/

-- PARENT_COMMENT_NO 값이 NULL인 행이 부모(LV.1)
START WITH PARENT_COMMENT_NO IS NULL 

-- 부모의 COMMENT_NO와 같은 PARENT_COMMENT_NO 가진 행을 자식으로 지정
CONNECT BY PRIOR COMMENT_NO = PARENT_COMMENT_NO

-- 형제(같은 레벨 부모, 자식)들 간의 정렬 순서를 COMMENT_NO 오름 차순
ORDER SIBLINGS BY COMMENT_NO;

ROLLBACK;



DROP TABLE TB_USER;
DROP SEQUENCE SEQ_UNO;

-- 사용자 테이블
CREATE TABLE TB_USER(

USER_NO NUMBER PRIMARY KEY,

USER_ID VARCHAR2(50) UNIQUE NOT NULL,

USER_NAME VARCHAR2(50) NOT NULL,

USER_AGE NUMBER NOT NULL

);

-- 사용자 시퀀스
CREATE SEQUENCE SEQ_UNO;


-- 샘플 데이터
INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'gd_hong', '홍길동', 20);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'sh_han', '한소희', 28);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'jm_park', '지민', 27);

INSERT INTO TB_USER VALUES(SEQ_UNO.NEXTVAL, 'jm123', '지민', 25);

SELECT * FROM TB_USER;




-- 게시판 테이블

CREATE TABLE TB_BOARD(

BOARD_NO NUMBER PRIMARY KEY,

BOARD_TITLE VARCHAR2(50) NOT NULL,

BOARD_CONTENT VARCHAR2(2000) NOT NULL,

BOARD_DATE DATE DEFAULT SYSDATE,

BOARD_READCOUNT NUMBER DEFAULT 0,

USER_NO NUMBER REFERENCES TB_USER

);


-- 게시판 시퀀스

CREATE SEQUENCE SEQ_BNO;


-- 샘플 데이터

INSERT INTO TB_BOARD VALUES(SEQ_BNO.NEXTVAL, '처음입니다', '만나서 반가워요', SYSDATE, DEFAULT, 1);

INSERT INTO TB_BOARD VALUES(SEQ_BNO.NEXTVAL, '신입입니다', '잘 부탁드립니다!', SYSDATE, DEFAULT, 2);

INSERT INTO TB_BOARD VALUES(SEQ_BNO.NEXTVAL, '날씨가 좋네요', '즐거운 한 주 보내세요', SYSDATE, DEFAULT, 3);

INSERT INTO TB_BOARD VALUES(SEQ_BNO.NEXTVAL, '저도 처음이에요', '좋은 추억 쌓아요', SYSDATE, DEFAULT, 4);

INSERT INTO TB_BOARD VALUES(SEQ_BNO.NEXTVAL, '오늘 처음인 분이 많네요', '다들 환영합니다', SYSDATE, DEFAULT, 3);

COMMIT;

SELECT BOARD_NO,BOARD_TITLE,USER_ID,BOARD_CONTENT,BOARD_READCOUNT,BOARD_DATE  
FROM TB_BOARD
JOIN "TB_USER" USING(USER_NO)
WHERE BOARD_TITLE LIKE '%처음%';



-- 게시글 검색
SELECT BOARD_NO, BOARD_TITLE, MEMBER_NICKNAME, READ_COUNT,
	(SELECT
	COUNT(*)
	FROM "COMMENT" C
	WHERE C.BOARD_NO = B.BOARD_NO  
	AND COMMENT_DEL_FL = 'N') COMMENT_COUNT,

	(SELECT COUNT(*)
	FROM "BOARD_LIKE" L
	WHERE L.BOARD_NO = B.BOARD_NO) LIKE_COUNT,
	 
	 CASE
		 WHEN SYSDATE - BOARD_WRITE_DATE < 1 / 24 / 60 
		 THEN FLOOR((SYSDATE - BOARD_WRITE_DATE) * 24 * 60 * 60)  || '초 전'
		 
		 WHEN SYSDATE - BOARD_WRITE_DATE < 1 / 24 
		 THEN FLOOR((SYSDATE - BOARD_WRITE_DATE)* 24 * 60) || '분 전'
		 
		 WHEN SYSDATE - BOARD_WRITE_DATE < 1
		 THEN FLOOR((SYSDATE - BOARD_WRITE_DATE) * 24) || '시간 전'
		 
		 ELSE TO_CHAR(BOARD_WRITE_DATE, 'YYYY-MM-DD')
	 	
	 END BOARD_WRITE_DATE

FROM "BOARD" B
JOIN "MEMBER" USING(MEMBER_NO)
WHERE BOARD_DEL_FL = 'N'
AND BOARD_CODE = 1

-- 제목에 '10' 이 포함된 게시글 조회
-- AND BOARD_TITLE LIKE '%10%'

-- 내용에 '10' 이 포함된 게시글 조회
-- AND BOARD_CONTENT LIKE '%10%'

-- 제목 또는 내용에 '10' 이 포함된 게시글 조회
--AND (BOARD_TITLE LIKE '%10%' 
--   OR  BOARD_CONTENT LIKE '%10%')

-- 작성자 닉네임에 '샘플'이 포함된 게시글 조회
AND MEMBER_NICKNAME

ORDER BY BOARD_NO DESC;


-- 학생 테이블 생성

CREATE TABLE STUDENT(

STUDENT_NO NUMBER PRIMARY KEY,

STUDENT_NAME NVARCHAR2(10) NOT NULL,

STUDENT_MAJOR NVARCHAR2(20) NOT NULL,

STUDENT_GENDER CHAR(1) CHECK(STUDENT_GENDER IN ('M', 'F')) NOT NULL

);

-- 학번 시퀀스 생성

CREATE SEQUENCE SEQ_STUDENT_NO

START WITH 2024001 NOCACHE;

-- 학생 데이터 추가

INSERT INTO STUDENT VALUES(SEQ_STUDENT_NO.NEXTVAL, '홍길동', '컴퓨터공학과', 'M');

INSERT INTO STUDENT VALUES(SEQ_STUDENT_NO.NEXTVAL, '김영희', '국어국문학과', 'F');

INSERT INTO STUDENT VALUES(SEQ_STUDENT_NO.NEXTVAL, '이정학', '정치외교학과', 'M');

INSERT INTO STUDENT VALUES(SEQ_STUDENT_NO.NEXTVAL, '박변호', '법학과', 'F');

COMMIT;

SELECT STUDENT_NO , STUDENT_NAME , STUDENT_MAJOR , STUDENT_GENDER  
FROM STUDENT;


-- 프로필 이미지, 게시글 이미지 목록 모두 조회
SELECT SUBSTR(PROFILE_IMG, INSTR(PROFILE_IMG, '/', -1) + 1) "FILE_NAME"
FROM "MEMBER" 
WHERE PROFILE_IMG IS NOT NULL
UNION
SELECT IMG_RENAME "FILE_NAME"
FROM "BOARD_IMG";


-------------------------------------------------------------------------------
/* 알림 관련 SQL */

DROP TABLE "NOTIFICATION";

CREATE TABLE "NOTIFICATION" (
	"NOTIFICATION_NO"	NUMBER		NOT NULL,
	"NOTIFICATION_CONTENT"	NVARCHAR2(500)		NOT NULL,
	"NOTIFICATION_CHECK"	CHAR	DEFAULT 'N'	NOT NULL,
	"NOTIFICATION_DATE"	DATE	DEFAULT CURRENT_DATE	NOT NULL,
	"NOTIFICATION_URL"	NVARCHAR2(500)		NOT NULL,
	"SEND_MEMBER_PROFILE_IMG"	VARCHAR2(300)		NULL,
	"SEND_MEMBER_NO"	NUMBER		NOT NULL,
	"RECEIVE_MEMBER_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "NOTIFICATION"."NOTIFICATION_NO" IS '알림 구분 번호';

COMMENT ON COLUMN "NOTIFICATION"."NOTIFICATION_CONTENT" IS '알림 내용';

COMMENT ON COLUMN "NOTIFICATION"."NOTIFICATION_CHECK" IS '알림 읽음 여부(N/Y)';

COMMENT ON COLUMN "NOTIFICATION"."NOTIFICATION_DATE" IS '알림 생성 시간';

COMMENT ON COLUMN "NOTIFICATION"."NOTIFICATION_URL" IS '알림 클릭 시 연결할 페이지 주소';

COMMENT ON COLUMN "NOTIFICATION"."SEND_MEMBER_NO" IS '알림 보낸 회원 번호';

COMMENT ON COLUMN "NOTIFICATION"."RECEIVE_MEMBER_NO" IS '알림 받는 회원 번호';

ALTER TABLE "NOTIFICATION" ADD CONSTRAINT "PK_NOTIFICATION" PRIMARY KEY (
	"NOTIFICATION_NO"
);

ALTER TABLE "NOTIFICATION" ADD CONSTRAINT "FK_MEMBER_TO_NOTIFICATION_1" FOREIGN KEY (
	"SEND_MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);

ALTER TABLE "NOTIFICATION" ADD CONSTRAINT "FK_MEMBER_TO_NOTIFICATION_2" FOREIGN KEY (
	"RECEIVE_MEMBER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
);

-- 알림용 시퀀스 생성
CREATE SEQUENCE SEQ_NOTI_NO NOCACHE;


------------------------------------------------------------------------------------


/* ******** 채팅 관련 테이블 ********* */

CREATE TABLE "CHATTING_ROOM" (
	"CHATTING_NO"	NUMBER		NOT NULL,
	"CREATE_DATE"	DATE	DEFAULT SYSDATE	NOT NULL,
	"OPEN_MEMBER"	NUMBER		NOT NULL,
	"PARTICIPANT"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "CHATTING_ROOM"."CHATTING_NO" IS '채팅방 번호';

COMMENT ON COLUMN "CHATTING_ROOM"."CREATE_DATE" IS '채팅방 생성일';

COMMENT ON COLUMN "CHATTING_ROOM"."OPEN_MEMBER" IS '개설자 회원 번호';

COMMENT ON COLUMN "CHATTING_ROOM"."PARTICIPANT" IS '참여자 회원 번호';

CREATE TABLE "MESSAGE" (
	"MESSAGE_NO"	NUMBER		NOT NULL,
	"MESSAGE_CONTENT"	VARCHAR2(4000)		NOT NULL,
	"READ_FL"	CHAR	DEFAULT 'N'	NOT NULL,
	"SEND_TIME"	DATE	DEFAULT SYSDATE	NOT NULL,
	"SENDER_NO"	NUMBER		NOT NULL,
	"CHATTING_NO"	NUMBER		NOT NULL
);

COMMENT ON COLUMN "MESSAGE"."MESSAGE_NO" IS '메세지 번호';

COMMENT ON COLUMN "MESSAGE"."MESSAGE_CONTENT" IS '메세지 내용';

COMMENT ON COLUMN "MESSAGE"."READ_FL" IS '읽음 여부';

COMMENT ON COLUMN "MESSAGE"."SEND_TIME" IS '메세지 보낸 시간';

COMMENT ON COLUMN "MESSAGE"."SENDER_NO" IS '보낸 회원의 번호';

COMMENT ON COLUMN "MESSAGE"."CHATTING_NO" IS '채팅방 번호';



CREATE SEQUENCE SEQ_ROOM_NO NOCACHE;
CREATE SEQUENCE SEQ_MESSAGE_NO NOCACHE;


ALTER TABLE "CHATTING_ROOM" ADD CONSTRAINT "PK_CHATTING_ROOM" PRIMARY KEY (
	"CHATTING_NO"
);

ALTER TABLE "MESSAGE" ADD CONSTRAINT "PK_MESSAGE" PRIMARY KEY (
	"MESSAGE_NO"
);

ALTER TABLE "CHATTING_ROOM" ADD CONSTRAINT "FK_MEMBER_TO_CHATTING_ROOM_1" FOREIGN KEY (
	"OPEN_MEMBER"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
) ON DELETE CASCADE;

ALTER TABLE "CHATTING_ROOM" ADD CONSTRAINT "FK_MEMBER_TO_CHATTING_ROOM_2" FOREIGN KEY (
	"PARTICIPANT"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
) ON DELETE CASCADE;

ALTER TABLE "MESSAGE" ADD CONSTRAINT "FK_MEMBER_TO_MESSAGE_1" FOREIGN KEY (
	"SENDER_NO"
)
REFERENCES "MEMBER" (
	"MEMBER_NO"
) ON DELETE CASCADE;

ALTER TABLE "MESSAGE" ADD CONSTRAINT "FK_CHATTING_ROOM_TO_MESSAGE_1" FOREIGN KEY (
	"CHATTING_NO"
)
REFERENCES "CHATTING_ROOM" (
	"CHATTING_NO"
) ON DELETE CASCADE;



SELECT * FROM CHATTING_ROOM;


SELECT * FROM "MESSAGE";


DELETE FROM CHATTING_ROOM;
COMMIT;




SELECT CHATTING_NO
			,(SELECT MESSAGE_CONTENT FROM (
				SELECT * FROM MESSAGE M2
				WHERE M2.CHATTING_NO = R.CHATTING_NO
				ORDER BY MESSAGE_NO DESC) 
				WHERE ROWNUM = 1) LAST_MESSAGE
			,TO_CHAR(NVL((SELECT MAX(SEND_TIME) SEND_TIME 
					FROM MESSAGE M
					WHERE R.CHATTING_NO  = M.CHATTING_NO), CREATE_DATE), 
					'YYYY.MM.DD') SEND_TIME
			,NVL2((SELECT OPEN_MEMBER FROM CHATTING_ROOM R2
						WHERE R2.CHATTING_NO = R.CHATTING_NO 
						AND R2.OPEN_MEMBER = #{memberNo}),
						R.PARTICIPANT, -- NULL X
						R.OPEN_MEMBER -- NULL O
				) TARGET_NO	
			,NVL2((SELECT OPEN_MEMBER FROM CHATTING_ROOM R2
				WHERE R2.CHATTING_NO = R.CHATTING_NO
				AND R2.OPEN_MEMBER = #{memberNo}),
				(SELECT MEMBER_NICKNAME FROM MEMBER WHERE MEMBER_NO = R.PARTICIPANT),
				(SELECT MEMBER_NICKNAME FROM MEMBER WHERE MEMBER_NO = R.OPEN_MEMBER)
				) TARGET_NICKNAME	
			,NVL2((SELECT OPEN_MEMBER FROM CHATTING_ROOM R2
				WHERE R2.CHATTING_NO = R.CHATTING_NO
				AND R2.OPEN_MEMBER = #{memberNo}),
				(SELECT PROFILE_IMG FROM MEMBER WHERE MEMBER_NO = R.PARTICIPANT),
				(SELECT PROFILE_IMG FROM MEMBER WHERE MEMBER_NO = R.OPEN_MEMBER)
				) TARGET_PROFILE
			,(SELECT COUNT(*) FROM MESSAGE M 
				WHERE M.CHATTING_NO = R.CHATTING_NO 
				AND READ_FL = 'N' 
				AND SENDER_NO != #{memberNo}) NOT_READ_COUNT
				
				
			,(SELECT MAX(MESSAGE_NO) SEND_TIME 
			FROM MESSAGE M 
			WHERE R.CHATTING_NO  = M.CHATTING_NO) MAX_MESSAGE_NO
		FROM CHATTING_ROOM R
		WHERE OPEN_MEMBER = #{memberNo}
		OR PARTICIPANT = #{memberNo}
		ORDER BY MAX_MESSAGE_NO DESC NULLS LAST


		
		
		
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		






































































