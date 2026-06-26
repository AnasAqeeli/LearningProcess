const http = require("http");

const products = [
  {
    id: 1,
    name: "Ethiopian Yirgacheffe",
    origin: "Ethiopia",
    roast: "Light",
    price: 18.99,
    weight: "250g",
    notes: "Blueberry, jasmine, citrus",
    img: "🫘",
  },
  {
    id: 2,
    name: "Colombian Supremo",
    origin: "Colombia",
    roast: "Medium",
    price: 15.99,
    weight: "250g",
    notes: "Caramel, nuts, mild chocolate",
    img: "☕",
  },
  {
    id: 3,
    name: "Sumatra Mandheling",
    origin: "Indonesia",
    roast: "Dark",
    price: 16.99,
    weight: "250g",
    notes: "Earthy, cedar, dark chocolate",
    img: "🌑",
  },
  {
    id: 4,
    name: "Guatemala Antigua",
    origin: "Guatemala",
    roast: "Medium-Dark",
    price: 17.49,
    weight: "250g",
    notes: "Cocoa, brown sugar, smoky",
    img: "🍫",
  },
  {
    id: 5,
    name: "Kenya AA",
    origin: "Kenya",
    roast: "Light-Medium",
    price: 19.99,
    weight: "250g",
    notes: "Blackcurrant, tomato, wine",
    img: "🍇",
  },
  {
    id: 6,
    name: "Brazil Santos",
    origin: "Brazil",
    roast: "Medium",
    price: 13.99,
    weight: "250g",
    notes: "Nutty, sweet, low acidity",
    img: "🥜",
  },
];

