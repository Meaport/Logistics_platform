FROM maven:3.9-amazoncorretto-17-debian AS build
WORKDIR /app
COPY . .

# Set Maven memory options to prevent OOM
ENV MAVEN_OPTS="-Xmx1024m -XX:MaxMetaspaceSize=256m"

RUN mvn clean package -DskipTests -pl user-service -am

FROM openjdk:17-jdk-slim
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/user-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
