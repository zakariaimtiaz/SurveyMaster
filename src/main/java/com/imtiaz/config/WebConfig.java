package com.imtiaz.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Dev profile: serves static resources straight from the source folder with
 * caching disabled, so edits to CSS/JS/images show up on browser refresh
 * without rebuilding. Active with: --spring.profiles.active=dev
 *
 * @author Imtiaz
 */
@Configuration
@Profile("dev")
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/resources/**")
                .addResourceLocations(
                        "file:src/main/webapp/resources/",
                        "/resources/")
                .setCachePeriod(0);
    }
}
