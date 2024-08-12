# Types of Tests 

There are two types of tests with spring 

1. `junit` 5 Jupiter unit tests 
2. Spring Boot tests `@SpringBootTest` 

# Junit 5 Jupiter unit tests 
- Used for unit testing 
- Isolated unit testing 
- Mocking is involved 
- No need to start up a container to execute the test cases 

# Spring Boot tests @SpringBootTest 
- integration tests focus on integrating different layers of the application 
- That also means no mocking is involved. 
- We should keep the integration tests separated from the unit tests
- should not run along with the unit tests 
- using a different profile to only run the integration tests 
- need to start up a container to execute the test cases 
- `@SpringBootTest` annotation is useful when we need to bootstrap the entire container. 
- `@SpringBootTest` creates the ApplicationContext that will be utilized in our tests 
- means we can `@Autowire` any bean that's picked up by component scanning into our test 


References 

[1] https://www.baeldung.com/spring-boot-testing  




