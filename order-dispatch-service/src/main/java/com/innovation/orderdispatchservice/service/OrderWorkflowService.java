package com.innovation.orderdispatchservice.service;

import com.innovation.orderdispatchservice.dao.OrderWorkflowDao;
import com.innovation.orderdispatchservice.dto.request.OrderScheduleRequest;
import com.innovation.orderdispatchservice.dto.response.CommonResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:44 AM Wednesday
 **/

@Service
public class OrderWorkflowService {
    @Autowired
    private OrderWorkflowDao orderWorkflowDao;

    public CommonResponse scheduleOrder(OrderScheduleRequest orderScheduleRequest) {
        return orderWorkflowDao.scheduleOrderRequest(orderScheduleRequest);
    }
}
