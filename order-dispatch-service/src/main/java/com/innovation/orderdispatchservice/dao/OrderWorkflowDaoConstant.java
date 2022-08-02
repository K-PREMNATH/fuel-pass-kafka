package com.innovation.orderdispatchservice.dao;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:55 AM Wednesday
 **/
public class OrderWorkflowDaoConstant {
    interface OrderWorkflow {
        String UPDATE_ORDER_STATUS = "{call update_order_status(?,?)}";
        int orderStatus = 3; // 3 for scheduled
    }
}
