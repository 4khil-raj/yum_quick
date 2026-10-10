# YumQuick — Master UI & Design Architecture Specification

This specification documents the exact design system, visual styling, component architecture, and interaction states across all screens in the YumQuick food delivery application.

---

## 1. Design System & Design Tokens

### 1.1 Color Palette

| Token Name | Hex Code | RGB | Role & Usage |
|---|---|---|---|
| `primaryYellow` | `#F5CB58` | `245, 203, 88` | Header background, splash screen, top greeting section, highlighted tabs |
| `primaryOrange` | `#E95421` | `233, 84, 33` | Primary action buttons, active pills, bottom navigation bar, icon line art |
| `logoOrange` | `#FF6430` | `255, 100, 48` | Primary brand logo accent, "YUM" lettering |
| `softCream` | `#F3E9B5` | `243, 233, 181` | Text field background fills, secondary inactive pill tags |
| `chipTintOrange` | `#FFDECF` | `255, 222, 207` | Inactive/secondary badge fills, tag pill borders |
| `badgeGray` | `#F8F8F8` | `248, 248, 248` | Circular icon badge containers |
| `backgroundLight` | `#F5F5F5` | `245, 245, 245` | Main card background surface |
| `surfaceWhite` | `#FFFFFF` | `255, 255, 255` | Curved bottom card bodies, modal dialogs, search inputs |
| `textDark` | `#3E1B0E` | `62, 27, 14` | Primary titles, bold headings, price tags, item names |
| `textMuted` | `#7D6559` | `125, 101, 89` | Subtitles, descriptions, placeholder text, timestamps |
| `statusGreen` | `#4CAF50` | `76, 175, 80` | Delivered order status, active tracking state |
| `statusRed` | `#E53935` | `229, 57, 53` | Cancelled order text, delete account actions |

---

### 1.2 Geometry, Shapes & Layout Tokens

- **Top Curved Container**: Screen transitions feature a curved white card overlapping the yellow header with `BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))`.
- **Side Drawers**: Right-anchored curved overlay panels with `BorderRadius.only(topLeft: Radius.circular(36), bottomLeft: Radius.circular(36))` and a deep orange background (`#E95421`).
- **Button Styling**: Rounded pill geometry (`BorderRadius.circular(28)`), standard height 50–54px, bold white or deep brown text.
- **Form Inputs**: Soft cream filled containers (`#F3E9B5`), height 48–52px, `BorderRadius.circular(16)`, no harsh borders, subtle padding.
- **Bottom Navigation Bar**: Fixed orange bar (`#E95421`), height ~70px, containing 5 balanced icons (Home, Cloche/Menu, Heart/Favorites, Clipboard/Orders, Headset/Support).
- **Steppers**: Circular `-` and `+` buttons (`#E95421`) flanking bold count numerals.

---

## 2. Screen-by-Screen Specifications

### Section 0: Launch & Welcome
- **0-A Splash Screen**: Fullscreen warm yellow background (`#F5CB58`), centered orange heart-fork YumQuick logo with white typography.
- **0-B Launch Welcome**: Deep orange background (`#E95421`), centered yellow logo, sub-headline, **Log In** pill button (yellow `#F5CB58`) and **Sign Up** pill button (cream `#F3E9B5`).

### Section 1: Onboarding Carousel
- **1-A / 1-B / 1-C Carousel**:
  - Full-bleed food hero images: Pepperoni Pizza (Food), Brownie & Ice cream (Payment), Latte Art (Delivery).
  - Top right: *"Skip >"* action.
  - Curved white sheet with circular icon badge (`ic_orders`, `ic_payment`, `ic_delivery`).
  - Titles: *"Order For Food"*, *"Easy Payment"*, *"Fast Delivery"*.
  - 3-step active dash indicator (`#E95421` active, `#F3E9B5` inactive).
  - Action button: **Next** (steps 1–2) and **Get Started** (step 3).

### Section 2: Authentication & Biometrics
- **2-A & 2-B Log In**: Yellow header with back chevron. White curved card with *"Welcome"* header. Email/Mobile input, Password with `ic_eye` visibility toggle, *"Forgot Password?"* link, orange **Log In** button, social login row (Google, Facebook, Fingerprint), and *"Sign Up"* link.
- **2-C Sign Up**: Form fields for Full Name, Password, Email, Mobile Number, and Date of Birth with terms disclaimer.
- **2-D Set Password**: Password and Confirm Password inputs with eye toggles and **Create New Password** button.
- **2-E & 2-F Fingerprint Biometric**: Visual fingerprint enrollment showing inactive state (light orange) transitioning to active state (vibrant orange), with **Skip** and **Continue** actions.

