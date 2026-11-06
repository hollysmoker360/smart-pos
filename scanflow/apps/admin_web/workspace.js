const seed = {
    branches: ["Nairobi Main", "Westlands"],
    products: [
        { id: "p1", name: "Maize Flour 2kg", sku: "SF-001", barcode: "6161000000011", category: "Groceries", price: 180, cost: 132, stock: 42, minimum: 12 },
        { id: "p2", name: "White Sugar 1kg", sku: "SF-002", barcode: "6161000000012", category: "Groceries", price: 170, cost: 139, stock: 8, minimum: 15 },
        { id: "p3", name: "Cooking Oil 1L", sku: "SF-003", barcode: "6161000000013", category: "Groceries", price: 280, cost: 220, stock: 24, minimum: 10 },
        { id: "p4", name: "Fresh Milk 500ml", sku: "SF-004", barcode: "6161000000014", category: "Dairy", price: 70, cost: 51, stock: 5, minimum: 14 },
        { id: "p5", name: "Bottled Water 1L", sku: "SF-005", barcode: "6161000000015", category: "Beverages", price: 60, cost: 30, stock: 60, minimum: 20 },
        { id: "p6", name: "Bread 400g", sku: "SF-006", barcode: "6161000000016", category: "Bakery", price: 75, cost: 54, stock: 11, minimum: 16 },
        { id: "p7", name: "Washing Powder 1kg", sku: "SF-008", barcode: "6161000000018", category: "Household", price: 250, cost: 188, stock: 31, minimum: 8 },
        { id: "p8", name: "Rice 2kg", sku: "SF-010", barcode: "6161000000020", category: "Groceries", price: 320, cost: 251, stock: 19, minimum: 10 }
    ],
    orders: [
        { id: "o1", number: "SF-NAI-000124", customer: "Walk-in customer", channel: "CASHIER", method: "M-Pesa", amount: 1180, status: "Confirmed", time: "10:42" },
        { id: "o2", number: "SF-NAI-000123", customer: "Wanjiku N.", channel: "PHONE", method: "M-Pesa", amount: 670, status: "Confirmed", time: "10:18" },
        { id: "o3", number: "SF-NAI-000122", customer: "Walk-in customer", channel: "CASHIER", method: "Cash", amount: 490, status: "Confirmed", time: "09:57" },
        { id: "o4", number: "SF-NAI-000121", customer: "Peter K.", channel: "SMART_TROLLEY", method: "M-Pesa", amount: 1430, status: "Pending", time: "09:44" }
    ],
    customers: [
        { name: "Wanjiku Njoroge", phone: "+254 712 345 678", email: "wanjiku@example.ke", orders: 18, spend: 12450 },
        { name: "Peter Kamau", phone: "+254 722 901 234", email: "peter@example.ke", orders: 7, spend: 6810 },
        { name: "Amina Hassan", phone: "+254 701 332 100", email: "amina@example.ke", orders: 12, spend: 9320 }
    ],
    suppliers: [
        { name: "Nairobi Wholesale Foods", contact: "Mary W.", phone: "+254 720 100 200", balance: 12400, status: "Active" },
        { name: "Fresh Dairy Distributors", contact: "John M.", phone: "+254 733 220 110", balance: 0, status: "Active" }
    ],
    employees: [
        { name: "Grace Wanjiku", email: "grace@scanflow.demo", role: "Branch Manager", branch: "Nairobi Main", status: "Active" },
        { name: "David Ochieng", email: "david@scanflow.demo", role: "Cashier", branch: "Nairobi Main", status: "Active" },
        { name: "Faith Muthoni", email: "faith@scanflow.demo", role: "Inventory Officer", branch: "Westlands", status: "Active" }
    ],
    devices: [
        { code: "POS-NAI-01", type: "POS terminal", branch: "Nairobi Main", status: "Online", lastSeen: "Now" },
        { code: "TRL-NAI-01", type: "SmartTrolley", branch: "Nairobi Main", status: "Online", lastSeen: "1 min ago" },
        { code: "TRL-WES-02", type: "SmartTrolley", branch: "Westlands", status: "Offline", lastSeen: "18 min ago" },
        { code: "EXIT-NAI-01", type: "Exit station", branch: "Nairobi Main", status: "Online", lastSeen: "Now" }
    ],
    promotions: [
        { name: "Weekend pantry", type: "Percentage off", value: "5%", dates: "Nov 07 - Nov 09", status: "Scheduled" },
        { name: "Water multipack", type: "Bundle", value: "Buy 5, pay for 4", dates: "Nov 01 - Nov 30", status: "Active" }
    ],
    movements: [],
    purchaseOrders: [],
    qrCodes: [],
    audit: [
        { action: "Sale completed", actor: "David Ochieng", detail: "SF-NAI-000124", time: "10:42" },
        { action: "Stock count adjusted", actor: "Faith Muthoni", detail: "White Sugar 1kg: -2 units", time: "09:20" },
        { action: "Staff sign-in", actor: "Grace Wanjiku", detail: "Nairobi Main", time: "08:04" }
    ],
    settings: { phone: true, trolley: true, cashier: true, requireExit: true, guest: true }
};

const pages = [
    ["overview", "Overview", "bi-grid-1x2"], ["pos", "Point of Sale", "bi-upc-scan"],
    ["products", "Products & Catalogue", "bi-box-seam"], ["inventory", "Inventory", "bi-inboxes"],
    ["orders", "Orders & Receipts", "bi-receipt"], ["payments", "Payments & Finance", "bi-credit-card"],
    ["customers", "Customers & Loyalty", "bi-people"], ["suppliers", "Suppliers & Purchasing", "bi-truck"],
    ["employees", "Employees & Access", "bi-person-badge"], ["devices", "Devices & Trolleys", "bi-phone-landscape"],
    ["promotions", "Promotions", "bi-tag"], ["reports", "Reports & Analytics", "bi-bar-chart-line"],
    ["qr", "QR Management", "bi-qr-code"], ["audit", "Security & Audit", "bi-shield-check"], ["settings", "Settings", "bi-gear"]
];
const icons = ["bi-basket2", "bi-bag", "bi-droplet", "bi-cup-straw", "bi-box-seam", "bi-basket"];
let state = loadState();
let activePage = "overview";
let cart = [];
let productFilter = "";

