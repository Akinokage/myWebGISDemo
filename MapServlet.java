package com.example.JSPdemo;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet(name = "MapServlet", value = "/MapServlet")
public class MapServlet extends HttpServlet {
    public void init() {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取搜索输入值
        String location = request.getParameter("location");

        // 设置响应内容类型
        response.setContentType("text/html;charset=utf-8");

        response.setCharacterEncoding("utf-8");
        request.setCharacterEncoding("utf-8");

        ArrayList<DataInfo> list=DataSets.getDataInfo(location);
        String json=DataSets.dataJson(list);
        PrintWriter out = response.getWriter();
        out.println(json);
        out.close();

    }


    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        doGet(request, response);
    }


    public void destroy() {
    }
}