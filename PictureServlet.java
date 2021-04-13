package com.example.JSPdemo;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

//import javafx.application.Application;
//import javafx.geometry.Insets;
//import javafx.geometry.Pos;
//import javafx.scene.Node;
//import javafx.scene.Scene;
//import javafx.scene.control.*;
//import javafx.scene.image.Image;
//import javafx.scene.image.ImageView;
//import javafx.scene.layout.*;
//import javafx.scene.media.Media;
//import javafx.scene.media.MediaPlayer;
//import javafx.scene.text.Font;
//import javafx.stage.FileChooser;
//import javafx.stage.Stage;


public class PictureServlet extends HttpServlet {
    static final String JDBC_DRIVER = "jdbc.postgresql.Driver";
    // jdbc协议:postgresql子协议://主机地址:数据库端口号/要连接的数据库名
    static final String DB_URL = "";
    // 数据库的用户名与密码，需要根据自己的设置
    static final String USER = "postgres";
    static final String PASS = "";

    public static String sql;
    public static Statement stmt = null;
    public static ResultSet rs = null;
    public static Connection conn = null;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //获取搜索输入值
        String location = request.getParameter("location");

        String picture = null;

        // 设置响应内容类型
        response.setContentType("text/html;charset=utf-8");

        response.setCharacterEncoding("utf-8");
        request.setCharacterEncoding("utf-8");

        try {
            Class.forName("org.postgresql.Driver");
            // 2. 连接数据库，返回连接对象
            conn = DriverManager.getConnection(DB_URL, USER, PASS);
            //注意这里查询的是pinyin还是name！！！
            sql = "select pic from pictures where name = '" + location + "'";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            // 展开结果集数据库
            if (rs.next()) {
//                OutputStream ops = null;
//                InputStream ips = null;
//                try
//                {
//                    ips = rs.getBinaryStream(1);
//                    picture = ips.toString();
////                    byte[] buffer = new byte[ips.available()];//or other value like 1024
////                    for (int i; (i = ips.read(buffer)) > 0;)
////                    {
////                        ops.write(buffer, 0, i);
////                        ops.flush();
////                    }
//                }
//                catch (Exception ex)
//                {
//                    ex.printStackTrace(System.out);
//                }
//                finally
//                {
//                    ips.close();
//                    ops.close();
//                }

                Blob blob = rs.getBlob("pic");
                if (blob != null) {
                    InputStream in = blob.getBinaryStream();
                    picture = in.toString();
                }
            }
            else {
                picture = "no picture";
            }
            // 完成后关闭
            rs.close();

        } catch (SQLException se) {
            // 处理 JDBC 错误
            se.printStackTrace();
        } catch (Exception e) {
            // 处理 Class.forName 错误
            e.printStackTrace();
        } finally {
            // 最后是用于关闭资源的块
            try {
                if (stmt != null)
                    stmt.close();
            } catch (SQLException se2) {
            }
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }

        PrintWriter out = response.getWriter();
        out.println(picture);
        out.close();

    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        Boolean ifSucceed = false;

        //获取搜索输入值
        String location = request.getParameter("location");
        //图片流可能还是前端获取好一点？不然要用swing或者javafx
//        String picture = request.getParameter("picture");

        // 设置响应内容类型
        response.setContentType("text/html;charset=utf-8");

        response.setCharacterEncoding("utf-8");
        request.setCharacterEncoding("utf-8");

        //选择图片
        File picture = null;
//        FileChooser photoFileChooser = new FileChooser();
//        photoFileChooser.getExtensionFilters().addAll(new FileChooser.ExtensionFilter("jpg pictures", "*.jpg"),
//                new FileChooser.ExtensionFilter("png pictures", "*.png"));
//
//        picture = photoFileChooser.showOpenDialog(new Stage());
        if (picture != null) {
            try {
                BufferedInputStream fis = new BufferedInputStream(new FileInputStream(picture));

                Class.forName("org.postgresql.Driver");
                // 2. 连接数据库，返回连接对象
                conn = DriverManager.getConnection(DB_URL, USER, PASS);
                //注意这里查询的是pinyin还是name！！！
                sql = "update pictures set pic = ? where name = '" + location+ "'";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setBinaryStream(1, fis, (int) picture.length());
                pstmt.executeUpdate();

                ifSucceed = true;
            } catch (SQLException se) {
                // 处理 JDBC 错误
                se.printStackTrace();
            } catch (Exception e) {
                // 处理 Class.forName 错误
                e.printStackTrace();
            } finally {
                // 最后是用于关闭资源的块
                try {
                    if (stmt != null)
                        stmt.close();
                } catch (SQLException se2) {
                }
                try {
                    if (conn != null)
                        conn.close();
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }

            PrintWriter out = response.getWriter();
            out.println(ifSucceed.toString());
            out.close();
        }
    }
}