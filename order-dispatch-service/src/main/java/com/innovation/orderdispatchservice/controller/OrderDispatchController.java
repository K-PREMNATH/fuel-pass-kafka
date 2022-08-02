package com.innovation.orderdispatchservice.controller;

import com.innovation.orderdispatchservice.dto.request.OrderScheduleRequest;
import com.innovation.orderdispatchservice.service.OrderWorkflowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:03 AM Wednesday
 **/
@RestController
@RequestMapping("/api/v1/order-dispatch")
public class OrderDispatchController {

    @Autowired
    private OrderWorkflowService orderWorkflowService;

    @PostMapping("/status")
    public ResponseEntity<?> scheduleOrder(@RequestBody OrderScheduleRequest orderSchedule) {
        return new ResponseEntity<>(orderWorkflowService.scheduleOrder(orderSchedule), HttpStatus.OK);
    }
}
