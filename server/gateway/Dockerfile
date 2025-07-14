# ---- Build stage ----
FROM gradle:8.6.0-jdk17-alpine AS build
WORKDIR /workspace/app
COPY . .
RUN gradle clean bootJar --no-daemon

# ---- Run stage ----
FROM eclipse-temurin:17-jre-alpine
ENV TZ=UTC
WORKDIR /app
COPY --from=build /workspace/app/build/libs/*.jar gateway.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/gateway.jar"]