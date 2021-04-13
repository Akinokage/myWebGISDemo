package com.example.JSPdemo;

import javax.servlet.http.HttpServlet;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.servlet.annotation.*;


public class WeatherServlet extends HttpServlet {

    String url1 = "https://api.seniverse.com/v3/weather/daily.json?key=put your key here&location=";
    String url2 = "&language=zh-Hans&unit=c&start=0&days=3";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取搜索输入值
        String location = request.getParameter("pinyin");
        if (location.equals("Lhasa")) {
            location = "lasa";
        } else if (location.equals("Taipei Shih")) {
            location = "taipei";
        } else if (location.equals("Hong Kong")) {
            location = "xianggang";
        } else if (location.equals("Xi'an")) {
            location = "xian";
        }

        String url3 = url1 + location + url2;
        // 设置响应内容类型
        response.setContentType("text/html;charset=utf-8");

        response.setCharacterEncoding("utf-8");
        request.setCharacterEncoding("utf-8");

        StringBuilder json = new StringBuilder();
        URL oracle = new URL(url3);
        URLConnection yc = oracle.openConnection();
        BufferedReader in = new BufferedReader(new InputStreamReader(yc.getInputStream(), "utf-8"));
        String inputLine = null;
        while ((inputLine = in.readLine()) != null) {
            json.append(inputLine);
        }
        in.close();

//        URL url = null;
//        HttpURLConnection httpConn = null;
//        BufferedReader in = null;
//        StringBuffer sb = new StringBuffer();
//        try{
//            url = new URL(url3);
//            in = new BufferedReader(new InputStreamReader(url.openStream(),"utf-8") );
//            String str = null;
//            while((str = in.readLine()) != null) {
//                sb.append( str );
//            }
//        } catch (Exception ex) {
//        } finally{
//            try{
//                if(in!=null) {
//                    in.close();
//                }
//            }catch(IOException ex) {
//            }
//        }
//        String json =sb.toString();

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
}