### Section 3 & 9.1: Master Home Page
- **Header**: Yellow background with search input, filter icon (`ic_settings` / filter), top action icons (Cart, Notification, Profile), and personalized greeting (*"Good Morning — Rise And Shine! It's Breakfast Time"*).
- **Categories Row**: 5 circular icon badges with orange line art and labels (*Snacks, Meal, Vegan, Dessert, Drinks*).
- **Best Seller Carousel**: Horizontal cards with image, price badge, title, rating, and *"View All >"* link.
- **Promo Deal Banner**: 30% OFF banner with pizza image, discount badge, and carousel indicator dots.
- **Recommendations Grid**: Multi-column cards with rating badges (`5.0 ⭐️ ❤️`) and price tags.

### Section 4.1: Profile Drawer & Sub-screens
- **4.1-A Profile Drawer**: Slide-out curved orange panel with user avatar (John Smith), email, and 8 navigation rows.
- **4.1.1-I My Profile**: Avatar with camera badge, Full Name, DOB (highlighted), Email, Phone Number, and **Update Profile** button.
- **4.1.1-J Delivery Address**: List of saved addresses with home icons, radio selectors, and **Add New Address** button.
- **4.1.1-K Add New Address**: House icon header, Name and Address text inputs, **Apply** button.
- **4.1.1-L Payment Methods**: Saved cards and payment options (Credit Card, Apple Pay, PayPal, Google Play).
- **4.1.1-M Add Card**: Stylized card preview with chip and live inputs for Cardholder Name, Card Number, Expiry, and CVV.
- **4.1.1-N & 4.1.1-O Contact & FAQs**: `FAQ` and `Contact Us` segment toggle, social support channels, and expandable FAQ accordions.
- **4.1.1-P through 4.1.1-R Settings**: Notification switches list, Password reset form, Delete account link.
- **4.1.1-S Log Out Modal**: Bottom confirmation sheet with **Cancel** and **Yes, logout** buttons.

### Section 4.2: Notifications Panel
- **4.2-A Notification Drawer**: List of order and promotional notifications with category icons (*Cutlery, Heart, Bag, Scooter*).

### Section 4.3: Cart & Checkout
- **4.3-A Empty Cart**: Prompt with add button.
- **4.3-B Cart Drawer**: List of items with image, price, and `-` `+` quantity steppers, subtotal, tax, delivery fee, and yellow **Checkout** button.
- **4.3-C Confirm Order**: Shipping address card with edit trigger, item summary, cost breakdown, and **Place Order** button.
- **4.3-D Payment**: Address review, payment method selector, estimated delivery time (25 mins), and **Pay Now** button.
- **4.3-E Order Confirmed**: Full yellow celebration screen with *"¡Order Confirmed!"* and **Track my order** link.
- **4.3-F Live Delivery Tracking**: Interactive map route with restaurant marker, courier scooter, user pin, 4-stage tracking timeline, and **Track Order** button.

### Section 4.4: Search & Multi-criteria Filters
- Category selector pills, Top Rated 5-star selector, dynamic subcategory tag chips per category, price range slider ($1–$100+), and **Apply** button.

### Section 5 & 9.2: Food Menu & Food Item Details
- **Category Tabs**: Dedicated tabs for Snacks, Meals, Vegan, Desserts, and Drinks.
- **Item Detail Screens**: Full photo hero, rating badge, wishlist toggle, quantity stepper, customizable toppings/add-on ingredients with individual prices, and sticky **Add to Cart** button.

### Section 6, 7 & 8: Discover Sub-screens
- **6-A Best Seller**: 2-column grid of popular dishes with category badges, ratings, and instant add-to-cart buttons.
- **7-A Promo Deal Detail**: Hero pizza detail with -30% discount rosette badge, portion size selector (Personal, Medium, Familiar, Jumbo), and price calculations.
- **8-A Recommendations**: Chef specials with *"New Product"* badge, crepes, burgers, milkshakes, and curries.

### Section 9.3: Favorites
- **9.3-A Favorites Grid**: 2-column wishlist grid of favorited dishes with active heart buttons (❤️).

### Section 9.4: Orders Hub & Tracking
- **9.4-A through 9.4-C**: Active, Completed, and Cancelled order tabs with **Cancel Order** and **Track Driver** actions.
- **9.4-D & 9.4-E**: Order History list and detailed invoice receipt.
- **9.4-F & 9.4-G**: Full GPS map tracking with *"Call driver"* & *"Message driver"* buttons, plus post-delivery 5-star rating screen.
- **9.4-H & 9.4-I**: Cancel Order questionnaire with radio options, custom text area, and confirmation screen.

### Section 9.5: Support Hub & Live Chat
- **9.5-A**: Support gateway (*Help with order* vs *Help center*).
- **9.5-B Live Chat**: Interactive customer service chatbot with order context card, quick-reply chips, and composer bar with attachment, mic, and send buttons.
- **9.5-C & 9.5-D**: Help Center FAQ accordions and direct contact channels.
