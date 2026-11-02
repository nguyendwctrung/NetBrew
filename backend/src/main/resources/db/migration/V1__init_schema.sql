CREATE TABLE users (
                       id            BIGINT       NOT NULL AUTO_INCREMENT,
                       firebase_uid  VARCHAR(128) NOT NULL,
                       phone         VARCHAR(20)  NOT NULL,
                       email         VARCHAR(255) NULL,
                       full_name     VARCHAR(100) NOT NULL,
                       avatar_key    VARCHAR(255) NULL,
                       role          VARCHAR(20)  NOT NULL DEFAULT 'CUSTOMER',
                       status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
                       created_at    DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                       updated_at    DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                       PRIMARY KEY (id),
                       UNIQUE KEY uk_users_firebase_uid (firebase_uid),
                       UNIQUE KEY uk_users_phone (phone),
                       UNIQUE KEY uk_users_email (email),
                       CONSTRAINT ck_users_role   CHECK (role IN ('CUSTOMER', 'STAFF', 'ADMIN')),
                       CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'BLOCKED'))
) ENGINE=InnoDB;

CREATE TABLE user_addresses (
                                id              BIGINT        NOT NULL AUTO_INCREMENT,
                                user_id         BIGINT        NOT NULL,
                                label           VARCHAR(50)   NULL,
                                recipient_name  VARCHAR(100)  NOT NULL,
                                recipient_phone VARCHAR(20)   NOT NULL,
                                address_line    VARCHAR(255)  NOT NULL,
                                latitude        DECIMAL(9, 6) NOT NULL,
                                longitude       DECIMAL(9, 6) NOT NULL,
                                is_default      TINYINT(1)    NOT NULL DEFAULT 0,
                                created_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                                updated_at      DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                                PRIMARY KEY (id),
                                KEY idx_user_addresses_user (user_id),
                                CONSTRAINT fk_user_addresses_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE device_tokens (
                               id           BIGINT       NOT NULL AUTO_INCREMENT,
                               user_id      BIGINT       NOT NULL,
                               token        VARCHAR(512) NOT NULL,
                               platform     VARCHAR(20)  NOT NULL DEFAULT 'ANDROID',
                               created_at   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                               last_seen_at DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                               PRIMARY KEY (id),
                               UNIQUE KEY uk_device_tokens_token (token),
                               KEY idx_device_tokens_user (user_id),
                               CONSTRAINT fk_device_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Đúng một dòng (id = 1): cấu hình của cửa hàng duy nhất.
CREATE TABLE store_info (
                            id                INT           NOT NULL,
                            name              VARCHAR(100)  NOT NULL,
                            phone             VARCHAR(20)   NULL,
                            address           VARCHAR(255)  NOT NULL,
                            latitude          DECIMAL(9, 6) NOT NULL,
                            longitude         DECIMAL(9, 6) NOT NULL,
                            opening_time      TIME          NOT NULL,
                            closing_time      TIME          NOT NULL,
                            delivery_radius_m INT           NOT NULL,
                            delivery_fee      BIGINT        NOT NULL,
                            accepting_orders  TINYINT(1)    NOT NULL DEFAULT 1,
                            updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                            PRIMARY KEY (id),
                            CONSTRAINT ck_store_info_single_row CHECK (id = 1),
                            CONSTRAINT ck_store_info_radius CHECK (delivery_radius_m > 0),
                            CONSTRAINT ck_store_info_fee CHECK (delivery_fee >= 0)
) ENGINE=InnoDB;

-- Giá trị tạm: sau khi chạy, cập nhật thành thông tin quán thật (xem mục 5).
INSERT INTO store_info (id, name, phone, address, latitude, longitude, opening_time, closing_time, delivery_radius_m, delivery_fee)
VALUES (1, 'NetBrew Coffee', NULL, 'Replace with the real shop address', 10.776889, 106.700806, '07:00:00', '22:00:00', 5000, 15000);

CREATE TABLE categories (
                            id          BIGINT       NOT NULL AUTO_INCREMENT,
                            name        VARCHAR(100) NOT NULL,
                            description VARCHAR(255) NULL,
                            image_key   VARCHAR(255) NULL,
                            sort_order  INT          NOT NULL DEFAULT 0,
                            is_active   TINYINT(1)   NOT NULL DEFAULT 1,
                            created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                            updated_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                            PRIMARY KEY (id),
                            UNIQUE KEY uk_categories_name (name)
) ENGINE=InnoDB;

-- is_available = 0: tạm hết hàng. is_active = 0: ẩn khỏi menu (xóa mềm).
CREATE TABLE products (
                          id                 BIGINT       NOT NULL AUTO_INCREMENT,
                          category_id        BIGINT       NOT NULL,
                          name               VARCHAR(150) NOT NULL,
                          description        TEXT         NULL,
                          image_key          VARCHAR(255) NULL,
                          supports_sugar_ice TINYINT(1)   NOT NULL DEFAULT 1,
                          is_available       TINYINT(1)   NOT NULL DEFAULT 1,
                          is_active          TINYINT(1)   NOT NULL DEFAULT 1,
                          sort_order         INT          NOT NULL DEFAULT 0,
                          created_at         DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                          updated_at         DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                          PRIMARY KEY (id),
                          KEY idx_products_category (category_id, is_active),
                          CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (id)
) ENGINE=InnoDB;

-- Giá cơ bản theo size. Món không có size (bánh...) chỉ có một dòng, ví dụ "Regular".
CREATE TABLE product_sizes (
                               id         BIGINT      NOT NULL AUTO_INCREMENT,
                               product_id BIGINT      NOT NULL,
                               name       VARCHAR(30) NOT NULL,
                               price      BIGINT      NOT NULL,
                               sort_order INT         NOT NULL DEFAULT 0,
                               is_active  TINYINT(1)  NOT NULL DEFAULT 1,
                               PRIMARY KEY (id),
                               UNIQUE KEY uk_product_sizes_name (product_id, name),
                               CONSTRAINT fk_product_sizes_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
                               CONSTRAINT ck_product_sizes_price CHECK (price >= 0)
) ENGINE=InnoDB;

CREATE TABLE toppings (
                          id           BIGINT       NOT NULL AUTO_INCREMENT,
                          name         VARCHAR(100) NOT NULL,
                          price        BIGINT       NOT NULL,
                          is_available TINYINT(1)   NOT NULL DEFAULT 1,
                          is_active    TINYINT(1)   NOT NULL DEFAULT 1,
                          sort_order   INT          NOT NULL DEFAULT 0,
                          created_at   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                          updated_at   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                          PRIMARY KEY (id),
                          UNIQUE KEY uk_toppings_name (name),
                          CONSTRAINT ck_toppings_price CHECK (price >= 0)
) ENGINE=InnoDB;

CREATE TABLE product_toppings (
                                  product_id BIGINT NOT NULL,
                                  topping_id BIGINT NOT NULL,
                                  PRIMARY KEY (product_id, topping_id),
                                  CONSTRAINT fk_product_toppings_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
                                  CONSTRAINT fk_product_toppings_topping FOREIGN KEY (topping_id) REFERENCES toppings (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orders (
                        id                    BIGINT        NOT NULL AUTO_INCREMENT,
                        code                  VARCHAR(20)   NOT NULL,
                        user_id               BIGINT        NOT NULL,
                        status                VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
                        payment_method        VARCHAR(20)   NOT NULL,
                        payment_status        VARCHAR(20)   NOT NULL DEFAULT 'UNPAID',
                        subtotal              BIGINT        NOT NULL,
                        delivery_fee          BIGINT        NOT NULL,
                        total                 BIGINT        NOT NULL,
                        recipient_name        VARCHAR(100)  NOT NULL,
                        recipient_phone       VARCHAR(20)   NOT NULL,
                        delivery_address      VARCHAR(255)  NOT NULL,
                        delivery_latitude     DECIMAL(9, 6) NOT NULL,
                        delivery_longitude    DECIMAL(9, 6) NOT NULL,
                        note                  VARCHAR(500)  NULL,
                        delivery_provider     VARCHAR(30)   NULL,
                        delivery_tracking_ref VARCHAR(255)  NULL,
                        cancelled_by_role     VARCHAR(20)   NULL,
                        cancel_reason         VARCHAR(255)  NULL,
                        confirmed_at          DATETIME(6)   NULL,
                        completed_at          DATETIME(6)   NULL,
                        cancelled_at          DATETIME(6)   NULL,
                        created_at            DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                        updated_at            DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                        PRIMARY KEY (id),
                        UNIQUE KEY uk_orders_code (code),
                        KEY idx_orders_user_created (user_id, created_at),
                        KEY idx_orders_status_created (status, created_at),
                        CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (id),
                        CONSTRAINT ck_orders_status CHECK (status IN
                                                           ('PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERING', 'COMPLETED', 'CANCELLED')),
                        CONSTRAINT ck_orders_payment_method CHECK (payment_method IN ('CASH', 'ONLINE')),
                        CONSTRAINT ck_orders_payment_status CHECK (payment_status IN
                                                                   ('UNPAID', 'PAID', 'REFUND_PENDING', 'REFUNDED', 'FAILED')),
                        CONSTRAINT ck_orders_amounts CHECK (subtotal >= 0 AND delivery_fee >= 0 AND total >= 0)
) ENGINE=InnoDB;

-- Các cột snapshot (tên, giá) giữ nguyên dữ liệu tại thời điểm đặt, kể cả khi menu đổi sau này.
CREATE TABLE order_items (
                             id              BIGINT       NOT NULL AUTO_INCREMENT,
                             order_id        BIGINT       NOT NULL,
                             product_id      BIGINT       NOT NULL,
                             product_name    VARCHAR(150) NOT NULL,
                             size_name       VARCHAR(30)  NOT NULL,
                             size_price      BIGINT       NOT NULL,
                             toppings_total  BIGINT       NOT NULL DEFAULT 0,
                             quantity        INT          NOT NULL,
                             sugar_level     TINYINT      NULL,
                             ice_level       TINYINT      NULL,
                             note            VARCHAR(255) NULL,
                             line_total      BIGINT       NOT NULL,
                             PRIMARY KEY (id),
                             KEY idx_order_items_order (order_id),
                             KEY idx_order_items_product (product_id),
                             CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders (id) ON DELETE CASCADE,
                             CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (id),
                             CONSTRAINT ck_order_items_quantity CHECK (quantity > 0),
                             CONSTRAINT ck_order_items_sugar CHECK (sugar_level IS NULL OR sugar_level IN (0, 30, 50, 100)),
                             CONSTRAINT ck_order_items_ice   CHECK (ice_level   IS NULL OR ice_level   IN (0, 30, 50, 100))
) ENGINE=InnoDB;

CREATE TABLE order_item_toppings (
                                     id            BIGINT       NOT NULL AUTO_INCREMENT,
                                     order_item_id BIGINT       NOT NULL,
                                     topping_id    BIGINT       NOT NULL,
                                     topping_name  VARCHAR(100) NOT NULL,
                                     price         BIGINT       NOT NULL,
                                     PRIMARY KEY (id),
                                     KEY idx_order_item_toppings_item (order_item_id),
                                     CONSTRAINT fk_oit_item    FOREIGN KEY (order_item_id) REFERENCES order_items (id) ON DELETE CASCADE,
                                     CONSTRAINT fk_oit_topping FOREIGN KEY (topping_id)    REFERENCES toppings (id)
) ENGINE=InnoDB;

CREATE TABLE order_status_history (
                                      id                 BIGINT       NOT NULL AUTO_INCREMENT,
                                      order_id           BIGINT       NOT NULL,
                                      from_status        VARCHAR(20)  NULL,
                                      to_status          VARCHAR(20)  NOT NULL,
                                      changed_by_user_id BIGINT       NULL,
                                      note               VARCHAR(255) NULL,
                                      created_at         DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                                      PRIMARY KEY (id),
                                      KEY idx_osh_order (order_id, created_at),
                                      CONSTRAINT fk_osh_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
                                      CONSTRAINT fk_osh_user  FOREIGN KEY (changed_by_user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE payments (
                          id                BIGINT        NOT NULL AUTO_INCREMENT,
                          order_id          BIGINT        NOT NULL,
                          provider          VARCHAR(20)   NOT NULL,
                          amount            BIGINT        NOT NULL,
                          status            VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
                          provider_txn_id   VARCHAR(100)  NULL,
                          provider_ref      VARCHAR(100)  NULL,
                          payment_url       VARCHAR(1000) NULL,
                          qr_content        TEXT          NULL,
                          paid_at           DATETIME(6)   NULL,
                          raw_callback      JSON          NULL,
                          created_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                          updated_at        DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
                          PRIMARY KEY (id),
                          UNIQUE KEY uk_payments_provider_txn (provider, provider_txn_id),
                          UNIQUE KEY uk_payments_provider_ref (provider, provider_ref),
                          KEY idx_payments_order (order_id),
                          CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (id),
                          CONSTRAINT ck_payments_provider CHECK (provider IN ('CASH', 'MOMO', 'VIETQR')),
                          CONSTRAINT ck_payments_status CHECK (status IN ('PENDING', 'SUCCEEDED', 'FAILED', 'EXPIRED')),
                          CONSTRAINT ck_payments_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE refunds (
                         id                 BIGINT       NOT NULL AUTO_INCREMENT,
                         payment_id         BIGINT       NOT NULL,
                         order_id           BIGINT       NOT NULL,
                         amount             BIGINT       NOT NULL,
                         status             VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
                         reason             VARCHAR(255) NULL,
                         provider_refund_id VARCHAR(100) NULL,
                         requested_by       BIGINT       NULL,
                         processed_by       BIGINT       NULL,
                         created_at         DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                         processed_at       DATETIME(6)  NULL,
                         PRIMARY KEY (id),
                         KEY idx_refunds_order (order_id),
                         CONSTRAINT fk_refunds_payment FOREIGN KEY (payment_id) REFERENCES payments (id),
                         CONSTRAINT fk_refunds_order   FOREIGN KEY (order_id)   REFERENCES orders (id),
                         CONSTRAINT fk_refunds_req     FOREIGN KEY (requested_by) REFERENCES users (id) ON DELETE SET NULL,
                         CONSTRAINT fk_refunds_proc    FOREIGN KEY (processed_by) REFERENCES users (id) ON DELETE SET NULL,
                         CONSTRAINT ck_refunds_status CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED')),
                         CONSTRAINT ck_refunds_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE TABLE notifications (
                               id         BIGINT       NOT NULL AUTO_INCREMENT,
                               user_id    BIGINT       NOT NULL,
                               type       VARCHAR(30)  NOT NULL,
                               title      VARCHAR(150) NOT NULL,
                               body       VARCHAR(500) NOT NULL,
                               order_id   BIGINT       NULL,
                               is_read    TINYINT(1)   NOT NULL DEFAULT 0,
                               created_at DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                               PRIMARY KEY (id),
                               KEY idx_notifications_user (user_id, is_read, created_at),
                               CONSTRAINT fk_notifications_user  FOREIGN KEY (user_id)  REFERENCES users (id) ON DELETE CASCADE,
                               CONSTRAINT fk_notifications_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE feedbacks (
                           id         BIGINT        NOT NULL AUTO_INCREMENT,
                           order_id   BIGINT        NOT NULL,
                           user_id    BIGINT        NOT NULL,
                           rating     TINYINT       NOT NULL,
                           comment    VARCHAR(1000) NULL,
                           created_at DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                           PRIMARY KEY (id),
                           UNIQUE KEY uk_feedbacks_order (order_id),
                           KEY idx_feedbacks_user (user_id),
                           CONSTRAINT fk_feedbacks_order FOREIGN KEY (order_id) REFERENCES orders (id),
                           CONSTRAINT fk_feedbacks_user  FOREIGN KEY (user_id)  REFERENCES users (id),
                           CONSTRAINT ck_feedbacks_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;