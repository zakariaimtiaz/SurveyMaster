package com.imtiaz.config;

import org.springframework.http.HttpStatus;

/**
 *
 * @author Imtiaz
 * @param <T>
 */
public class AppResponse<T> {

    private HttpStatus status;
    private String message;
    private T body;
    private Integer code;

    private AppResponse(HttpStatus status) {
        this.status = status;
        this.code = status.value();
    }

    private AppResponse() {
    }

    /**
     *
     * @param status
     * @return
     */
    public static AppResponse build(HttpStatus status) {
        return new AppResponse(status);
    }

    /**
     *
     * @return
     */
    public Integer getCode() {
        return code;
    }

    /**
     *
     * @return
     */
    public HttpStatus getStatus() {
        return status;
    }

    /**
     *
     * @return
     */
    public String getMessage() {
        return message;
    }

    /**
     *
     * @param message
     * @return
     */
    public AppResponse message(String message) {
        this.message = message;
        return this;
    }

    /**
     *
     * @return
     */
    public T getBody() {
        return body;
    }

    /**
     *
     * @param data
     * @return
     */
    public AppResponse body(T data) {
        this.body = data;
        return this;
    }

}
