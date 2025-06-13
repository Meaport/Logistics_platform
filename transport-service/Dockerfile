FROM maven:3.9-amazoncorretto-17-debian AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -pl transport-service -am

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/transport-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
