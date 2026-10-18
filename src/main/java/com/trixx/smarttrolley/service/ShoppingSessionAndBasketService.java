package com.trixx.smarttrolley.service;

import com.trixx.smarttrolley.domain.*;
import com.trixx.smarttrolley.dto.ApiDtos.BasketDto;
import com.trixx.smarttrolley.dto.ApiDtos.BasketItemDto;
import com.trixx.smarttrolley.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ShoppingSessionAndBasketService {

    private final ShoppingSessionRepository sessionRepository;
    private final ShoppingBasketRepository basketRepository;
    private final BasketItemRepository basketItemRepository;
    private final TrolleyDeviceRepository trolleyRepository;
    private final CatalogueAndPricingService catalogueAndPricingService;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    public ShoppingSessionAndBasketService(ShoppingSessionRepository sessionRepository,
                                            ShoppingBasketRepository basketRepository,
                                            BasketItemRepository basketItemRepository,
                                            TrolleyDeviceRepository trolleyRepository,
                                            CatalogueAndPricingService catalogueAndPricingService,
                                            OrderRepository orderRepository,
                                            OrderItemRepository orderItemRepository) {
        this.sessionRepository = sessionRepository;
        this.basketRepository = basketRepository;
        this.basketItemRepository = basketItemRepository;
        this.trolleyRepository = trolleyRepository;
        this.catalogueAndPricingService = catalogueAndPricingService;
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
    }

    @Transactional
    public ShoppingSession createOrGetSession(Long trolleyId, User customer) {
        var activeOpt = sessionRepository.findByTrolleyIdAndSessionStatus(trolleyId, "ACTIVE");
        if (activeOpt.isPresent()) {
            return activeOpt.get();
        }

        TrolleyDevice trolley = trolleyRepository.findById(trolleyId)
                .orElseThrow(() -> new IllegalArgumentException("DEVICE_NOT_FOUND: Trolley ID not found"));

        trolley.setDeviceStatus("IN_USE");
        trolleyRepository.save(trolley);

        ShoppingSession session = new ShoppingSession();
        session.setTenant(trolley.getTenant());
        session.setBranch(trolley.getBranch());
        session.setTrolley(trolley);
        session.setCustomer(customer);
        session.setStartedAt(LocalDateTime.now());
        session.setExpiresAt(LocalDateTime.now().plusHours(4));
        session.setSessionStatus("ACTIVE");

        session = sessionRepository.save(session);

        ShoppingBasket basket = new ShoppingBasket();
        basket.setSession(session);
        basketRepository.save(basket);

        return session;
    }

    @Transactional
    public BasketDto processScanEvent(Long sessionId, String barcode) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("SESSION_EXPIRED: Shopping session not found or expired"));

        if (!"ACTIVE".equals(session.getSessionStatus())) {
            throw new IllegalStateException("SESSION_INACTIVE: Shopping session is not active");
        }

        ShoppingBasket basket = basketRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new IllegalStateException("BASKET_NOT_FOUND: Shopping basket not found"));

        Product product = catalogueAndPricingService.resolveProductByBarcode(barcode);
        BigDecimal unitPrice = catalogueAndPricingService.getActiveBranchPrice(session.getBranch().getId(), product.getId());

        var itemOpt = basketItemRepository.findByBasketIdAndProductId(basket.getId(), product.getId());
        if (itemOpt.isPresent()) {
            BasketItem item = itemOpt.get();
            item.setQuantity(item.getQuantity() + 1);
            item.setLineTotal(unitPrice.multiply(BigDecimal.valueOf(item.getQuantity())));
            item.setUpdatedAt(LocalDateTime.now());
            basketItemRepository.save(item);
        } else {
            BasketItem item = new BasketItem();
            item.setBasket(basket);
            item.setProduct(product);
            item.setBarcode(barcode);
            item.setQuantity(1);
            item.setUnitPrice(unitPrice);
            item.setLineTotal(unitPrice);
            item.setAddedAt(LocalDateTime.now());
            item.setUpdatedAt(LocalDateTime.now());
            basketItemRepository.save(item);
        }

        recalculateBasket(basket);
        ShoppingBasket savedBasket = basketRepository.save(basket);
        return toBasketDto(savedBasket);
    }

    @Transactional
    public BasketDto processRemovalEvent(Long sessionId, String barcode) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("SESSION_EXPIRED: Shopping session not found"));

        ShoppingBasket basket = basketRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new IllegalStateException("BASKET_NOT_FOUND: Shopping basket not found"));

        Product product = catalogueAndPricingService.resolveProductByBarcode(barcode);
        var itemOpt = basketItemRepository.findByBasketIdAndProductId(basket.getId(), product.getId());

        if (itemOpt.isPresent()) {
            BasketItem item = itemOpt.get();
            if (item.getQuantity() > 1) {
                item.setQuantity(item.getQuantity() - 1);
                item.setLineTotal(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                item.setUpdatedAt(LocalDateTime.now());
                basketItemRepository.save(item);
            } else {
                basketItemRepository.delete(item);
            }
        }

        recalculateBasket(basket);
        ShoppingBasket savedBasket = basketRepository.save(basket);
        return toBasketDto(savedBasket);
    }

    @Transactional
    public BasketDto removeBasketItemById(Long sessionId, Long itemId) {
        ShoppingBasket basket = basketRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new IllegalStateException("BASKET_NOT_FOUND: Shopping basket not found"));

        basketItemRepository.findById(itemId).ifPresent(item -> {
            if (item.getBasket().getId().equals(basket.getId())) {
                basketItemRepository.delete(item);
            }
        });

        recalculateBasket(basket);
        ShoppingBasket savedBasket = basketRepository.save(basket);
        return toBasketDto(savedBasket);
    }

    @Transactional(readOnly = true)
    public BasketDto getBasketDtoBySessionId(Long sessionId) {
        ShoppingBasket basket = basketRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new IllegalStateException("BASKET_NOT_FOUND: Shopping basket not found"));
        return toBasketDto(basket);
    }

    @Transactional
    public Order createCheckoutSnapshot(Long sessionId) {
        ShoppingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("SESSION_EXPIRED: Shopping session not found"));

        ShoppingBasket basket = basketRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new IllegalStateException("BASKET_NOT_FOUND: Shopping basket not found"));

        List<BasketItem> items = basketItemRepository.findByBasketId(basket.getId());
        if (items.isEmpty()) {
            throw new IllegalStateException("BASKET_EMPTY: Cannot proceed to checkout with an empty basket");
        }

        recalculateBasket(basket);

        Order order = new Order();
        order.setTenant(session.getTenant());
        order.setBranch(session.getBranch());
        order.setSession(session);
        order.setCustomer(session.getCustomer());
        order.setOrderNumber("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        order.setSubtotal(basket.getSubtotal());
        order.setTaxAmount(basket.getTaxAmount());
        order.setDiscountAmount(basket.getDiscountAmount());
        order.setTotalAmount(basket.getTotalAmount());
        order.setOrderStatus("CHECKOUT_PENDING");

        order = orderRepository.save(order);

        for (BasketItem bItem : items) {
            OrderItem oItem = new OrderItem();
            oItem.setOrder(order);
            oItem.setProduct(bItem.getProduct());
            oItem.setProductName(bItem.getProduct().getName());
            oItem.setQuantity(bItem.getQuantity());
            oItem.setUnitPrice(bItem.getUnitPrice());
            oItem.setTaxAmount(bItem.getTaxAmount());
            oItem.setDiscountAmount(bItem.getDiscountAmount());
            oItem.setLineTotal(bItem.getLineTotal());
            oItem.setPriceVersionHash("PV-" + bItem.getProduct().getId() + "-" + bItem.getUnitPrice());
            orderItemRepository.save(oItem);
        }

        return order;
    }

    private void recalculateBasket(ShoppingBasket basket) {
        List<BasketItem> items = basketItemRepository.findByBasketId(basket.getId());
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal expectedWeight = BigDecimal.ZERO;

        for (BasketItem item : items) {
            subtotal = subtotal.add(item.getLineTotal());
            if (item.getProduct().getExpectedWeightGrams() != null) {
                expectedWeight = expectedWeight.add(item.getProduct().getExpectedWeightGrams().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }

        basket.setSubtotal(subtotal);
        basket.setDiscountAmount(BigDecimal.ZERO);
        BigDecimal taxAmount = subtotal.multiply(new BigDecimal("0.16")).setScale(2, RoundingMode.HALF_UP);
        basket.setTaxAmount(taxAmount);
        basket.setTotalAmount(subtotal);
        basket.setExpectedTotalWeight(expectedWeight);
        basket.setUpdatedAt(LocalDateTime.now());
    }

    private BasketDto toBasketDto(ShoppingBasket basket) {
        List<BasketItem> items = basketItemRepository.findByBasketId(basket.getId());
        List<BasketItemDto> itemDtos = items.stream().map(i -> new BasketItemDto(
                i.getId(),
                i.getProduct().getId(),
                i.getProduct().getName(),
                i.getBarcode(),
                i.getQuantity(),
                i.getUnitPrice(),
                i.getLineTotal()
        )).collect(Collectors.toList());

        return new BasketDto(
                basket.getId(),
                basket.getSession().getId(),
                basket.getVersion(),
                basket.getSubtotal(),
                basket.getTaxAmount(),
                basket.getDiscountAmount(),
                basket.getTotalAmount(),
                basket.getExpectedTotalWeight(),
                basket.getStatus(),
                itemDtos
        );
    }
}
