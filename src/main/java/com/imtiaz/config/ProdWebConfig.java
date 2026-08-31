package com.imtiaz.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Production profile: registers the /resources/** handler with long-lived
 * caching (period comes from spring.resources.cache.period in
 * application.properties). Active when the "dev" profile is NOT set.
 *
 * @author Imtiaz
 */
@Configuration
@Profile("!dev")
public class ProdWebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("/resources/")
                .setCachePeriod(12 * 60 * 60);
    }
}