const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Roast & Co. — Premium Coffee Beans</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --espresso: #1a0a00;
      --roast:    #3d1c02;
      --caramel:  #c47b2b;
      --cream:    #f5ede0;
      --foam:     #faf6f0;
      --text:     #2c1a0e;
      --muted:    #7a5c42;
    }

    body {
      font-family: 'Georgia', serif;
      background: var(--foam);
      color: var(--text);
    }

    /* ── NAV ── */
    nav {
      background: var(--espresso);
      color: var(--cream);
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem 2rem;
      position: sticky;
      top: 0;
      z-index: 100;
    }
    .logo { font-size: 1.5rem; letter-spacing: .05em; }
    .logo span { color: var(--caramel); }
    .cart-btn {
      background: var(--caramel);
      color: #fff;
      border: none;
      padding: .5rem 1.2rem;
      border-radius: 999px;
      cursor: pointer;
      font-size: .95rem;
      display: flex;
      align-items: center;
      gap: .5rem;
      transition: opacity .2s;
    }
    .cart-btn:hover { opacity: .85; }
    #cart-count {
      background: #fff;
      color: var(--caramel);
      border-radius: 50%;
      width: 1.4rem;
      height: 1.4rem;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: .75rem;
      font-weight: bold;
    }

    /* ── HERO ── */
    .hero {
      background: linear-gradient(135deg, var(--roast) 0%, var(--espresso) 100%);
      color: var(--cream);
      text-align: center;
      padding: 5rem 2rem 4rem;
    }
    .hero h1 { font-size: clamp(2rem, 5vw, 3.5rem); margin-bottom: 1rem; }
    .hero p  { font-size: 1.1rem; color: #c8a882; max-width: 500px; margin: 0 auto 2rem; }
    .hero a  {
      display: inline-block;
      background: var(--caramel);
      color: #fff;
      padding: .8rem 2rem;
      border-radius: 999px;
      text-decoration: none;
      font-size: 1rem;
      transition: opacity .2s;
    }
    .hero a:hover { opacity: .85; }

    /* ── PRODUCTS ── */
    .section-title {
      text-align: center;
      padding: 3rem 1rem 1.5rem;
      font-size: 1.8rem;
      color: var(--roast);
    }
    .products {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 1.5rem;
      max-width: 1100px;
      margin: 0 auto;
      padding: 0 1.5rem 3rem;
    }
    .card {
      background: #fff;
      border-radius: 12px;
      padding: 1.5rem;
      box-shadow: 0 2px 12px rgba(26,10,0,.08);
      display: flex;
      flex-direction: column;
      gap: .75rem;
      transition: transform .2s, box-shadow .2s;
    }
    .card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(26,10,0,.13); }
    .card-icon  { font-size: 2.5rem; }
    .card h3    { font-size: 1.1rem; }
    .card .origin { font-size: .8rem; color: var(--muted); text-transform: uppercase; letter-spacing: .08em; }
    .badges     { display: flex; gap: .4rem; flex-wrap: wrap; }
    .badge {
      font-size: .72rem;
      padding: .2rem .6rem;
      border-radius: 999px;
      background: var(--cream);
      color: var(--roast);
      font-style: italic;
    }
    .notes      { font-size: .85rem; color: var(--muted); }
    .card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: auto; }
    .price      { font-size: 1.25rem; font-weight: bold; color: var(--caramel); }
    .add-btn {
      background: var(--roast);
      color: #fff;
      border: none;
      padding: .45rem 1rem;
      border-radius: 999px;
      cursor: pointer;
      font-size: .9rem;
      transition: background .2s;
    }
    .add-btn:hover { background: var(--caramel); }

    /* ── CART DRAWER ── */
    .overlay {
      position: fixed; inset: 0;
      background: rgba(0,0,0,.5);
      z-index: 200;
      display: none;
    }
    .overlay.open { display: block; }
    .drawer {
      position: fixed;
      top: 0; right: -420px;
      width: min(420px, 100vw);
      height: 100vh;
      background: #fff;
      z-index: 300;
      display: flex;
      flex-direction: column;
      transition: right .3s ease;
      box-shadow: -4px 0 24px rgba(0,0,0,.15);
    }
    .drawer.open { right: 0; }
    .drawer-header {
      background: var(--espresso);
      color: var(--cream);
      padding: 1.25rem 1.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 1.1rem;
    }
    .close-btn {
      background: none;
      border: none;
      color: var(--cream);
      font-size: 1.4rem;
      cursor: pointer;
      line-height: 1;
    }
    .drawer-body { flex: 1; overflow-y: auto; padding: 1rem 1.5rem; }
    .empty-msg   { text-align: center; color: var(--muted); margin-top: 3rem; font-style: italic; }
    .cart-item {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: .85rem 0;
      border-bottom: 1px solid var(--cream);
    }
    .cart-item-icon { font-size: 1.8rem; }
    .cart-item-info { flex: 1; }
    .cart-item-info strong { display: block; font-size: .95rem; }
    .cart-item-info span  { font-size: .8rem; color: var(--muted); }
    .qty-ctrl {
      display: flex;
      align-items: center;
      gap: .4rem;
    }
    .qty-ctrl button {
      width: 1.6rem; height: 1.6rem;
      border-radius: 50%;
      border: 1px solid var(--cream);
      background: var(--foam);
      cursor: pointer;
      font-size: .9rem;
      line-height: 1;
    }
    .cart-item-price { font-weight: bold; color: var(--caramel); min-width: 4rem; text-align: right; }
    .drawer-footer {
      padding: 1.25rem 1.5rem;
      border-top: 1px solid var(--cream);
    }
    .total-row {
      display: flex;
      justify-content: space-between;
      font-size: 1.1rem;
      margin-bottom: 1rem;
    }
    .checkout-btn {
      width: 100%;
      padding: .9rem;
      background: var(--caramel);
      color: #fff;
      border: none;
      border-radius: 999px;
      font-size: 1rem;
      cursor: pointer;
      transition: opacity .2s;
    }
    .checkout-btn:hover { opacity: .85; }

    /* ── ABOUT ── */
    .about {
      background: var(--cream);
      text-align: center;
      padding: 4rem 2rem;
    }
    .about h2 { font-size: 1.8rem; color: var(--roast); margin-bottom: 1rem; }
    .about p  { max-width: 600px; margin: 0 auto; line-height: 1.8; color: var(--muted); }

    /* ── FOOTER ── */
    footer {
      background: var(--espresso);
      color: #7a5c42;
      text-align: center;
      padding: 1.5rem;
      font-size: .85rem;
    }

    /* ── TOAST ── */
    .toast {
      position: fixed;
      bottom: 2rem;
      left: 50%;
      transform: translateX(-50%) translateY(80px);
      background: var(--roast);
      color: var(--cream);
      padding: .7rem 1.5rem;
      border-radius: 999px;
      font-size: .9rem;
      opacity: 0;
      transition: transform .3s, opacity .3s;
      z-index: 500;
      pointer-events: none;
    }
    .toast.show {
      transform: translateX(-50%) translateY(0);
      opacity: 1;
    }
  </style>
</head>
<body>

<nav>
  <div class="logo">Roast <span>&</span> Co.</div>
  <button class="cart-btn" onclick="toggleCart()">
    🛒 Cart <span id="cart-count">0</span>
  </button>
</nav>

