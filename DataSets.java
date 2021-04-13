package com.example.JSPdemo;

import java.sql.*;
import java.util.ArrayList;

public class DataSets {
    //    private static final long serialVersionUID = 1L;
    // 参数：
    // JDBC 驱动名
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


    public static ArrayList<DataInfo> getDataInfo(String location) {
        ArrayList<DataInfo> list = new ArrayList<DataInfo>();
        try {

            Class.forName("org.postgresql.Driver");
            // 2. 连接数据库，返回连接对象
            conn = DriverManager.getConnection(DB_URL, USER, PASS);

            // 执行 SQL 查询（postgresql中文乱码是否影响查询？改用拼音尝试（依然失败））
            stmt = conn.createStatement();
            //注意这里查询的是pinyin还是name！！！
            sql = "select res1_4m_id, pinyin, name, st_asgeojson(geom) from res1_4m where name ilike '%" + location + "%'";

            rs = stmt.executeQuery(sql);
            // 展开结果集数据库
            while (rs.next()) {
                DataInfo data = new DataInfo();
                data.setId(rs.getDouble("res1_4m_id"));
                data.setName(rs.getString("name"));
                data.setPinyin(rs.getString("pinyin"));
                data.setGeom(rs.getString("st_asgeojson"));
                list.add(data);
            }
//            out.println("</body></html>");

            // 完成后关闭
            rs.close();
            stmt.close();
            conn.close();
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
        return list;
    }

    //将list转成json样式的字符串（目前是制作geojson方便leaflet直接读取）
    public static String dataJson(ArrayList<DataInfo> list) {
        int i = 0;
        String json = "{\"type\": \"FeatureCollection\",\"features\": [";
        for (DataInfo dataInfo : list) {
            String line = "{\"type\": \"Feature\",\"properties\":{\"name\":\"" + dataInfo.getName() +
                    "\",\"id\":\"" + dataInfo.getId() + //数字不需要引号(但建议还是改成字符串）
                    "\",\"pinyin\":\"" + dataInfo.getPinyin() + "\"}," +
                    "\"geometry\":" + dataInfo.getGeom() +
                    "},\r\n";
            json = json + line;
            i++;
        }
        json = json.substring(0, json.length() - 3);
        json = json + "],\"totalFeatures\": "+ i +"}";
        return json;




    }
}
