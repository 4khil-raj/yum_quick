# YumQuick — Food Delivery Application

A production-quality Flutter Food Delivery application developed for the **Bictree Flutter Developer Technical Assignment**.

Built with **Flutter BLoC**, **Feature-Based Clean Architecture**, **Dio**, **DummyJSON API**, **Hive** local caching, **Flutter Secure Storage**, **GoRouter**, and strict reproduction of the design system, colors, curved surfaces, and supplied line-art iconography.

---

## 📱 Screenshots & Visual Aesthetics
The app strictly reproduces the provided design screenshots and geometry:
- **Palette Tokens:** Header & Splash Yellow (`#F5CB58`), Primary Nav & Button Orange (`#E95421`), Soft Cream Field Fill (`#F3E9B5`), Accent Tint (`#FFDECF`), Warm Brown Typography (`#3E1B0E`).
- **Curved Top Headers:** 28px bottom border radius with integrated address selector, notification badges, and search shortcuts.
- **Micro-Interactions:** Hero image transitions, quantity steppers, swipe-to-delete with undo snackbars, and animated progress timelines.

---

## 🌟 Key Features

1. **Authentication & Session Persistence:**
   - Powered by DummyJSON (`https://dummyjson.com/auth/login`).
   - Default test credentials: `username: emilys`, `password: emilyspass` (with one-tap demo autofill pill).
   - Secure storage of `accessToken` and `refreshToken` using `flutter_secure_storage`.
   - Bearer token injection through Dio interceptor.
   - Centralized HTTP 401 handling that safely invalidates sessions without infinite redirect loops.
   - Session restoration on app restart.
   - Optional local biometric fingerprint unlock via `local_auth`.

2. **Recipe Browsing & Exploration:**
   - Real-time recipe feed from DummyJSON (`GET /recipes?limit=10&skip=0`).
   - Infinite pagination with `limit` and `skip`.
   - Pull-to-refresh.
   - Category filtering: Snacks, Meal, Vegan, Dessert, Drinks mapped deterministically from `mealType` and `tags`.
   - Shimmer skeleton loading and error states with retry actions.

3. **Debounced Search & Multi-Criteria Filters:**
   - 350ms debounced live search (`GET /recipes/search?q={query}`).
   - Bottom sheet filter modal with Sort By options:
     - Relevance
     - Top Rated (Rating High to Low)
     - Price: Low to High
     - Price: High to Low
     - Fastest Prep Time
   - Interactive Maximum Price slider (₹99 to ₹500).

4. **Food Detail & Customization:**
   - Seamless Hero image transition from food cards.
   - Detailed nutritional info (prep time, cook time, calories per serving, difficulty, cuisine).
   - Ingredients chips and preparation steps.
   - Custom add-on toppings & dips (Extra Gourmet Cheese, Crispy Croutons, Creamy Garlic Dip, Peri-Peri Glaze) with live price updates.
   - Quantity selector synchronized with bottom checkout bar.

5. **Cart & Local Persistence:**
   - Persistent cart stored in local Hive storage (`cart_box`).
   - Add recipes from detail screen or quick-add from home/menu.
   - Quantity modification and item removal.
   - Swipe-to-delete with Undo snackbar.
   - Promo code application (`YUM10` for 10% off, `YUM20` for 20% off).
   - Full bill breakdown: Subtotal, 5% GST / Tax, Delivery Fee (Free on orders ≥ ₹500, else ₹40), Platform Service Fee (₹15), Discount, Total.

6. **Checkout & Order Tracking:**
   - Delivery address card with notes field.
   - Payment method selection (UPI, Credit/Debit Cards, Cash on Delivery).
   - Order placement with local order confirmation.
   - Active Orders & Past Orders tabs.
   - Simulated Live Tracking screen with rider profile, map route visualization, and delivery timeline.
   - Order cancellation flow with reason selection.

7. **Offline Support:**
   - Hive caching of the first page of recipes (`recipes_cache_box`).
   - Automatic fallback to cached recipes when network requests fail.
   - Real-time offline banner via `connectivity_plus`.
   - Cart persists and remains completely operational offline.

---

## 🧮 Mock Price Formula
Because DummyJSON recipes do not include a price attribute, a centralized deterministic mock-price formula is used:

```dart
double priceForRecipe(int id) {
  return 99.0 + ((id * 37) % 401);
}
```

