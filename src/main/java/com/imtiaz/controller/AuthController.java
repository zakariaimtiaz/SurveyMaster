/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.imtiaz.controller;

import com.imtiaz.config.AppProperty;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

/**
 *
 * @author Imtiaz
 */
@RestController
public class AuthController extends AppProperty {    

    /**
     *
     * @return
     */
    @RequestMapping(value = {"/"}, method = {RequestMethod.GET})
    public ModelAndView index() {   
        return new ModelAndView("home");
    }

    @RequestMapping(value = {"/user-guide"}, method = {RequestMethod.GET})
    public ModelAndView userGuide() {
        return new ModelAndView("user_guide");
    }
}