<section class="hero">
  <h1>Single-Origin.<br/>Freshly Roasted.</h1>
  <p>Handpicked beans from the world's finest growing regions, roasted to order and shipped to your door.</p>
  <a href="#shop">Shop Beans</a>
</section>

<h2 class="section-title" id="shop">Our Beans</h2>
<div class="products" id="product-grid"></div>

<section class="about">
  <h2>Why Roast & Co.?</h2>
  <p>We source directly from small-batch farms across Ethiopia, Colombia, Indonesia, and beyond. Every bag is roasted fresh within 48 hours of your order — so you always get peak flavour, not warehouse dust.</p>
</section>

<footer>&copy; 2026 Roast &amp; Co. All rights reserved.</footer>

<!-- Cart Drawer -->
<div class="overlay" id="overlay" onclick="toggleCart()"></div>
<div class="drawer" id="drawer">
  <div class="drawer-header">
    Your Cart
    <button class="close-btn" onclick="toggleCart()">✕</button>
  </div>
  <div class="drawer-body" id="cart-body"></div>
  <div class="drawer-footer">
    <div class="total-row">
      <span>Total</span>
      <span id="cart-total">$0.00</span>
    </div>
    <button class="checkout-btn" onclick="checkout()">Checkout</button>
  </div>
</div>

<div class="toast" id="toast"></div>

<script>
  const PRODUCTS = ${JSON.stringify(products)};
  let cart = {};

  function renderProducts() {
    const grid = document.getElementById('product-grid');
    grid.innerHTML = PRODUCTS.map(p => \`
      <div class="card">
        <div class="card-icon">\${p.img}</div>
        <div class="origin">\${p.origin}</div>
        <h3>\${p.name}</h3>
        <div class="badges">
          <span class="badge">\${p.roast} Roast</span>
          <span class="badge">\${p.weight}</span>
        </div>
        <p class="notes">\${p.notes}</p>
        <div class="card-footer">
          <span class="price">\$\${p.price.toFixed(2)}</span>
          <button class="add-btn" onclick="addToCart(\${p.id})">Add to Cart</button>
        </div>
      </div>
    \`).join('');
  }

  function addToCart(id) {
    cart[id] = (cart[id] || 0) + 1;
    updateCartUI();
    const p = PRODUCTS.find(x => x.id === id);
    showToast(\`\${p.name} added to cart!\`);
  }

  function changeQty(id, delta) {
    cart[id] = (cart[id] || 0) + delta;
    if (cart[id] <= 0) delete cart[id];
    updateCartUI();
  }

  function updateCartUI() {
    const count = Object.values(cart).reduce((a, b) => a + b, 0);
    document.getElementById('cart-count').textContent = count;

    const body = document.getElementById('cart-body');
    const ids = Object.keys(cart);

    if (!ids.length) {
      body.innerHTML = '<p class="empty-msg">Your cart is empty.<br/>Add some beans!</p>';
      document.getElementById('cart-total').textContent = '$0.00';
      return;
    }

    let total = 0;
    body.innerHTML = ids.map(id => {
      const p = PRODUCTS.find(x => x.id == id);
      const qty = cart[id];
      const sub = p.price * qty;
      total += sub;
      return \`
        <div class="cart-item">
          <span class="cart-item-icon">\${p.img}</span>
          <div class="cart-item-info">
            <strong>\${p.name}</strong>
            <span>\$\${p.price.toFixed(2)} each</span>
          </div>
          <div class="qty-ctrl">
            <button onclick="changeQty(\${id}, -1)">−</button>
            <span>\${qty}</span>
            <button onclick="changeQty(\${id}, +1)">+</button>
          </div>
          <span class="cart-item-price">\$\${sub.toFixed(2)}</span>
        </div>
      \`;
    }).join('');
    document.getElementById('cart-total').textContent = \`\$\${total.toFixed(2)}\`;
  }

  function toggleCart() {
    document.getElementById('drawer').classList.toggle('open');
    document.getElementById('overlay').classList.toggle('open');
  }

  function showToast(msg) {
    const t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), 2200);
  }

  function checkout() {
    if (!Object.keys(cart).length) return showToast('Your cart is empty!');
    cart = {};
    updateCartUI();
    toggleCart();
    showToast('Order placed! Thanks for your purchase ☕');
  }

  renderProducts();
</script>
</body>
</html>`;

const PORT = 8080;
http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(html);
}).listen(PORT, () => {
  console.log(`Roast & Co. running at http://localhost:${PORT}`);
});
