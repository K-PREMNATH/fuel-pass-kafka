package com.consumer;

import com.business.InventoryBusiness;
import com.dao.InventoryDAO;
import com.dto.request.TopicReq;
import com.dto.response.GeneralResponse;
import com.google.gson.Gson;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.util.logging.Logger;

@Component
public class KafkaConsumerService {

    @Autowired
    InventoryBusiness inventoryBusiness;

    private static final Logger LOGGER = Logger.getLogger(KafkaConsumerService.class.getName());

    @KafkaListener(topics = "OrderTopic", groupId = "test-consumer-group")
    public void processMessage(String content) {
        Gson gson = new Gson();
        LOGGER.info("Message received by consumer: " + content);
        TopicReq topicReq = gson.fromJson(content, TopicReq.class);
        LOGGER.info("ConvertedTopic--------------->" + topicReq.toString());

        inventoryBusiness.processOrderAllocation(topicReq);
    }


}
