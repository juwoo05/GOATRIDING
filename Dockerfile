# Java 17 (Temurin JDK, Alpine 대신 glibc 기반)
FROM eclipse-temurin:17-jdk

# 임시 디렉토리 마운트
VOLUME /tmp

# 빌드된 WAR 파일 복사
ARG JAR_FILE=target/*.war
COPY ${JAR_FILE} app.war

# Spring Boot 실행
ENTRYPOINT ["java","-jar","/app.war"]