- **Guarantees:**
  - Price is strictly deterministic based on recipe ID (Recipe #1 will always cost ₹136).
  - Price falls within the realistic range of ₹99 to ₹499.
  - Exactly consistent across Home, Menu, Search, Food Details, Cart, Checkout, and Order History.

---

## 🏷️ Category Mapping Strategy
DummyJSON categorizes recipes using `mealType` and `tags`. The app implements a centralized mapper (`CategoryMapper`) to map them into the 5 design categories:

| Design Category | Icon Asset | DummyJSON Mapping Rules |
| :--- | :--- | :--- |
| **All** | Restaurant Menu | Matches all recipes |
| **Snacks** | `ic_snacks.png` | `mealType` contains `snack`/`appetizer` OR `tags` contain `snack`, `finger food`, `dip` |
| **Meal** | `ic_knife_fork.png` | `mealType` contains `dinner`, `lunch`, `breakfast` OR `tags` contain `dinner`, `pasta`, `pizza`, `curry`, `chicken`, `beef` |
| **Vegan** | `ic_vegetables.png` | `tags` contain `vegan`, `vegetarian`, `plant-based` |
| **Dessert** | `ic_desserts.png` | `mealType` contains `dessert` OR `tags` contain `dessert`, `cake`, `cookie`, `chocolate`, `baking`, `ice cream` |
| **Drinks** | `ic_beverages.png` | `mealType` contains `beverage`, `drink` OR `tags` contain `drink`, `smoothie`, `cocktail`, `juice`, `shake`, `coffee`, `tea` |

---

## 🏗️ Architecture & Folder Structure

Follows **Consistent Feature-First Clean Architecture** with strict layer boundaries:  
`UI (Screens & Widgets)` → `BLoC (Events/States in presentation/bloc/)` → `Repository Contracts (domain/)` → `Repository Implementations (data/)` → `Data Sources (Remote Dio / Local Hive & SecureStorage)`

```
lib/
├── main.dart
├── constants/
│   └── app_assets.dart                # Backward-compatible export
└── src/
    ├── app/
    │   ├── app.dart                   # Root MultiBlocProvider & MaterialApp.router
    │   ├── router.dart                # GoRouter with redirect guards & routes
    │   └── main_navigation_shell.dart # Curved bottom navigation shell
    ├── core/
    │   ├── connectivity/              # ConnectivityService with connectivity_plus stream
    │   ├── constants/                 # AppColors, ApiConstants, AppAssets
    │   ├── errors/                    # Failure & Exception hierarchies
    │   ├── network/                   # DioClient with Bearer injection & safe 401 callback
    │   ├── storage/                   # SecureStorageService & HiveStorageService (5 boxes)
    │   ├── theme/                     # Material 3 light theme & typography
    │   ├── utils/                     # PricingCalculator, CategoryMapper, AppSnackbar
    │   └── presentation/components/   # AppButton, AppTextField, CurvedHeader, FoodCard, etc.
    └── features/
        ├── auth/
        │   ├── data/                  # AuthRemoteDataSource, AuthLocalDataSource, UserModel, AuthRepositoryImpl
        │   ├── domain/                # UserEntity, AuthRepository contract
        │   └── presentation/          # LoginScreen, OnboardingScreen, SignupScreen, SplashScreen, AuthBloc
        │       └── bloc/              # auth_bloc.dart, auth_event.dart, auth_state.dart
        ├── recipes/
        │   ├── data/                  # RecipeRemoteDataSource, RecipeLocalDataSource, RecipeModel, RecipeRepositoryImpl
        │   ├── domain/                # RecipeEntity, RecipeRepository contract
        │   └── presentation/          # HomeScreen, MenuScreen, RecipeDetailScreen, FavoritesScreen, RecipeBloc
        │       └── bloc/              # recipe_bloc.dart, recipe_event.dart, recipe_state.dart
        ├── cart/
        │   ├── data/                  # CartLocalDataSource, CartRepositoryImpl
        │   ├── domain/                # CartItemEntity, CartRepository contract
        │   └── presentation/          # CartScreen, CheckoutScreen, OrderConfirmedScreen, CartBloc
        │       └── bloc/              # cart_bloc.dart, cart_event.dart, cart_state.dart
        ├── search/
        │   └── presentation/          # FilterScreen, SearchBloc
        │       └── bloc/              # search_bloc.dart, search_event.dart, search_state.dart
        ├── orders/
        │   ├── data/                  # OrdersLocalDataSource (Hive), OrderModel, OrdersRepositoryImpl
        │   ├── domain/                # OrderEntity, OrdersRepository contract
        │   └── presentation/          # OrdersScreen, LiveTrackingScreen, OrdersBloc
        │       └── bloc/              # orders_bloc.dart, orders_event.dart, orders_state.dart
        └── profile/
            └── presentation/          # ProfileScreen with sign-out, stats, and profile options
```

### State Management & Layer Boundaries
- Grouped all BLoCs under `presentation/bloc/` consistently across all features.
- Zero business logic inside widgets: pricing calculations are pure domain rules in `PricingCalculator`.
- Zero direct HTTP or database calls in BLoCs: all persistence flows through abstract Repository contracts.
- Credential security: `accessToken` and `refreshToken` are stored exclusively in hardware-backed `FlutterSecureStorage` (never in unencrypted Hive).
- Orders persistence: `OrdersBloc` uses `OrdersRepository` backed by `OrdersLocalDataSource` with Hive `orders_box`. Orders persist across app restarts and updates.

---

## 🧪 Testing

The project includes unit and widget tests covering calculations, mock repository fallback, BLoC state transitions, and UI interactions:

1. **`test/unit/cart_pricing_test.dart`**:
   - Deterministic recipe price bounds (₹99 – ₹499).
   - INR formatting.
   - 5% GST / Tax calculation.
   - Delivery fee threshold logic (Free over ₹500, ₹40 below).
   - Platform service fee (₹15).
   - Promo discount application (`YUM10`, `YUM20`).
   - Final cart total calculation.
   - Add-on toppings price calculation.

2. **`test/unit/recipe_repository_test.dart`**:
   - Uses `mocktail` to mock remote and local data sources.
   - Tests successful remote parsing and first-page Hive caching.
   - Tests automatic fallback to cached recipes upon `NetworkException`.
   - Tests error mapping to `ServerFailure`.
   - Tests category filtering logic.

3. **`test/unit/auth_bloc_test.dart`**:
   - Tests session check (`CheckAuthSessionReq`) for restored and null sessions.
   - Tests login flow with success (`Authenticated`) and failure (`AuthError`).
   - Tests logout flow (`Unauthenticated`).
   - Tests session expiry handling (`SessionExpiredReq`).

4. **`test/unit/cart_bloc_test.dart`**:
   - Tests cart loading, empty cart state, and loaded items state.
   - Tests adding items, updating quantity, item removal, and undo item restoration.
   - Tests promo code application and cart clearing.

5. **`test/unit/orders_bloc_test.dart`**:
   - Tests loading orders from `OrdersRepository`.
   - Tests order placement with `latestPlacedOrder`.
   - Tests order cancellation and status updates.

6. **`test/unit/orders_repository_test.dart`**:
   - Tests local data source delegation for orders retrieval.
   - Tests model-to-entity mapping and order placement persistence.
   - Tests cancellation status persistence in Hive.

7. **`test/unit/search_bloc_test.dart`**:
   - Tests query debouncing and catalog caching.
   - Tests multi-attribute search across ingredients, tags, and cuisine.
   - Tests category switching and subcategory tag clearing.
   - Tests reset filters logic.

8. **Widget Tests**:
   - `test/widget/login_form_widget_test.dart`: Validates credential inputs and error states.
   - `test/widget/onboarding_widget_test.dart`: Validates slide content rendering and swipe interaction.
   - `test/widget/filter_screen_test.dart`: Validates filter screen components, chips, and price slider.

### Run Tests:
```bash
flutter test
```
*Result: All 46 unit and widget tests pass.*

---

## ⚙️ Versions & Setup

- **Flutter SDK:** 3.47.5
- **Dart SDK:** 3.13.4
- **Platform Targets:** Android & iOS

### Getting Started:
1. Ensure Flutter is installed:
   ```bash
   flutter --version
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the analyzer:
   ```bash
   flutter analyze
   ```
4. Run tests:
   ```bash
   flutter test
   ```
5. Run the application:
   ```bash
   flutter run
   ```

### Build Android APK:
```bash
flutter build apk --release
```

---

## ⏱️ Approximate Working Hours
- **Inspection & Asset Organization:** ~1.5 hours
- **Core Architecture & Network/Storage:** ~2 hours
- **Auth & Session Persistence:** ~1.5 hours
- **Recipe Browsing, Search, Filters & Caching:** ~3 hours
- **Food Detail, Cart & Checkout:** ~2.5 hours
- **Orders, Tracking & Profile:** ~1.5 hours
- **Testing, Verification & Documentation:** ~2 hours
- **Total Development Time:** ~14 hours
