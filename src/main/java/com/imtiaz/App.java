package com.imtiaz;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 *
 * @author Imtiaz
 */
@SpringBootApplication
public class App extends SpringBootServletInitializer {

    /**
     *
     */
    public App() {
        super();
    }

    /**
     *
     * @param args
     */
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
    
    /**
     *
     * @param application
     * @return
     */
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(App.class);
    }

}
