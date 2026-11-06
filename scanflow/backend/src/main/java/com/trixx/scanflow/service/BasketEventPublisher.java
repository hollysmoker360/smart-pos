package com.trixx.scanflow.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class BasketEventPublisher {
    private static final Logger log = LoggerFactory.getLogger(BasketEventPublisher.class);
    static final int MAX_SUBSCRIBERS_PER_SESSION = 32;
    static final int MAX_SUBSCRIBERS_TOTAL = 1_000;
    static final long EMITTER_TIMEOUT_MILLIS = 5 * 60 * 1_000L;

    private final Map<UUID, Set<SseEmitter>> subscribers = new HashMap<>();
    private int subscriberCount;

    public SseEmitter subscribe(UUID sessionId, ShoppingSessionService.BasketResponse initialSnapshot) {
        SseEmitter emitter = new SseEmitter(EMITTER_TIMEOUT_MILLIS);
        synchronized (subscribers) {
            Set<SseEmitter> sessionSubscribers = subscribers.computeIfAbsent(sessionId, ignored -> new HashSet<>());
            if (subscriberCount >= MAX_SUBSCRIBERS_TOTAL
                    || sessionSubscribers.size() >= MAX_SUBSCRIBERS_PER_SESSION) {
                if (sessionSubscribers.isEmpty()) {
                    subscribers.remove(sessionId);
                }
                throw new SubscriberLimitExceededException();
            }
            sessionSubscribers.add(emitter);
            subscriberCount++;
        }

        emitter.onCompletion(() -> remove(sessionId, emitter));
        emitter.onTimeout(() -> {
            remove(sessionId, emitter);
            emitter.complete();
        });
        emitter.onError(error -> remove(sessionId, emitter));

        try {
            send(emitter, initialSnapshot);
        } catch (IOException | RuntimeException exception) {
            remove(sessionId, emitter);
            log.warn("Failed to send initial basket snapshot for session {}", sessionId, exception);
            emitter.completeWithError(exception);
        }
        return emitter;
    }

    public void publish(UUID sessionId, ShoppingSessionService.BasketResponse snapshot) {
        Set<SseEmitter> sessionSubscribers;
        synchronized (subscribers) {
            Set<SseEmitter> registered = subscribers.get(sessionId);
            sessionSubscribers = registered == null ? Set.of() : Set.copyOf(registered);
        }

        for (SseEmitter emitter : sessionSubscribers) {
            try {
                send(emitter, snapshot);
            } catch (IOException | RuntimeException exception) {
                remove(sessionId, emitter);
                log.warn("Failed to publish basket snapshot for session {}", sessionId, exception);
                emitter.completeWithError(exception);
            }
        }
    }

    private void send(SseEmitter emitter, ShoppingSessionService.BasketResponse snapshot) throws IOException {
        emitter.send(SseEmitter.event().name("basket.snapshot").data(snapshot));
    }

    private void remove(UUID sessionId, SseEmitter emitter) {
        synchronized (subscribers) {
            Set<SseEmitter> sessionSubscribers = subscribers.get(sessionId);
            if (sessionSubscribers != null && sessionSubscribers.remove(emitter)) {
                subscriberCount--;
                if (sessionSubscribers.isEmpty()) {
                    subscribers.remove(sessionId);
                }
            }
        }
    }

    int getSubscriberCount() {
        synchronized (subscribers) {
            return subscriberCount;
        }
    }

    public static class SubscriberLimitExceededException extends RuntimeException {
        public SubscriberLimitExceededException() {
            super("Too many realtime subscribers");
        }
    }
}
