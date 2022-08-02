package com.service;

import com.business.OrderBusiness;
import com.dto.request.FuelOrderReq;
import com.dto.response.CommonResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OrderService {

    @Autowired
    OrderBusiness orderBusiness;

        @PostMapping("/push/order/request")
        public CommonResponse createNewOrder(@RequestBody FuelOrderReq fuelOrderReq) throws Exception{
            return orderBusiness.createNewOrder(fuelOrderReq);
        }
}
