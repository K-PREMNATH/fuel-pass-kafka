package com.dao;

public class OrderDAOConstant {
    interface Order{
        String INSERT_ORDER_DETAIL = "{call insert_order_detail(?,?,?)}";
    }
}
