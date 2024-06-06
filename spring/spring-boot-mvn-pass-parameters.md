Suppose that when you run your jar it requires to pass the following parameters

```
# java –jar myprog.jar -v 1 -a ddd 
```
 
Then when using spring-boot Main(args) and/or `CommandLineRunner` you get  
```
java.lang.IllegalStateException: Failed to execute CommandLineRunner 
```
 
Use the following 
 
```
# mvnw spring-boot:run-Dspring-boot.run.arguments="-v 1 -a ddd" 
# mvn spring-boot:run -Dspring-boot.run.arguments="-v 1 -a ddd" 
# mvn exec:java -Dexec.mainClass=com.dimipet.myapp.MyApplicationMainClass -Dexec.args="-v 111 -a dimipet" 
```
