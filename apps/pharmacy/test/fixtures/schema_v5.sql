CREATE TABLE "customers" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "phone" TEXT NULL, "notes" TEXT NULL, "created_at" TEXT NOT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "debt_events" ("id" TEXT NOT NULL, "type" TEXT NOT NULL, "customer_id" TEXT NOT NULL, "amount_minor" INTEGER NOT NULL, "currency_code" TEXT NOT NULL, "sale_id" TEXT NULL, "note" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "devices" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "is_this_device" INTEGER NOT NULL DEFAULT 0 CHECK ("is_this_device" IN (0, 1)), "created_at" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "employees" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "role" TEXT NOT NULL, "pin_hash" TEXT NOT NULL, "pin_salt" TEXT NOT NULL, "active" INTEGER NOT NULL DEFAULT 1 CHECK ("active" IN (0, 1)), "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "expense_events" ("id" TEXT NOT NULL, "category" TEXT NOT NULL, "amount_minor" INTEGER NOT NULL, "currency_code" TEXT NOT NULL, "paid_from" TEXT NOT NULL, "note" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "product_barcodes" ("barcode" TEXT NOT NULL, "product_id" TEXT NOT NULL REFERENCES products (id), PRIMARY KEY ("barcode"));
CREATE TABLE "products" ("id" TEXT NOT NULL, "trade_name" TEXT NOT NULL, "arabic_name" TEXT NULL, "active_ingredient" TEXT NOT NULL, "strength" TEXT NULL, "form" TEXT NULL, "manufacturer" TEXT NULL, "shelf" TEXT NULL, "price_minor" INTEGER NOT NULL, "prescription_only" INTEGER NOT NULL DEFAULT 0 CHECK ("prescription_only" IN (0, 1)), "low_stock_threshold" INTEGER NOT NULL DEFAULT 5, "units_per_pack" INTEGER NOT NULL DEFAULT 1, "strip_price_minor" INTEGER NULL, "active" INTEGER NOT NULL DEFAULT 1 CHECK ("active" IN (0, 1)), "created_at" TEXT NOT NULL, "updated_at" TEXT NOT NULL, "updated_by_device" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "purchase_lines" ("id" TEXT NOT NULL, "purchase_id" TEXT NOT NULL REFERENCES purchases (id), "product_id" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "bonus" INTEGER NOT NULL, "pieces_per_unit" INTEGER NOT NULL, "unit_price_minor" INTEGER NOT NULL, "discount_basis_points" INTEGER NOT NULL, "cost_minor" INTEGER NOT NULL, "batch_id" TEXT NOT NULL, "expiry" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "purchase_order_lines" ("id" TEXT NOT NULL, "order_id" TEXT NOT NULL REFERENCES purchase_orders (id), "product_id" TEXT NOT NULL, "quantity" INTEGER NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "purchase_orders" ("id" TEXT NOT NULL, "supplier_id" TEXT NOT NULL, "status" TEXT NOT NULL, "note" TEXT NULL, "created_at" TEXT NOT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "purchases" ("id" TEXT NOT NULL, "supplier_id" TEXT NOT NULL, "supplier_invoice_no" TEXT NULL, "payment" TEXT NOT NULL, "paid_from" TEXT NULL, "currency_code" TEXT NOT NULL, "gross_minor" INTEGER NOT NULL, "line_discounts_minor" INTEGER NOT NULL, "invoice_discount_minor" INTEGER NOT NULL, "transport_minor" INTEGER NOT NULL, "total_minor" INTEGER NOT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "return_lines" ("id" TEXT NOT NULL, "return_id" TEXT NOT NULL REFERENCES returns (id), "product_id" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "unit_price_minor" INTEGER NOT NULL, "pieces_per_unit" INTEGER NOT NULL, "sale_line_id" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "returns" ("id" TEXT NOT NULL, "sale_id" TEXT NULL, "customer_id" TEXT NULL, "refund" TEXT NOT NULL, "currency_code" TEXT NOT NULL, "total_minor" INTEGER NOT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "sale_lines" ("id" TEXT NOT NULL, "sale_id" TEXT NOT NULL REFERENCES sales (id), "product_id" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "unit_price_minor" INTEGER NOT NULL, "pieces_per_unit" INTEGER NOT NULL DEFAULT 1, PRIMARY KEY ("id"));
CREATE TABLE "sales" ("id" TEXT NOT NULL, "customer_id" TEXT NULL, "payment" TEXT NOT NULL, "currency_code" TEXT NOT NULL, "subtotal_minor" INTEGER NOT NULL, "discount_minor" INTEGER NOT NULL, "total_minor" INTEGER NOT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, "tendered_minor" INTEGER NULL, PRIMARY KEY ("id"));
CREATE TABLE "settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, PRIMARY KEY ("key"));
CREATE TABLE "stock_events" ("id" TEXT NOT NULL, "type" TEXT NOT NULL, "product_id" TEXT NOT NULL, "batch_id" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "expiry" TEXT NULL, "unit_cost_minor" INTEGER NULL, "sale_id" TEXT NULL, "note" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, "ref_id" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "stocktake_counts" ("id" TEXT NOT NULL, "stocktake_id" TEXT NOT NULL REFERENCES stocktakes (id), "product_id" TEXT NOT NULL, "counted_pieces" INTEGER NOT NULL, "system_pieces_at_count" INTEGER NOT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "stocktakes" ("id" TEXT NOT NULL, "scope" TEXT NULL, "started_by" TEXT NOT NULL, "started_at" TEXT NOT NULL, "applied_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "supplier_debt_events" ("id" TEXT NOT NULL, "type" TEXT NOT NULL, "supplier_id" TEXT NOT NULL, "amount_minor" INTEGER NOT NULL, "currency_code" TEXT NOT NULL, "ref_id" TEXT NULL, "note" TEXT NULL, "paid_from" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "supplier_returns" ("id" TEXT NOT NULL, "supplier_id" TEXT NOT NULL, "total_minor" INTEGER NOT NULL, "refunded_in_cash" INTEGER NOT NULL CHECK ("refunded_in_cash" IN (0, 1)), "note" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE TABLE "suppliers" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "phone" TEXT NULL, "rep_name" TEXT NULL, "notes" TEXT NULL, "credit_limit_minor" INTEGER NULL, "active" INTEGER NOT NULL DEFAULT 1 CHECK ("active" IN (0, 1)), "created_at" TEXT NOT NULL, "updated_at" TEXT NOT NULL, PRIMARY KEY ("id"));
CREATE TABLE "till_events" ("id" TEXT NOT NULL, "type" TEXT NOT NULL, "shift_id" TEXT NOT NULL, "amount_minor" INTEGER NOT NULL, "note" TEXT NULL, "device_id" TEXT NOT NULL, "employee_id" TEXT NOT NULL, "occurred_at" TEXT NOT NULL, "synced_at" TEXT NULL, PRIMARY KEY ("id"));
CREATE INDEX debt_events_customer ON debt_events (customer_id);
CREATE INDEX expense_events_occurred ON expense_events (occurred_at);
CREATE INDEX product_barcodes_product ON product_barcodes (product_id);
CREATE INDEX products_ingredient ON products (active_ingredient);
CREATE INDEX purchase_lines_batch ON purchase_lines (batch_id);
CREATE INDEX purchase_lines_product ON purchase_lines (product_id);
CREATE INDEX purchase_lines_purchase ON purchase_lines (purchase_id);
CREATE INDEX purchases_occurred ON purchases (occurred_at);
CREATE INDEX purchases_supplier ON purchases (supplier_id);
CREATE INDEX return_lines_sale_line ON return_lines (sale_line_id);
CREATE INDEX sale_lines_sale ON sale_lines (sale_id);
CREATE INDEX sales_occurred ON sales (occurred_at);
CREATE INDEX stock_events_product ON stock_events (product_id);
CREATE INDEX stock_events_ref ON stock_events (ref_id);
CREATE INDEX stock_events_unsynced ON stock_events (synced_at) WHERE synced_at IS NULL;
CREATE INDEX stocktake_counts_session ON stocktake_counts (stocktake_id);
CREATE INDEX supplier_debt_events_supplier ON supplier_debt_events (supplier_id);
CREATE INDEX till_events_shift ON till_events (shift_id);
CREATE TRIGGER debt_events_no_delete BEFORE DELETE ON debt_events
        BEGIN SELECT RAISE(ABORT, 'append-only: debt_events'); END;
CREATE TRIGGER debt_events_no_update BEFORE UPDATE ON debt_events
        WHEN NOT (OLD.id IS NEW.id AND OLD.type IS NEW.type AND OLD.customer_id IS NEW.customer_id AND OLD.amount_minor IS NEW.amount_minor AND OLD.currency_code IS NEW.currency_code AND OLD.sale_id IS NEW.sale_id AND OLD.note IS NEW.note AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
        BEGIN SELECT RAISE(ABORT, 'append-only: debt_events'); END;
CREATE TRIGGER expense_events_no_delete BEFORE DELETE ON expense_events
        BEGIN SELECT RAISE(ABORT, 'append-only: expense_events'); END;
CREATE TRIGGER expense_events_no_update BEFORE UPDATE ON expense_events
    WHEN NOT (OLD.id IS NEW.id AND OLD.category IS NEW.category AND OLD.amount_minor IS NEW.amount_minor AND OLD.currency_code IS NEW.currency_code AND OLD.paid_from IS NEW.paid_from AND OLD.note IS NEW.note AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
    BEGIN SELECT RAISE(ABORT, 'append-only: expense_events'); END;
CREATE TRIGGER purchase_lines_no_delete BEFORE DELETE ON purchase_lines
        BEGIN SELECT RAISE(ABORT, 'append-only: purchase_lines'); END;
CREATE TRIGGER purchase_lines_no_update BEFORE UPDATE ON purchase_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: purchase_lines'); END;
CREATE TRIGGER purchases_no_delete BEFORE DELETE ON purchases
        BEGIN SELECT RAISE(ABORT, 'append-only: purchases'); END;
CREATE TRIGGER purchases_no_update BEFORE UPDATE ON purchases
    WHEN NOT (OLD.id IS NEW.id AND OLD.supplier_id IS NEW.supplier_id AND OLD.supplier_invoice_no IS NEW.supplier_invoice_no AND OLD.payment IS NEW.payment AND OLD.paid_from IS NEW.paid_from AND OLD.currency_code IS NEW.currency_code AND OLD.gross_minor IS NEW.gross_minor AND OLD.line_discounts_minor IS NEW.line_discounts_minor AND OLD.invoice_discount_minor IS NEW.invoice_discount_minor AND OLD.transport_minor IS NEW.transport_minor AND OLD.total_minor IS NEW.total_minor AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
    BEGIN SELECT RAISE(ABORT, 'append-only: purchases'); END;
CREATE TRIGGER return_lines_no_delete BEFORE DELETE ON return_lines
        BEGIN SELECT RAISE(ABORT, 'append-only: return_lines'); END;
CREATE TRIGGER return_lines_no_update BEFORE UPDATE ON return_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: return_lines'); END;
CREATE TRIGGER returns_no_delete BEFORE DELETE ON returns
        BEGIN SELECT RAISE(ABORT, 'append-only: returns'); END;
CREATE TRIGGER returns_no_update BEFORE UPDATE ON returns
      WHEN NOT (OLD.id IS NEW.id AND OLD.sale_id IS NEW.sale_id AND OLD.customer_id IS NEW.customer_id AND OLD.refund IS NEW.refund AND OLD.currency_code IS NEW.currency_code AND OLD.total_minor IS NEW.total_minor AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
      BEGIN SELECT RAISE(ABORT, 'append-only: returns'); END;
CREATE TRIGGER sale_lines_no_delete BEFORE DELETE ON sale_lines
        BEGIN SELECT RAISE(ABORT, 'append-only: sale_lines'); END;
CREATE TRIGGER sale_lines_no_update BEFORE UPDATE ON sale_lines
      BEGIN SELECT RAISE(ABORT, 'append-only: sale_lines'); END;
CREATE TRIGGER sales_no_delete BEFORE DELETE ON sales
        BEGIN SELECT RAISE(ABORT, 'append-only: sales'); END;
CREATE TRIGGER sales_no_update BEFORE UPDATE ON sales
        WHEN NOT (OLD.id IS NEW.id AND OLD.customer_id IS NEW.customer_id AND OLD.payment IS NEW.payment AND OLD.currency_code IS NEW.currency_code AND OLD.subtotal_minor IS NEW.subtotal_minor AND OLD.discount_minor IS NEW.discount_minor AND OLD.total_minor IS NEW.total_minor AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at AND OLD.tendered_minor IS NEW.tendered_minor)
        BEGIN SELECT RAISE(ABORT, 'append-only: sales'); END;
CREATE TRIGGER stock_events_no_delete BEFORE DELETE ON stock_events
        BEGIN SELECT RAISE(ABORT, 'append-only: stock_events'); END;
CREATE TRIGGER stock_events_no_update BEFORE UPDATE ON stock_events
        WHEN NOT (OLD.id IS NEW.id AND OLD.type IS NEW.type AND OLD.product_id IS NEW.product_id AND OLD.batch_id IS NEW.batch_id AND OLD.quantity IS NEW.quantity AND OLD.expiry IS NEW.expiry AND OLD.unit_cost_minor IS NEW.unit_cost_minor AND OLD.sale_id IS NEW.sale_id AND OLD.note IS NEW.note AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at AND OLD.ref_id IS NEW.ref_id)
        BEGIN SELECT RAISE(ABORT, 'append-only: stock_events'); END;
CREATE TRIGGER stocktake_counts_no_delete BEFORE DELETE ON stocktake_counts
        BEGIN SELECT RAISE(ABORT, 'append-only: stocktake_counts'); END;
CREATE TRIGGER stocktake_counts_no_update BEFORE UPDATE ON stocktake_counts
    WHEN NOT (OLD.id IS NEW.id AND OLD.stocktake_id IS NEW.stocktake_id AND OLD.product_id IS NEW.product_id AND OLD.counted_pieces IS NEW.counted_pieces AND OLD.system_pieces_at_count IS NEW.system_pieces_at_count AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
    BEGIN SELECT RAISE(ABORT, 'append-only: stocktake_counts'); END;
CREATE TRIGGER supplier_debt_events_no_delete BEFORE DELETE ON supplier_debt_events
        BEGIN SELECT RAISE(ABORT, 'append-only: supplier_debt_events'); END;
CREATE TRIGGER supplier_debt_events_no_update BEFORE UPDATE ON supplier_debt_events
    WHEN NOT (OLD.id IS NEW.id AND OLD.type IS NEW.type AND OLD.supplier_id IS NEW.supplier_id AND OLD.amount_minor IS NEW.amount_minor AND OLD.currency_code IS NEW.currency_code AND OLD.ref_id IS NEW.ref_id AND OLD.note IS NEW.note AND OLD.paid_from IS NEW.paid_from AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
    BEGIN SELECT RAISE(ABORT, 'append-only: supplier_debt_events'); END;
CREATE TRIGGER supplier_returns_no_delete BEFORE DELETE ON supplier_returns
        BEGIN SELECT RAISE(ABORT, 'append-only: supplier_returns'); END;
CREATE TRIGGER supplier_returns_no_update BEFORE UPDATE ON supplier_returns
    WHEN NOT (OLD.id IS NEW.id AND OLD.supplier_id IS NEW.supplier_id AND OLD.total_minor IS NEW.total_minor AND OLD.refunded_in_cash IS NEW.refunded_in_cash AND OLD.note IS NEW.note AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
    BEGIN SELECT RAISE(ABORT, 'append-only: supplier_returns'); END;
CREATE TRIGGER till_events_no_delete BEFORE DELETE ON till_events
      BEGIN SELECT RAISE(ABORT, 'append-only: till_events'); END;
CREATE TRIGGER till_events_no_update BEFORE UPDATE ON till_events
      WHEN NOT (OLD.id IS NEW.id AND OLD.type IS NEW.type AND OLD.shift_id IS NEW.shift_id AND OLD.amount_minor IS NEW.amount_minor AND OLD.note IS NEW.note AND OLD.device_id IS NEW.device_id AND OLD.employee_id IS NEW.employee_id AND OLD.occurred_at IS NEW.occurred_at)
      BEGIN SELECT RAISE(ABORT, 'append-only: till_events'); END;
