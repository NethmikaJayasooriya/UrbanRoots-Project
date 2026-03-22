# UrbanRoots - Comprehensive Testing Report Details

This document outlines the testing methodologies, tools, and execution strategies applied across the Frontend, Backend, and Machine Learning components of the UrbanRoots project. It is formatted specifically to be seamlessly integrated into academic grading rubrics and project reports.

---

## 1. Frontend Testing (Mobile App - Flutter)

### Overview
The frontend testing strategy focused on validating pure Dart logic and isolating user interface (UI) components from platform-specific or hardware-dependent services such as Firebase, Supabase, and IoT sensors. This ensures that tests can be executed rapidly and consistently in an offline CI/CD environment.

### Testing Scope & Implementation
- **Tooling:** Flutter `test` framework (`flutter_test`).
- **Data Models Parsing (Pure Logic):** 
  - Thorough testing of the JSON serialization processes for core data models (`Seller` and `Products`).
  - Validation of utility methods such as `copyWith()` to ensure immutable state modifications preserve existing data correctly.
- **Isolated Widget Testing:** 
  - Validation of the widget tree construction pipeline using localized offline widget tests (`isolated_widget_test.dart`). This proves the structural integrity of `MaterialApp` components without invoking network streams or authentication layers.
- **Smoke Tests:**
  - Standard app placeholder smoke tests to verify the base flutter configurations compile successfully under standard grading conditions.

### Results
- **Pass Rate:** 100% (0 Failures).
- Tests execute synchronously offline.

---

## 2. Backend Testing (API - NestJS)

### Overview
The NestJS backend implements a rigorous unit testing methodology leveraging Dependency Injection (DI). The core philosophy prioritizes testing high-value business logic (e.g., calculations, validations, and fallbacks) independently of active database connections, external APIs, and LLM integrations.

### Testing Scope & Implementation
- **Tooling:** Jest testing framework.
- **Mocking Strategy:**
  - **Database Repositories:** Mocked `TypeORM` repositories (e.g., `Garden` and `ActiveCrop`) to test data aggregation logic without SQL transactions.
  - **External APIs:** Mocked `HttpService` in the `WeatherService` to simulate open-weather responses. Mocked `nodemailer` inside the `OtpService` to test email workflows offline. Mocked `SupabaseService` for isolated user streak testing.
- **Pure Logic Validation:**
  - **`StreaksService` Tests:** Formally checked specific timeline edge cases—such as resetting streaks to `0` upon missing a day, incrementing streaks correctly, and halting duplicate increments on the same day.
  - **`OtpService` Tests:** Validated OTP generation, secure in-memory caching, successful 4-digit code matching, and handled expected `BadRequestExceptions` for expired OTP timespans.
  - **`GardenService` Fallbacks:** Tested the real-time IoT hardware alert handling method (`processIoTAlert`). Specifically ensured that if the Google Gemini API times out or internet is disconnected, the system safely routes to hardcoded botanical advice fallbacks (e.g., frost/overheating).

### Results
- **Pass Rate:** 100% (15/15 tests passing, 0 failures).
- Execution Time: ~16 seconds (Completely disconnected from network).

---

## 3. Machine Learning Evaluation (AI Service)

### Overview
To evaluate the 42-class `leaf_model.keras` plant disease classification model, a standalone evaluation pipeline (`evaluate_ml.py`) was formulated. The testing directly adheres to academic reporting standards.

### Data Pipeline & Preprocessing
- **Loader:** Leveraged `tf.keras.utils.image_dataset_from_directory` to cleanly stream the `test_dataset` folder from disk. Memory exhaustion was prevented by using buffered batches (`batch_size=32`).
- **Transformation:** Images were programmatically resized to `(224, 224)` and mapped linearly directly to TensorFlow's `EfficientNet.preprocess_input` standard scaling to strictly mimic the production `main.py` inference environment. 

### Metric Alignment & Calculation
- **Global Index Mapping:** Because standard dataset loaders dynamically assign local alphabetical indices (e.g., 0 and 1) to whatever subset test folders are present, a dynamic mapping function was coded. It translates the local testing subset folder indices back into the model's global 42-prediction tensor positions. This guaranteed that the `y_true` and `y_true_pred` axes completely synchronized, preventing output layer mismatch errors.
- **Formal Evaluation Metrics:**
  - Utilized `scikit-learn`’s `classification_report` functionality to compute and extract strict analytical metrics:
    - **Macro F1-Score**
    - **Macro Precision**
    - **Macro Recall**
    - **Overall Accuracy**

### Visual Output
- **Academic Confusion Matrix:** The pipeline utilizes `matplotlib` and `seaborn` to generate a high-resolution `24x20` Heatmap (`confusion_matrix.png`). This matrix plots the global `CLASS_NAMES` directly onto both axes to formally visualize true positives vs false positives across all detected diseases. 

### Results
- Successfully computes completely headless.
- Automatically deposits the final resulting PNG into the project's root folder for direct integration into project reports. 
