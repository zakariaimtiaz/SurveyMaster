FROM maven:3.8-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

FROM openjdk:8-jre-slim
WORKDIR /app
COPY --from=build /app/target/*.war app.war
COPY run.sh .
RUN chmod +x run.sh
EXPOSE 8080
ENTRYPOINT ["./run.sh"]