function loadState() {
    try {
        const saved = JSON.parse(localStorage.getItem("scanflow-demo-state"));
        return saved && Array.isArray(saved.products) ? saved : structuredClone(seed);
    } catch { return structuredClone(seed); }
}
function saveState() { localStorage.setItem("scanflow-demo-state", JSON.stringify(state)); }
function esc(value) { return String(value ?? "").replace(/[&<>"']/g, char => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[char])); }
function money(value) { return `KSh ${Number(value || 0).toLocaleString("en-KE", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`; }
function id(prefix) { return `${prefix}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`; }
function lowStock() { return state.products.filter(product => Number(product.stock) <= Number(product.minimum)); }
function statusClass(value) {
    const text = String(value).toLowerCase();
    if (text.includes("pending") || text.includes("scheduled") || text.includes("low")) return "warning";
    if (text.includes("offline") || text.includes("failed") || text.includes("out")) return "danger";
    if (text.includes("demo") || text.includes("draft")) return "neutral";
    return "";
}
function status(value) { return `<span class="sf-status ${statusClass(value)}">${esc(value)}</span>`; }
function productIcon(index) { return icons[index % icons.length]; }
function heading(title, subtitle, action = "") {
    return `<header class="sf-heading"><div><h1>${title}</h1><p>${subtitle}</p></div><div class="sf-heading-actions">${action}</div></header>`;
}
function panel(title, subtitle, content, action = "") {
    return `<section class="sf-panel"><div class="sf-panel-head"><div><h2>${title}</h2>${subtitle ? `<small>${subtitle}</small>` : ""}</div>${action}</div>${content}</section>`;
}
function table(headers, rows, empty = "No records yet.") {
    if (!rows.length) return `<div class="sf-empty"><i class="bi bi-inbox"></i>${empty}</div>`;
    return `<div class="sf-table-wrap"><table class="sf-table"><thead><tr>${headers.map(header => `<th>${header}</th>`).join("")}</tr></thead><tbody>${rows.join("")}</tbody></table></div>`;
}
function productTable(products = state.products) {
    return table(["Product", "SKU / Barcode", "Category", "Price", "Cost", "Status", ""], products.map((product, index) => `<tr><td><strong>${esc(product.name)}</strong></td><td>${esc(product.sku)}<small class="d-block text-muted">${esc(product.barcode)}</small></td><td>${esc(product.category)}</td><td>${money(product.price)}</td><td>${money(product.cost)}</td><td>${status(product.stock <= product.minimum ? "Low stock" : "In stock")}</td><td><button class="sf-btn sf-btn-sm" data-action="edit-product" data-id="${esc(product.id)}" aria-label="Edit ${esc(product.name)}"><i class="bi bi-pencil"></i></button></td></tr>`));
}
function orderRows(orders = state.orders) {
    return orders.map(order => `<tr><td><strong>${esc(order.number)}</strong></td><td>${esc(order.time)}</td><td>${esc(order.customer)}</td><td>${esc(order.channel.replaceAll("_", " "))}</td><td>${esc(order.method)}</td><td>${money(order.amount)}</td><td>${status(order.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="view-order" data-id="${esc(order.id)}">View</button></td></tr>`);
}
function kpi(label, value, note, icon) {
    return `<div class="sf-kpi"><div class="sf-kpi-label">${label}<span class="sf-kpi-icon"><i class="bi ${icon}"></i></span></div><div class="sf-kpi-value">${value}</div><div class="sf-kpi-foot">${note}</div></div>`;
}
function renderShell() {
    const today = new Date().toLocaleDateString("en-KE", { weekday: "long", day: "numeric", month: "long", year: "numeric" });
    document.getElementById("scanflow-workspace").innerHTML = `
      <div class="sf-layout">
        <div class="sf-mobile-overlay" data-action="close-menu"></div>
        <aside class="sf-sidebar" id="sf-sidebar">
          <div class="sf-brand"><span class="sf-brand-mark"><i class="bi bi-basket2-fill"></i></span><div class="sf-brand-name">Scan<span>Flow</span><small>RETAIL OPERATIONS</small></div></div>
          <button class="sf-branch-switch" data-action="branch"><small>ACTIVE BRANCH</small><span><i class="bi bi-geo-alt me-1"></i><span id="active-branch">Nairobi Main</span><i class="bi bi-chevron-expand float-end"></i></span></button>
          <div class="sf-nav-label">Workspace</div>
          <nav class="sf-nav">${pages.slice(0, 8).map(([key, title, icon]) => `<button class="${activePage === key ? "active" : ""}" data-page="${key}"><i class="bi ${icon}"></i>${title}${key === "inventory" && lowStock().length ? `<span class="nav-count">${lowStock().length}</span>` : ""}</button>`).join("")}</nav>
          <div class="sf-nav-label">Manage</div>
          <nav class="sf-nav">${pages.slice(8).map(([key, title, icon]) => `<button class="${activePage === key ? "active" : ""}" data-page="${key}"><i class="bi ${icon}"></i>${title}</button>`).join("")}</nav>
          <div class="sf-side-bottom"><div class="sf-user"><span class="sf-avatar">GW</span><div><strong>Grace Wanjiku</strong><small>Business owner</small></div><button class="ms-auto btn btn-link btn-sm text-light" data-page="settings" aria-label="Account settings"><i class="bi bi-three-dots"></i></button></div></div>
        </aside>
        <main class="sf-main">
          <div class="sf-topbar"><button class="sf-mobile-menu" data-action="open-menu" aria-label="Open navigation"><i class="bi bi-list"></i></button><div class="sf-search"><i class="bi bi-search"></i><input id="global-search" placeholder="Search products, orders, customers..." autocomplete="off"></div><span class="sf-inline-note d-none d-lg-inline">${esc(today)}</span><div class="sf-top-actions"><button class="sf-notification" aria-label="Notifications" data-action="notifications"><i class="bi bi-bell"></i></button><button aria-label="Help center" data-action="help"><i class="bi bi-question-circle"></i></button><div class="sf-user"><span class="sf-avatar">GW</span><div><strong>Grace Wanjiku</strong><small>Owner</small></div></div></div></div>
          <div class="sf-page"><div class="sf-demo-banner"><i class="bi bi-info-circle"></i><span><strong>Demo workspace.</strong> Changes are stored in this browser only. Payments, QR issuance, device signals and inventory reconciliation are not connected to production services.</span><button class="btn-close ms-auto" data-action="dismiss-banner" aria-label="Dismiss"></button></div><div id="sf-page-content"></div></div>
        </main>
        <div class="sf-toast" id="sf-toast" role="status"></div>
        <div id="sf-modal-root"></div>
      </div>`;
    renderPage();
}
function renderPage() {
    const content = document.getElementById("sf-page-content");
    if (!content) return;
    const renderers = { overview: pageOverview, pos: pagePos, products: pageProducts, inventory: pageInventory, orders: pageOrders, payments: pagePayments, customers: pageCustomers, suppliers: pageSuppliers, employees: pageEmployees, devices: pageDevices, promotions: pagePromotions, reports: pageReports, qr: pageQr, audit: pageAudit, settings: pageSettings };
    content.innerHTML = (renderers[activePage] || pageOverview)();
    if (activePage === "qr") drawQr();
}
function pageOverview() {
    const confirmed = state.orders.filter(order => order.status === "Confirmed");
    const sales = confirmed.reduce((sum, order) => sum + Number(order.amount), 0);
    const bars = [38, 57, 48, 76, 62, 89, 68].map((height, i) => `<div class="sf-chart-col"><span class="sf-chart-bar" style="height:${height}%"></span><span>${["Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon"][i]}</span></div>`).join("");
    const products = [...state.products].sort((a, b) => b.stock - a.stock).slice(0, 4).map((product, index) => `<div class="sf-product-row"><span class="sf-product-thumb"><i class="bi ${productIcon(index)}"></i></span><span class="sf-product-info"><strong>${esc(product.name)}</strong><small>${esc(product.category)}</small></span><span class="sf-product-amount">${product.stock} units</span></div>`).join("");
    const stockItems = lowStock().slice(0, 4).map(product => `<div class="sf-stock-item"><span class="sf-product-thumb"><i class="bi bi-exclamation-triangle"></i></span><span class="sf-stock-text"><strong>${esc(product.name)}</strong><small>${product.stock} left · reorder at ${product.minimum}</small></span><button class="sf-btn sf-btn-sm" data-action="adjust-stock" data-id="${esc(product.id)}">Adjust</button></div>`).join("") || `<div class="sf-empty">All products are above reorder level.</div>`;
    return `${heading("Good morning, Grace", "Here’s what’s happening at Nairobi Main today.", `<button class="sf-btn" data-action="export-report"><i class="bi bi-download"></i>Export</button><button class="sf-btn sf-btn-primary" data-page="pos"><i class="bi bi-plus-lg"></i>New sale</button>`)}
      <div class="sf-grid sf-kpis">${kpi("Today's sales", money(sales), `<span class="sf-up"><i class="bi bi-arrow-up-right"></i> 8.4%</span> vs previous day`, "bi-currency-exchange")}${kpi("Transactions", confirmed.length, "Across 3 checkout channels", "bi-receipt")}${kpi("Inventory value", money(state.products.reduce((sum, product) => sum + product.cost * product.stock, 0)), "At recorded product cost", "bi-boxes")}${kpi("Low-stock products", lowStock().length, "Need attention or replenishment", "bi-exclamation-circle")}</div>
      <div class="sf-grid sf-overview-grid">${panel("Sales performance", "Daily sales · last 7 days", `<div class="sf-chart">${bars}</div><div class="sf-chart-legend"><i class="bi bi-square-fill text-success"></i> Sales · KSh</div>`, `<select class="form-select form-select-sm" aria-label="Date range"><option>Last 7 days</option><option>This month</option></select>`)}${panel("Best-selling products", "Units sold · this week", products, `<button class="sf-btn sf-btn-sm" data-page="products">View catalogue</button>`)}</div>
      <div class="sf-grid sf-lower-grid">${panel("Recent transactions", "Latest orders across channels", table(["Order", "Time", "Customer", "Channel", "Payment", "Total", "Status", ""], orderRows(state.orders.slice(0, 4))), `<button class="sf-btn sf-btn-sm" data-page="orders">All orders</button>`)}${panel("Reorder attention", "Stock at or below minimum", `<div class="sf-stock-list">${stockItems}</div>`, `<button class="sf-btn sf-btn-sm" data-page="inventory">Inventory</button>`)}</div>`;
}
function pagePos() {
    const matches = state.products.filter(product => `${product.name} ${product.sku} ${product.barcode}`.toLowerCase().includes(productFilter.toLowerCase()));
    const total = cart.reduce((sum, line) => sum + line.product.price * line.quantity, 0);
    return `${heading("Point of Sale", "Till 01 · Nairobi Main · Cashier: Grace Wanjiku", `<span class="sf-status">Till open</span><button class="sf-btn" data-action="suspend-sale"><i class="bi bi-pause-circle"></i>Suspend sale</button>`)}
      <div class="sf-pos-layout"><section class="sf-panel"><div class="sf-panel-head"><div><h2>Product catalogue</h2><small>Scan a barcode or search by name or SKU.</small></div></div><div class="sf-toolbar"><input class="sf-filter" id="pos-search" value="${esc(productFilter)}" placeholder="Search or scan barcode" autofocus><button class="sf-btn" data-action="clear-pos-search"><i class="bi bi-x-lg"></i>Clear</button></div><div class="sf-pos-products" id="pos-products">${matches.map((product, index) => `<button class="sf-pos-product" data-action="add-cart" data-id="${esc(product.id)}"><i class="bi ${productIcon(index)}"></i><strong>${esc(product.name)}</strong><small>${esc(product.sku)} · ${money(product.price)}</small></button>`).join("")}</div></section>
      <aside class="sf-panel"><div class="sf-panel-head"><div><h2>Current sale</h2><small>New transaction</small></div><button class="sf-btn sf-btn-sm sf-btn-danger" data-action="clear-cart" aria-label="Clear sale"><i class="bi bi-trash"></i></button></div>${cart.length ? cart.map((line, index) => `<div class="sf-cart-line"><span class="sf-product-thumb"><i class="bi ${productIcon(index)}"></i></span><span class="sf-product-info"><strong>${esc(line.product.name)}</strong><small>${money(line.product.price)} each</small></span><span class="sf-qty"><button data-action="cart-minus" data-id="${esc(line.product.id)}">−</button><span>${line.quantity}</span><button data-action="cart-plus" data-id="${esc(line.product.id)}">+</button></span><strong class="small">${money(line.quantity * line.product.price)}</strong></div>`).join("") : `<div class="sf-empty"><i class="bi bi-basket"></i>Scan or select products to start a sale.</div>`}<div class="sf-totals"><div class="sf-total-row"><span>Subtotal</span><strong>${money(total)}</strong></div><div class="sf-total-row"><span>Tax</span><span>Calculated at checkout</span></div><div class="sf-total-row grand"><span>Total</span><span>${money(total)}</span></div><button class="sf-btn sf-btn-primary w-100 mt-2" data-action="checkout-demo" ${cart.length ? "" : "disabled"}><i class="bi bi-credit-card"></i>Proceed to payment</button><div class="sf-inline-note mt-2 text-center">Demo only · no payment will be charged</div></div></aside></div>`;
}
function pageProducts() {
    return `${heading("Products & Catalogue", `${state.products.length} products · Shared catalogue for cashier, phone and trolley shopping.`, `<button class="sf-btn" data-action="import-products"><i class="bi bi-upload"></i>Import CSV</button><button class="sf-btn sf-btn-primary" data-action="new-product"><i class="bi bi-plus-lg"></i>Add product</button>`)}<section class="sf-panel"><div class="sf-toolbar"><input class="sf-filter" data-filter="products" placeholder="Search product, SKU or barcode"><select><option>All categories</option><option>Groceries</option><option>Beverages</option><option>Dairy</option><option>Bakery</option></select><button class="sf-btn" data-action="export-products"><i class="bi bi-download"></i>Export</button></div><div id="products-table">${productTable()}</div></section><input id="csv-file" type="file" accept=".csv,text/csv" hidden>`;
}
function pageInventory() {
    const rows = state.products.map(product => `<tr><td><strong>${esc(product.name)}</strong><small class="d-block text-muted">${esc(product.sku)}</small></td><td>${esc(product.category)}</td><td>${product.stock}</td><td>${product.minimum}</td><td><div class="sf-progress"><span style="width:${Math.min(100, Math.max(4, product.stock / Math.max(product.minimum * 2, 1) * 100))}%"></span></div></td><td>${status(product.stock <= product.minimum ? (product.stock === 0 ? "Out of stock" : "Low stock") : "In stock")}</td><td><button class="sf-btn sf-btn-sm" data-action="adjust-stock" data-id="${esc(product.id)}">Adjust</button></td></tr>`);
    return `${heading("Inventory", "Branch stock, replenishment and movement history.", `<button class="sf-btn" data-action="new-purchase"><i class="bi bi-truck"></i>Receive stock</button><button class="sf-btn sf-btn-primary" data-action="stocktake"><i class="bi bi-clipboard-check"></i>Start stocktake</button>`)}<div class="sf-grid sf-kpis">${kpi("Stock keeping units", state.products.length, "Active catalogue items", "bi-boxes")}${kpi("Low stock", lowStock().length, "At or below reorder point", "bi-exclamation-circle")}${kpi("On-hand units", state.products.reduce((sum, product) => sum + Number(product.stock), 0), "Across this branch", "bi-stack")}${kpi("Open purchase orders", state.purchaseOrders.filter(order => order.status !== "Received").length, "Awaiting delivery", "bi-truck")}</div><section class="sf-panel"><div class="sf-toolbar"><input class="sf-filter" data-filter="inventory" placeholder="Search inventory"><select><option>All stock statuses</option><option>Low stock</option><option>In stock</option></select><span class="sf-inline-note ms-auto">Branch: Nairobi Main</span></div><div id="inventory-table">${table(["Product", "Category", "On hand", "Reorder at", "Stock level", "Status", ""], rows)}</div></section><section class="sf-panel mt-3">${panel("Recent stock movements", "Stock adjustments and receipts are recorded locally in this demo.", table(["Time", "Product", "Change", "Reason", "Actor"], state.movements.slice(0, 8).map(movement => `<tr><td>${esc(movement.time)}</td><td><strong>${esc(movement.product)}</strong></td><td>${movement.delta > 0 ? "+" : ""}${movement.delta}</td><td>${esc(movement.reason)}</td><td>${esc(movement.actor)}</td></tr>`)), "")}</section>`;
}
function pageOrders() {
    return `${heading("Orders & Receipts", "Search transactions and review checkout status across channels.", `<button class="sf-btn" data-action="export-orders"><i class="bi bi-download"></i>Export</button>`)}<section class="sf-panel"><div class="sf-toolbar"><input class="sf-filter" data-filter="orders" placeholder="Search order, customer or reference"><select><option>All channels</option><option>Cashier</option><option>Phone</option><option>SmartTrolley</option></select><select><option>All statuses</option><option>Confirmed</option><option>Pending</option><option>Demo only</option></select></div><div id="orders-table">${table(["Order", "Time", "Customer", "Channel", "Payment", "Total", "Status", ""], orderRows())}</div></section>`;
}
function pagePayments() {
    const rows = state.orders.map(order => `<tr><td><strong>${esc(order.number)}</strong></td><td>${esc(order.time)}</td><td>${esc(order.method)}</td><td>${money(order.amount)}</td><td>${status(order.status === "Confirmed" ? "Demo confirmed" : "Pending")}</td><td>${esc(order.channel.replaceAll("_", " "))}</td><td><button class="sf-btn sf-btn-sm" data-action="view-order" data-id="${esc(order.id)}">Details</button></td></tr>`);
    return `${heading("Payments & Finance", "Payment attempts, reconciliation and settlement overview.", `<button class="sf-btn" data-action="export-payments"><i class="bi bi-download"></i>Export</button>`)}<div class="sf-alert mb-3"><i class="bi bi-exclamation-triangle me-1"></i> Payment values in this workspace are sample data. No provider callback or settlement has been verified.</div><div class="sf-grid sf-kpis">${kpi("Demo payment volume", money(state.orders.reduce((sum, order) => sum + order.amount, 0)), "Current sample orders", "bi-cash-stack")}${kpi("Pending attempts", state.orders.filter(order => order.status === "Pending").length, "Require provider reconciliation", "bi-hourglass-split")}${kpi("M-Pesa", state.orders.filter(order => order.method === "M-Pesa").length, "Sample payment records", "bi-phone")}${kpi("Cash", state.orders.filter(order => order.method === "Cash").length, "Sample payment records", "bi-wallet2")}</div><section class="sf-panel">${panel("Payment activity", "Transaction status and payment channel", table(["Order", "Time", "Method", "Amount", "Status", "Checkout channel", ""], rows), "")}</section>`;
}
function pageCustomers() {
    const rows = state.customers.map(customer => `<tr><td><strong>${esc(customer.name)}</strong></td><td>${esc(customer.phone)}</td><td>${esc(customer.email)}</td><td>${customer.orders}</td><td>${money(customer.spend)}</td><td>${status("Active")}</td><td><button class="sf-btn sf-btn-sm" data-action="customer-detail" data-name="${esc(customer.name)}">View</button></td></tr>`);
    return `${heading("Customers & Loyalty", `${state.customers.length} customer profiles · Tenant-scoped in production.`, `<button class="sf-btn" data-action="export-customers"><i class="bi bi-download"></i>Export</button><button class="sf-btn sf-btn-primary" data-action="new-customer"><i class="bi bi-person-plus"></i>Add customer</button>`)}<div class="sf-grid sf-kpis">${kpi("Customer profiles", state.customers.length, "Registered in this demo", "bi-people")}${kpi("Loyalty members", Math.max(0, state.customers.length - 1), "Eligible accounts", "bi-star")}${kpi("Repeat purchase rate", "64%", "Illustrative sample metric", "bi-arrow-repeat")}${kpi("Average lifetime spend", money(state.customers.length ? state.customers.reduce((sum, customer) => sum + customer.spend, 0) / state.customers.length : 0), "Illustrative sample metric", "bi-currency-exchange")}</div><section class="sf-panel"><div class="sf-toolbar"><input class="sf-filter" data-filter="customers" placeholder="Search name or phone"><select><option>All customer types</option><option>Loyalty members</option><option>Guest</option></select></div><div id="customers-table">${table(["Customer", "Phone", "Email", "Orders", "Lifetime spend", "Status", ""], rows)}</div></section>`;
}
function pageSuppliers() {
    const rows = state.suppliers.map((supplier, index) => `<tr><td><strong>${esc(supplier.name)}</strong></td><td>${esc(supplier.contact)}</td><td>${esc(supplier.phone)}</td><td>${money(supplier.balance)}</td><td>${status(supplier.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="supplier-detail" data-index="${index}">View</button></td></tr>`);
    const poRows = state.purchaseOrders.map(order => `<tr><td><strong>${esc(order.number)}</strong></td><td>${esc(order.supplier)}</td><td>${esc(order.product)}</td><td>${order.quantity}</td><td>${money(order.total)}</td><td>${status(order.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="receive-po" data-id="${esc(order.id)}">Receive</button></td></tr>`);
    return `${heading("Suppliers & Purchasing", "Supplier directory, purchase orders and delivery records.", `<button class="sf-btn" data-action="new-supplier"><i class="bi bi-person-plus"></i>Add supplier</button><button class="sf-btn sf-btn-primary" data-action="new-purchase"><i class="bi bi-plus-lg"></i>Create purchase order</button>`)}<section class="sf-panel mb-3">${panel("Suppliers", "Business supplier accounts", table(["Supplier", "Contact", "Phone", "Outstanding", "Status", ""], rows), "")}</section><section class="sf-panel">${panel("Purchase orders", "Open and received orders", table(["PO number", "Supplier", "Product", "Qty", "Total", "Status", ""], poRows), "")}</section>`;
}
function pageEmployees() {
    const rows = state.employees.map(employee => `<tr><td><strong>${esc(employee.name)}</strong></td><td>${esc(employee.email)}</td><td>${esc(employee.role)}</td><td>${esc(employee.branch)}</td><td>${status(employee.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="toggle-employee" data-name="${esc(employee.name)}">Change status</button></td></tr>`);
    return `${heading("Employees & Access", "Staff roles and branch assignments. Production permissions must be enforced by the API.", `<button class="sf-btn sf-btn-primary" data-action="new-employee"><i class="bi bi-person-plus"></i>Invite staff</button>`)}<div class="sf-alert mb-3"><i class="bi bi-shield-lock me-1"></i>Role labels in this demo are informational only; they do not grant or enforce backend permissions.</div><section class="sf-panel">${table(["Employee", "Email", "Role", "Branch access", "Status", ""], rows)}</section>`;
}
function pageDevices() {
    const rows = state.devices.map((device, index) => `<tr><td><strong>${esc(device.code)}</strong></td><td>${esc(device.type)}</td><td>${esc(device.branch)}</td><td>${status(device.status)}</td><td>${esc(device.lastSeen)}</td><td><button class="sf-btn sf-btn-sm" data-action="toggle-device" data-index="${index}">Simulate status</button></td></tr>`);
    return `${heading("Devices & SmartTrolleys", "Registered POS, trolley and exit devices by branch.", `<button class="sf-btn" data-action="new-device"><i class="bi bi-plus-lg"></i>Register device</button><button class="sf-btn sf-btn-primary" data-action="pair-device"><i class="bi bi-qr-code-scan"></i>Pair device</button>`)}<div class="sf-alert mb-3"><i class="bi bi-info-circle me-1"></i>Device health and pairing are local simulations. No hardware is authenticated or connected.</div><section class="sf-panel">${table(["Device", "Type", "Branch", "Health", "Last seen", ""], rows)}</section><div class="sf-grid sf-page-grid mt-3">${panel("Fleet health", "Demo device availability", `<div class="sf-kpi-value">${state.devices.filter(device => device.status === "Online").length} / ${state.devices.length}</div><div class="sf-kpi-foot">devices reporting online</div>`, "")}${panel("Exit security", "QR pass and detection status", `<div class="sf-settings-row"><div><strong>Exit verification</strong><small>Payment confirmation is required before exit in production.</small></div>${status("Staff review")}</div><div class="sf-settings-row"><div><strong>RFID / camera detection</strong><small>Integrations not connected.</small></div>${status("Unavailable")}</div>`, "")}</div>`;
}
function pagePromotions() {
    const rows = state.promotions.map(promotion => `<tr><td><strong>${esc(promotion.name)}</strong></td><td>${esc(promotion.type)}</td><td>${esc(promotion.value)}</td><td>${esc(promotion.dates)}</td><td>${status(promotion.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="toggle-promotion" data-name="${esc(promotion.name)}">Toggle</button></td></tr>`);
    return `${heading("Promotions", "Manage discounts and product offers by branch and validity period.", `<button class="sf-btn sf-btn-primary" data-action="new-promotion"><i class="bi bi-plus-lg"></i>Create promotion</button>`)}<div class="sf-alert mb-3">Promotions shown here are demo records. Server-side eligibility and redemption limits are not connected.</div><section class="sf-panel">${table(["Promotion", "Type", "Offer", "Validity", "Status", ""], rows)}</section>`;
}
function pageReports() {
    const sales = state.orders.filter(order => order.status === "Confirmed").reduce((sum, order) => sum + order.amount, 0);
    return `${heading("Reports & Analytics", "Operational summaries from sample workspace records.", `<button class="sf-btn" data-action="export-report"><i class="bi bi-download"></i>Download CSV</button><select class="form-select form-select-sm"><option>Today</option><option>This week</option><option>This month</option></select>`)}<div class="sf-grid sf-kpis">${kpi("Recorded sales", money(sales), "Demo confirmed orders", "bi-currency-exchange")}${kpi("Average order", money(state.orders.length ? sales / state.orders.length : 0), "Sample calculation", "bi-receipt")}${kpi("Gross margin estimate", money(state.products.reduce((sum, product) => sum + (product.price - product.cost) * Math.max(0, product.stock), 0)), "On current stock, before expenses", "bi-graph-up-arrow")}${kpi("Stock units", state.products.reduce((sum, product) => sum + Number(product.stock), 0), "Across selected branch", "bi-boxes")}</div><div class="sf-grid sf-page-grid">${panel("Sales by channel", "Illustrative mix from current sample orders", `<div class="sf-settings-row"><div><strong>Cashier POS</strong><small>Traditional checkout</small></div><strong>50%</strong></div><div class="sf-settings-row"><div><strong>Phone scan</strong><small>Customer self-scan</small></div><strong>25%</strong></div><div class="sf-settings-row"><div><strong>SmartTrolley</strong><small>Trolley checkout</small></div><strong>25%</strong></div>`, "")}${panel("Inventory risk", "Products requiring replenishment", `<div class="sf-stock-list">${lowStock().map(product => `<div class="sf-stock-item"><span class="sf-stock-text"><strong>${esc(product.name)}</strong><small>${product.stock} units remaining</small></span>${status("Low stock")}</div>`).join("") || `<div class="sf-empty">No low-stock products.</div>`}</div>`, "")}</div>`;
}
function pageQr() {
    const current = state.qrCodes[0];
    return `${heading("QR Management", "Business and branch QR identity. Demo tokens are stored only in this browser.", `<button class="sf-btn sf-btn-primary" data-action="generate-qr"><i class="bi bi-qr-code"></i>Generate branch QR</button>`)}<div class="sf-alert mb-3"><i class="bi bi-shield-lock me-1"></i>Production QR tokens must be issued, hashed, scoped, revocable and resolved by the backend. This local demo token cannot start a real shopping session.</div><div class="sf-qr-layout"><section class="sf-panel"><div class="sf-panel-head"><div><h2>Branch entry QR</h2><small>Nairobi Main · Long-lived identity</small></div>${status("Demo")}</div><div class="sf-qr-canvas"><canvas id="qr-canvas" width="180" height="180"></canvas></div><div class="sf-code mt-3" id="qr-token">${current ? esc(current.token) : "No demo QR generated yet."}</div><div class="sf-inline-note mt-2">${current ? `Generated ${esc(current.created)}` : "Generate a sample token to preview the QR."}</div><button class="sf-btn w-100 mt-3" data-action="download-qr" ${current ? "" : "disabled"}><i class="bi bi-download"></i>Download PNG</button></section><section class="sf-panel">${panel("QR directory", "Branch identity codes", table(["Name", "Purpose", "Created", "Status", ""], state.qrCodes.map((qr, index) => `<tr><td><strong>${esc(qr.name)}</strong></td><td>${esc(qr.purpose)}</td><td>${esc(qr.created)}</td><td>${status(qr.status)}</td><td><button class="sf-btn sf-btn-sm" data-action="select-qr" data-index="${index}">Preview</button></td></tr>`), "No QR codes created in this demo."), "")}</section></div>`;
}
function pageAudit() {
    return `${heading("Security & Audit", "Recent demo actions. Production audit records should be immutable and server-generated.", `<button class="sf-btn" data-action="export-audit"><i class="bi bi-download"></i>Export log</button>`)}<div class="sf-alert mb-3">This browser-only log is not a security or compliance audit trail.</div><section class="sf-panel">${table(["Time", "Action", "Actor", "Reference"], state.audit.map(entry => `<tr><td>${esc(entry.time)}</td><td><strong>${esc(entry.action)}</strong></td><td>${esc(entry.actor)}</td><td>${esc(entry.detail)}</td></tr>`))}</section>`;
}
function pageSettings() {
    const settings = [["phone", "Phone scanning", "Allow customers to scan products with the ScanFlow app."], ["trolley", "SmartTrolley scanning", "Allow trolley devices to submit scan events."], ["cashier", "Cashier POS", "Enable traditional staff checkout."], ["requireExit", "Require exit verification", "Ask staff to verify eligible self-scan orders."], ["guest", "Allow guest checkout", "Allow a customer session without a registered account."]];
    return `${heading("Business Settings", "Checkout methods and branch policies for Nairobi Main.", `<button class="sf-btn sf-btn-primary" data-action="save-settings"><i class="bi bi-check2"></i>Save settings</button>`)}<div class="sf-grid sf-page-grid"><section class="sf-panel">${panel("Checkout configuration", "Preview of branch settings", settings.map(([key, title, description]) => `<div class="sf-settings-row"><div><strong>${title}</strong><small>${description}</small></div><input class="sf-switch" type="checkbox" data-setting="${key}" ${state.settings[key] ? "checked" : ""}></div>`).join(""), "")}</section><section class="sf-panel">${panel("Branch profile", "Retail location details", `<div class="sf-field mb-3"><label>Business</label><input value="ScanFlow Demo Market" readonly></div><div class="sf-field mb-3"><label>Branch</label><select>${state.branches.map(branch => `<option>${esc(branch)}</option>`).join("")}</select></div><div class="sf-field mb-3"><label>Currency</label><input value="KES · Kenyan Shilling" readonly></div><div class="sf-field"><label>Timezone</label><input value="Africa/Nairobi" readonly></div>`, "")}</section></div>`;
}

function go(page) { activePage = page; renderShell(); document.getElementById("sf-sidebar")?.classList.remove("open"); document.querySelector(".sf-mobile-overlay")?.classList.remove("show"); }
function toast(message) { const element = document.getElementById("sf-toast"); if (!element) return; element.textContent = message; element.classList.add("show"); clearTimeout(toast.timer); toast.timer = setTimeout(() => element.classList.remove("show"), 2400); }
function recordAudit(action, detail) { state.audit.unshift({ action, actor: "Grace Wanjiku", detail, time: new Date().toLocaleTimeString("en-KE", { hour: "2-digit", minute: "2-digit" }) }); state.audit = state.audit.slice(0, 100); }
function addToCart(productId) {
    const product = state.products.find(item => item.id === productId); if (!product) return;
    const line = cart.find(item => item.product.id === productId);
    if ((line?.quantity || 0) >= Number(product.stock)) return toast("Quantity exceeds demo on-hand stock.");
    if (line) line.quantity++; else cart.push({ product, quantity: 1 });
    renderPage();
}
function cartChange(productId, delta) {
    const line = cart.find(item => item.product.id === productId); if (!line) return;
    line.quantity += delta;
    if (line.quantity <= 0) cart = cart.filter(item => item.product.id !== productId);
    else if (line.quantity > line.product.stock) { line.quantity = line.product.stock; toast("Quantity limited to demo stock."); }
    renderPage();
}
function modal(title, content) {
    const root = document.getElementById("sf-modal-root");
    root.innerHTML = `<div class="sf-modal-backdrop" data-action="backdrop-close"><section class="sf-modal" role="dialog" aria-modal="true"><div class="sf-modal-head"><h2>${title}</h2><button data-action="close-modal" aria-label="Close"><i class="bi bi-x-lg"></i></button></div><div class="sf-modal-body">${content}</div></section></div>`;
}
function formModal(kind, values = {}) {
    const forms = {
        product: ["Add product", `<div class="sf-form-grid"><div class="sf-field full"><label>Product name</label><input name="name" required value="${esc(values.name || "")}"></div><div class="sf-field"><label>SKU</label><input name="sku" required value="${esc(values.sku || "")}"></div><div class="sf-field"><label>Barcode</label><input name="barcode" value="${esc(values.barcode || "")}"></div><div class="sf-field"><label>Category</label><input name="category" value="${esc(values.category || "Groceries")}"></div><div class="sf-field"><label>Selling price (KES)</label><input name="price" type="number" min="0" step="0.01" required value="${esc(values.price ?? "")}"></div><div class="sf-field"><label>Unit cost (KES)</label><input name="cost" type="number" min="0" step="0.01" value="${esc(values.cost ?? "")}"></div><div class="sf-field"><label>On-hand units</label><input name="stock" type="number" min="0" step="1" value="${esc(values.stock ?? 0)}"></div><div class="sf-field"><label>Reorder point</label><input name="minimum" type="number" min="0" step="1" value="${esc(values.minimum ?? 5)}"></div></div>`],
        customer: ["Add customer", `<div class="sf-form-grid"><div class="sf-field full"><label>Full name</label><input name="name" required></div><div class="sf-field"><label>Phone</label><input name="phone" required></div><div class="sf-field"><label>Email</label><input name="email" type="email"></div></div>`],
        supplier: ["Add supplier", `<div class="sf-form-grid"><div class="sf-field full"><label>Supplier name</label><input name="name" required></div><div class="sf-field"><label>Contact person</label><input name="contact"></div><div class="sf-field"><label>Phone</label><input name="phone"></div></div>`],
        employee: ["Invite employee", `<div class="sf-alert mb-3">This demo invitation does not create an account or assign server permissions.</div><div class="sf-form-grid"><div class="sf-field full"><label>Full name</label><input name="name" required></div><div class="sf-field"><label>Email</label><input name="email" type="email" required></div><div class="sf-field"><label>Role</label><select name="role"><option>Cashier</option><option>Branch Manager</option><option>Inventory Officer</option><option>Finance Officer</option><option>Exit Attendant</option><option>Auditor</option></select></div><div class="sf-field full"><label>Branch</label><select name="branch">${state.branches.map(branch => `<option>${esc(branch)}</option>`).join("")}</select></div></div>`],
        promotion: ["Create promotion", `<div class="sf-alert mb-3">Promotion rules are saved locally and are not applied to checkout totals.</div><div class="sf-form-grid"><div class="sf-field full"><label>Promotion name</label><input name="name" required></div><div class="sf-field"><label>Discount type</label><select name="type"><option>Percentage off</option><option>Fixed amount</option><option>Bundle</option></select></div><div class="sf-field"><label>Value</label><input name="value" required placeholder="10% or KSh 50"></div><div class="sf-field"><label>Start date</label><input name="start" type="date"></div><div class="sf-field"><label>End date</label><input name="end" type="date"></div></div>`],
        adjustment: ["Adjust stock", `<div class="sf-form-grid"><div class="sf-field full"><label>Product</label><select name="productId">${state.products.map(product => `<option value="${esc(product.id)}">${esc(product.name)} · ${product.stock} on hand</option>`).join("")}</select></div><div class="sf-field"><label>Quantity change (+/-)</label><input name="delta" type="number" required></div><div class="sf-field"><label>Reason</label><select name="reason"><option>Stock count</option><option>Damaged goods</option><option>Goods received</option><option>Correction</option></select></div></div>`],
        purchase: ["Create purchase order", `<div class="sf-form-grid"><div class="sf-field"><label>Supplier</label><select name="supplier">${state.suppliers.map(supplier => `<option>${esc(supplier.name)}</option>`).join("")}</select></div><div class="sf-field"><label>Product</label><select name="productId">${state.products.map(product => `<option value="${esc(product.id)}">${esc(product.name)}</option>`).join("")}</select></div><div class="sf-field"><label>Quantity</label><input name="quantity" type="number" min="1" required value="12"></div></div>`]
    };
    const [title, fields] = forms[kind];
    modal(title, `<form data-form="${kind}" ${values.id ? `data-id="${esc(values.id)}"` : ""}>${fields}<div class="sf-modal-actions"><button type="button" class="sf-btn" data-action="close-modal">Cancel</button><button class="sf-btn sf-btn-primary" type="submit">${kind === "product" && values.id ? "Save changes" : "Save demo record"}</button></div></form>`);
}
function checkoutModal() {
    const total = cart.reduce((sum, line) => sum + line.product.price * line.quantity, 0);
    modal("Complete demo sale", `<div class="sf-alert mb-3">This is a local simulation. It will not charge a payment method, create a provider-confirmed order or issue an exit pass.</div><div class="sf-total-row grand mb-3"><span>Total</span><span>${money(total)}</span></div><form data-form="checkout"><div class="sf-field"><label>Payment method (demo label only)</label><select name="method"><option>M-Pesa (not connected)</option><option>Cash (not recorded to a till)</option><option>Card (not connected)</option></select></div><div class="sf-modal-actions"><button type="button" class="sf-btn" data-action="close-modal">Cancel</button><button class="sf-btn sf-btn-primary" type="submit">Create demo order</button></div></form>`);
}
function submitForm(form) {
    const values = Object.fromEntries(new FormData(form).entries());
    const kind = form.dataset.form;
    if (kind === "product") {
        const existing = form.dataset.id && state.products.find(product => product.id === form.dataset.id);
        const item = { id: existing?.id || id("p"), name: values.name.trim(), sku: values.sku.trim(), barcode: values.barcode.trim(), category: values.category.trim() || "Other", price: Number(values.price), cost: Number(values.cost || 0), stock: Number(values.stock || 0), minimum: Number(values.minimum || 0) };
        if (existing) Object.assign(existing, item); else state.products.unshift(item);
        recordAudit(existing ? "Product updated" : "Product created", item.sku);
    } else if (kind === "customer") state.customers.unshift({ ...values, orders: 0, spend: 0 });
    else if (kind === "supplier") state.suppliers.unshift({ ...values, balance: 0, status: "Active" });
    else if (kind === "employee") state.employees.unshift({ ...values, status: "Invited" });
    else if (kind === "promotion") state.promotions.unshift({ name: values.name, type: values.type, value: values.value, dates: `${values.start || "Now"} - ${values.end || "No end"}`, status: "Scheduled" });
    else if (kind === "adjustment") {
        const product = state.products.find(item => item.id === values.productId); const delta = Number(values.delta);
        if (!product || product.stock + delta < 0) return toast("Adjustment cannot make stock negative.");
        product.stock += delta; state.movements.unshift({ product: product.name, delta, reason: values.reason, actor: "Grace Wanjiku", time: new Date().toLocaleTimeString("en-KE", { hour: "2-digit", minute: "2-digit" }) });
        recordAudit("Stock adjusted", `${product.name}: ${delta > 0 ? "+" : ""}${delta}`);
    } else if (kind === "purchase") {
        const product = state.products.find(item => item.id === values.productId); const quantity = Number(values.quantity);
        if (product && quantity > 0) state.purchaseOrders.unshift({ id: id("po"), number: `PO-${Date.now().toString().slice(-6)}`, supplier: values.supplier, product: product.name, productId: product.id, quantity, total: quantity * product.cost, status: "Draft" });
    } else if (kind === "checkout") {
        if (!cart.length) return toast("Add items before checkout.");
        const total = cart.reduce((sum, line) => sum + line.product.price * line.quantity, 0);
        state.orders.unshift({ id: id("o"), number: `DEMO-${Date.now().toString().slice(-6)}`, customer: "Walk-in customer", channel: "CASHIER", method: values.method, amount: total, status: "Demo only", time: new Date().toLocaleTimeString("en-KE", { hour: "2-digit", minute: "2-digit" }) });
        recordAudit("Demo sale created", `DEMO · ${money(total)} · stock unchanged`); cart = [];
    }
    saveState(); document.getElementById("sf-modal-root").innerHTML = ""; renderShell(); toast("Saved in this browser demo.");
}
function adjustStock(productId) { formModal("adjustment"); const select = document.querySelector('[data-form="adjustment"] [name="productId"]'); if (select && productId) select.value = productId; }
function downloadCsv(filename, rows) {
    const content = rows.map(row => row.map(value => `"${String(value ?? "").replaceAll('"', '""')}"`).join(",")).join("\n");
    const link = document.createElement("a"); link.href = URL.createObjectURL(new Blob([content], { type: "text/csv" })); link.download = filename; link.click(); URL.revokeObjectURL(link.href);
}
function drawQr() {
    const canvas = document.getElementById("qr-canvas"); const record = state.qrCodes[0];
    if (!canvas || !record || !window.QRCode) return;
    window.QRCode.toCanvas(canvas, record.token, { width: 170, margin: 1, color: { dark: "#163d32", light: "#ffffff" } }, error => { if (error) console.warn("QR preview unavailable", error); });
}
function makeQr() {
    const bytes = new Uint8Array(24); crypto.getRandomValues(bytes);
    const token = `https://scanflow.local/q/${Array.from(bytes, byte => byte.toString(16).padStart(2, "0")).join("")}`;
    const record = { name: "Nairobi Main", purpose: "Branch entry", token, status: "Demo", created: new Date().toLocaleString("en-KE") };
    state.qrCodes.unshift(record); saveState(); renderPage(); recordAudit("Demo QR generated", record.name); toast("Demo QR generated. Not registered with a backend.");
}
function filterPage(query) {
    const text = query.toLowerCase();
    if (activePage === "products" || activePage === "inventory") {
        const list = state.products.filter(product => `${product.name} ${product.sku} ${product.barcode} ${product.category}`.toLowerCase().includes(text));
        const target = document.getElementById(activePage === "products" ? "products-table" : "inventory-table");
        if (target) target.innerHTML = activePage === "products" ? productTable(list) : pageInventoryTable(list);
    } else if (activePage === "orders") {
        const list = state.orders.filter(order => `${order.number} ${order.customer} ${order.method} ${order.channel}`.toLowerCase().includes(text));
        const target = document.getElementById("orders-table"); if (target) target.innerHTML = table(["Order", "Time", "Customer", "Channel", "Payment", "Total", "Status", ""], orderRows(list));
    } else if (activePage === "customers") {
        const list = state.customers.filter(customer => `${customer.name} ${customer.phone} ${customer.email}`.toLowerCase().includes(text));
        const target = document.getElementById("customers-table"); if (target) target.innerHTML = table(["Customer", "Phone", "Email", "Orders", "Lifetime spend", "Status", ""], list.map(customer => `<tr><td><strong>${esc(customer.name)}</strong></td><td>${esc(customer.phone)}</td><td>${esc(customer.email)}</td><td>${customer.orders}</td><td>${money(customer.spend)}</td><td>${status("Active")}</td><td>—</td></tr>`));
    } else if (activePage === "pos") { productFilter = query; const target = document.getElementById("pos-products"); if (target) target.innerHTML = state.products.filter(product => `${product.name} ${product.sku} ${product.barcode}`.toLowerCase().includes(text)).map((product, index) => `<button class="sf-pos-product" data-action="add-cart" data-id="${esc(product.id)}"><i class="bi ${productIcon(index)}"></i><strong>${esc(product.name)}</strong><small>${esc(product.sku)} · ${money(product.price)}</small></button>`).join(""); }
}
function pageInventoryTable(products) {
    return table(["Product", "Category", "On hand", "Reorder at", "Stock level", "Status", ""], products.map(product => `<tr><td><strong>${esc(product.name)}</strong><small class="d-block text-muted">${esc(product.sku)}</small></td><td>${esc(product.category)}</td><td>${product.stock}</td><td>${product.minimum}</td><td><div class="sf-progress"><span style="width:${Math.min(100, Math.max(4, product.stock / Math.max(product.minimum * 2, 1) * 100))}%"></span></div></td><td>${status(product.stock <= product.minimum ? (product.stock === 0 ? "Out of stock" : "Low stock") : "In stock")}</td><td><button class="sf-btn sf-btn-sm" data-action="adjust-stock" data-id="${esc(product.id)}">Adjust</button></td></tr>`));
}
function handleAction(button, clickEvent) {
    const action = button.dataset.action; const productId = button.dataset.id;
    if (button.dataset.page) return go(button.dataset.page);
    if (action === "open-menu") { document.getElementById("sf-sidebar").classList.add("open"); document.querySelector(".sf-mobile-overlay").classList.add("show"); }
    else if (action === "close-menu") { document.getElementById("sf-sidebar").classList.remove("open"); document.querySelector(".sf-mobile-overlay").classList.remove("show"); }
    else if (action === "close-modal" || action === "backdrop-close" && button === clickEvent.target) document.getElementById("sf-modal-root").innerHTML = "";
    else if (action === "dismiss-banner") button.closest(".sf-demo-banner").remove();
    else if (action === "notifications") toast("No new notifications in this demo.");
    else if (action === "help") toast("Help center is not connected in this demo.");
    else if (action === "branch") modal("Select branch", `<div class="sf-nav">${state.branches.map(branch => `<button class="sf-btn w-100 justify-content-start" data-action="select-branch" data-branch="${esc(branch)}"><i class="bi bi-geo-alt"></i>${esc(branch)}</button>`).join("")}<button class="sf-btn w-100 justify-content-start" data-action="add-branch"><i class="bi bi-plus-lg"></i>Add branch</button></div>`);
    else if (action === "select-branch") { document.getElementById("active-branch").textContent = button.dataset.branch; document.getElementById("sf-modal-root").innerHTML = ""; toast(`Switched to ${button.dataset.branch} demo view.`); }
    else if (action === "add-branch") { const name = prompt("Branch name"); if (name?.trim()) { state.branches.push(name.trim()); saveState(); document.getElementById("sf-modal-root").innerHTML = ""; toast("Branch added to this browser demo."); } }
    else if (action === "new-product") formModal("product");
    else if (action === "edit-product") { const product = state.products.find(item => item.id === productId); if (product) formModal("product", product); }
    else if (action === "new-customer") formModal("customer");
    else if (action === "new-supplier") formModal("supplier");
    else if (action === "new-employee") formModal("employee");
    else if (action === "new-promotion") formModal("promotion");
    else if (action === "adjust-stock") adjustStock(productId);
    else if (action === "new-purchase") formModal("purchase");
    else if (action === "add-cart") addToCart(productId);
    else if (action === "cart-plus") cartChange(productId, 1);
    else if (action === "cart-minus") cartChange(productId, -1);
    else if (action === "clear-cart") { cart = []; renderPage(); }
    else if (action === "clear-pos-search") { productFilter = ""; renderPage(); }
    else if (action === "checkout-demo") checkoutModal();
    else if (action === "suspend-sale") toast("Suspended sales require server storage; not available in this demo.");
    else if (action === "generate-qr") makeQr();
    else if (action === "select-qr") { state.qrCodes.unshift(state.qrCodes.splice(Number(button.dataset.index), 1)[0]); saveState(); renderPage(); }
    else if (action === "download-qr") { const canvas = document.getElementById("qr-canvas"); if (canvas) { const link = document.createElement("a"); link.download = "scanflow-branch-qr-demo.png"; link.href = canvas.toDataURL("image/png"); link.click(); } }
    else if (action === "save-settings") { document.querySelectorAll("[data-setting]").forEach(input => state.settings[input.dataset.setting] = input.checked); saveState(); toast("Branch settings saved in this browser demo."); }
    else if (action === "toggle-device") { const device = state.devices[Number(button.dataset.index)]; device.status = device.status === "Online" ? "Offline" : "Online"; device.lastSeen = "Just now (simulated)"; saveState(); renderPage(); }
    else if (action === "toggle-employee") { const employee = state.employees.find(item => item.name === button.dataset.name); if (employee) employee.status = employee.status === "Active" ? "Suspended" : "Active"; saveState(); renderPage(); }
    else if (action === "toggle-promotion") { const promo = state.promotions.find(item => item.name === button.dataset.name); if (promo) promo.status = promo.status === "Active" ? "Paused" : "Active"; saveState(); renderPage(); }
    else if (action === "receive-po") { const order = state.purchaseOrders.find(item => item.id === productId); if (order && order.status !== "Received") { const product = state.products.find(item => item.id === order.productId); if (product) { product.stock += order.quantity; state.movements.unshift({ product: product.name, delta: order.quantity, reason: `Received ${order.number}`, actor: "Grace Wanjiku", time: new Date().toLocaleTimeString("en-KE", { hour: "2-digit", minute: "2-digit" }) }); } order.status = "Received"; saveState(); renderPage(); toast("Stock receipt simulated locally."); } }
    else if (action === "stocktake") modal("Start stocktake", `<p class="sf-inline-note">This demo can record individual stock adjustments. A multi-user stocktake workflow requires the backend.</p><div class="sf-modal-actions"><button class="sf-btn sf-btn-primary" data-action="close-modal">Got it</button></div>`);
    else if (action === "import-products") document.getElementById("csv-file").click();
    else if (action.startsWith("export-") || action === "export-report") exportData(action);
    else if (action === "view-order") { const order = state.orders.find(item => item.id === productId); if (order) modal(`Order ${esc(order.number)}`, `<div class="sf-settings-row"><div><strong>Customer</strong></div>${esc(order.customer)}</div><div class="sf-settings-row"><div><strong>Channel</strong></div>${esc(order.channel)}</div><div class="sf-settings-row"><div><strong>Payment state</strong></div>${status(order.status)}</div><div class="sf-settings-row"><div><strong>Total</strong></div>${money(order.amount)}</div><div class="sf-alert mt-3">No confirmed receipt or exit pass is available from the demo record.</div>`); }
    else if (action === "customer-detail") toast(`Customer profile: ${button.dataset.name}`);
    else if (action === "supplier-detail") toast(`Supplier account: ${state.suppliers[Number(button.dataset.index)]?.name || ""}`);
    else if (action === "pair-device") modal("Pair a device", `<div class="sf-alert mb-3">Pairing codes must come from an authenticated backend. This sample code is not valid for a device.</div><div class="sf-code text-center fs-4">${Math.floor(100000 + Math.random() * 900000)}</div><p class="sf-inline-note mt-2">Demo display only · expires when this dialog closes.</p>`);
    else if (action === "new-device") toast("Device registration requires a backend credential flow.");
    else if (action === "export-products") downloadCsv("scanflow-products-demo.csv", [["name", "sku", "barcode", "category", "price", "cost", "stock", "minimum"], ...state.products.map(product => [product.name, product.sku, product.barcode, product.category, product.price, product.cost, product.stock, product.minimum])]);
}
function exportData(action) {
    if (action === "export-orders" || action === "export-report") downloadCsv("scanflow-orders-demo.csv", [["order", "time", "customer", "channel", "method", "amount", "status"], ...state.orders.map(order => [order.number, order.time, order.customer, order.channel, order.method, order.amount, order.status])]);
    else if (action === "export-payments") downloadCsv("scanflow-payments-demo.csv", [["order", "method", "amount", "status"], ...state.orders.map(order => [order.number, order.method, order.amount, order.status])]);
    else if (action === "export-customers") downloadCsv("scanflow-customers-demo.csv", [["name", "phone", "email", "orders", "spend"], ...state.customers.map(customer => [customer.name, customer.phone, customer.email, customer.orders, customer.spend])]);
    else if (action === "export-audit") downloadCsv("scanflow-audit-demo.csv", [["time", "action", "actor", "detail"], ...state.audit.map(entry => [entry.time, entry.action, entry.actor, entry.detail])]);
    toast("Demo CSV downloaded.");
}
function importCsv(file) {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
        const lines = String(reader.result).split(/\r?\n/).filter(Boolean); const headers = lines.shift()?.split(",").map(value => value.trim().toLowerCase().replaceAll(/^"|"$/g, ""));
        const added = [];
        lines.forEach(line => { const values = line.split(",").map(value => value.trim().replaceAll(/^"|"$/g, "")); const row = Object.fromEntries(headers.map((header, index) => [header, values[index]])); if (row.name && row.sku) added.push({ id: id("p"), name: row.name, sku: row.sku, barcode: row.barcode || "", category: row.category || "Other", price: Number(row.price || 0), cost: Number(row.cost || 0), stock: Number(row.stock || 0), minimum: Number(row.minimum || 0) }); });
        state.products.push(...added); saveState(); renderPage(); toast(`${added.length} demo product(s) imported.`);
    };
    reader.readAsText(file);
}

document.addEventListener("click", event => {
    const pageButton = event.target.closest("[data-page]"); if (pageButton) { go(pageButton.dataset.page); return; }
    const actionButton = event.target.closest("[data-action]"); if (actionButton) handleAction(actionButton, event);
});
document.addEventListener("submit", event => { const form = event.target.closest("[data-form]"); if (!form) return; event.preventDefault(); submitForm(form); });
document.addEventListener("input", event => {
    if (event.target.id === "pos-search") { productFilter = event.target.value; filterPage(productFilter); }
    else if (event.target.id === "global-search") {
        const query = event.target.value.trim();
        if (query.length > 1) { const productMatch = state.products.some(product => `${product.name} ${product.sku} ${product.barcode}`.toLowerCase().includes(query.toLowerCase())); const orderMatch = state.orders.some(order => `${order.number} ${order.customer}`.toLowerCase().includes(query.toLowerCase())); if (productMatch) go("products"); else if (orderMatch) go("orders"); }
    } else if (event.target.dataset.filter) filterPage(event.target.value);
});
document.addEventListener("change", event => { if (event.target.id === "csv-file") importCsv(event.target.files[0]); });
renderShell();