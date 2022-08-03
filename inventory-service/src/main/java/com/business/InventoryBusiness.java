package com.business;


import com.consumer.KafkaConsumerService;
import com.dao.InventoryDAO;
import com.dto.request.TopicReq;
import com.dto.response.GeneralResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Service
public class InventoryBusiness {

    private static final Logger LOGGER = Logger.getLogger(InventoryBusiness.class.getName());
    @Autowired
    InventoryDAO inventoryDAO;

    @Value(value = "${app.dispatch.url}")
    private String dispatchURL;
    public void processOrderAllocation(TopicReq topicReq){
        try {
            GeneralResponse response = inventoryDAO.updateScheduleOrder(
                    topicReq.getFuelType(),
                    topicReq.getCapacity(),
                    topicReq.getReferenceNumber());
            if(response.getRes())
                callDispatchService(topicReq.getReferenceNumber());
        }catch (Exception exception){
            LOGGER.info("Exception occured in processOrderAllocation, "+exception.toString());
        }
    }

    private void callDispatchService(String referenceNumber) {
        WebClient webClient = WebClient.create(dispatchURL);
        Map map = new HashMap();
        map.put("referenceNumber",referenceNumber);

        WebClient.create(dispatchURL)
                .post()
                .uri("/dispatch-order")
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body(Mono.just(map), Map.class)
                .retrieve().bodyToMono(String.class);
    }
}
