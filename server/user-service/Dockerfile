# ---- Build stage ----
FROM gradle:8.6.0-jdk17-alpine AS build
WORKDIR /workspace/app
# Copy the entire monorepo (needed so Gradle can resolve settings and dependencies)
COPY . .
# Build only the user‑service jar
RUN gradle clean :user-service:bootJar --no-daemon

# ---- Run stage ----
FROM eclipse-temurin:17-jre-alpine
ENV TZ=UTC
WORKDIR /app
COPY --from=build /workspace/app/user-service/build/libs/*.jar user-service.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app/user-service.jar"]