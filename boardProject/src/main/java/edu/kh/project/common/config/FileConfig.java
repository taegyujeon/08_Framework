package edu.kh.project.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.util.unit.DataSize;
import org.springframework.web.multipart.MultipartResolver;
import org.springframework.web.multipart.support.StandardServletMultipartResolver;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;

import jakarta.servlet.MultipartConfigElement;

//@PropertySource("classpath:/config.properties")
//-> config.properties에 작성된 내용을 해당 클래스에서 사용하겠다

@Configuration
@PropertySource ("classpath:/config.properties")
public class FileConfig {
	
	// config.properties에 작성된 파일 업로드 임계값 얻어와 필드에 대입
	@Value("${spring.servlet.multipart.file-size-threshold}")
	private long fileSizeThreshold;
	
	@Value("${spring.servlet.multipart.max-request-size}")
	private long maxRequestSize; // 요청당 파일 최대 크기
	
	@Value("${spring.servlet.multipart.max-file-size}")
	private long maxFileSize; // 개별 파일당 최대 크기
	
	@Value("${spring.servlet.multipart.location}")
	private String location; // 임계값 초과 시 임시 저장 폴더 경로
	
	
	// 요청 주소에 따라 
	// 서버 컴퓨터의 어떤 경로에 접근할 지 설정
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		
		registry
		.addResourceHandler("/myPage/file/**") // 클라이언트 요청 주소 패턴
		.addResourceLocations("file:///C:\\uploadFiles\\test\\");
		
	}
	
	
	
	/* MultipartResolver 설정 */
	@Bean
	public MultipartConfigElement configElement() {
		
		MultipartConfigFactory factory = new MultipartConfigFactory();
		
		factory.setFileSizeThreshold(DataSize.ofBytes(fileSizeThreshold));
		
		factory.setMaxFileSize(DataSize.ofBytes(maxFileSize));
		
		factory.setMaxRequestSize(DataSize.ofBytes(maxRequestSize));
		
		factory.setLocation(location);
		
		
		return factory.createMultipartConfig();
	}
	
	
	@Bean
	public MultipartResolver multipartResovler() {
		StandardServletMultipartResolver multipartResolver
		= new StandardServletMultipartResolver();
		
		return multipartResolver;
	}
	
	
	
	
	
	
	
	
	
	
	
}





























