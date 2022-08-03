package com.consumer;

import com.dto.request.TopicReq;
import com.google.gson.Gson;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import java.util.logging.Logger;

@Component
public class KafkaConsumerService {

    private static final Logger LOGGER = Logger.getLogger(KafkaConsumerService.class.getName());
    @KafkaListener(topics = "OrderTopic", groupId = "test-consumer-group")
    public void processMessage(String content) {
        Gson gson = new Gson();
        LOGGER.info("Message received by consumer: " + content);
        TopicReq topicReq = gson.fromJson(content, TopicReq.class);
        LOGGER.info("ConvertedTopic--------------->"+topicReq.toString());

    }
}
