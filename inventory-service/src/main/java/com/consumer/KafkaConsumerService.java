package com.consumer;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class KafkaConsumerService {
    @KafkaListener(topics = "OrderTopic", groupId = "test-consumer-group")
    public void processMessage(String content) {
        System.out.println("Message received by consumer: " + content);
    }
}
