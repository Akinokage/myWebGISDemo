package com.example.JSPdemo;

//用于存储数据库查询结果的类
public class DataInfo {
    public double id;
    public String name,pinyin,geom;
    public double getId() {
        return id;
    }
    public void setId(double id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getPinyin() {
        return pinyin;
    }
    public void setPinyin(String pinyin) {
        this.pinyin = pinyin;
    }
    public String getGeom() {
        return geom;
    }
    public void setGeom(String geom) {
        this.geom = geom;
    }
}
