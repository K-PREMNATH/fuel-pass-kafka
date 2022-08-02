package com.business;

import com.dao.OrderDAO;
import com.dto.request.FuelOrderReq;
import com.dto.request.TopicReq;
import com.dto.response.CommonResponse;
import com.dto.response.OrderResponse;
import com.google.gson.Gson;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.KafkaException;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.util.concurrent.ListenableFutureCallback;

import javax.websocket.SendResult;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Service
public class OrderBusiness {

    private static final Logger LOGGER = Logger.getLogger(OrderBusiness.class.getName());
    @Autowired
    OrderDAO orderDAO;
    @Autowired
    KafkaTemplate kafkaTemplate;

    @Value(value = "${topic.name}")
    private String topicName;

    public CommonResponse createNewOrder(FuelOrderReq fuelOrderReq){
        CommonResponse commonResponse = null;
        Gson gson = new Gson();
        try{
            OrderResponse orderResponse = orderDAO.updateOrderRequest(fuelOrderReq);
            if(orderResponse.getRes()){
                TopicReq topicReq = new TopicReq(fuelOrderReq.getShedId(),fuelOrderReq.getFuelType(),fuelOrderReq.getCapacity(),orderResponse.getReferenceNumber());
                Map map = new HashMap();
                map.put("referenceNumber",orderResponse.getReferenceNumber());
                commonResponse = new CommonResponse(map,
                        orderResponse.getStatusCode() == 0 ? 1000 : orderResponse.getStatusCode()
                        ,(orderResponse.getMessage() == null || orderResponse.getMessage().equals("")) ? "Success": orderResponse.getMessage());
                /*Push to Kafka*/
                pushKafkaTopic(gson.toJson(topicReq));
            }else{
                commonResponse = new CommonResponse(null,orderResponse.getStatusCode(),orderResponse.getMessage());
            }
        }catch (Exception exception){
            LOGGER.info("Exception occured in createNewOrder, "+exception.toString());
            commonResponse = new CommonResponse(null,1001,"Unable to place the request...!");
        }
        return commonResponse;
    }

    public void pushKafkaTopic(String data){
        try{
            kafkaTemplate.send(topicName,data);
        }catch (KafkaException exception) {
            LOGGER.info("Exception occured in pushKafkaTopic, "+exception.toString());
        }
    }
}
