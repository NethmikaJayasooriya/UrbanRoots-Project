from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
from tensorflow.keras.applications.efficientnet import preprocess_input
import io
import cv2

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

model = tf.keras.models.load_model(
    r"C:\Users\Himasara\Desktop\urbanRoots1\UrbanRoots-Project\ai_service\leaf_model.keras"
)

CLASS_NAMES = [
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___healthy",
    "Crape_jasmine_Yellow_leaf_disease",
    "Crape_jasmine_healthy",
    "Crape_jasmine_insect_bite",
    "Dwarf_white_bauhinia_Death_leaf",
    "Dwarf_white_bauhinia_Yellow_Leaf_Disease",
    "Dwarf_white_bauhinia_healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___healthy",
    "Hibiscus_Blight",
    "Hibiscus_Death_leaf",
    "Hibiscus_Scorch",
    "Hibiscus_healthy",
    "Night_flowering_jasmine_Early_blight",
    "Night_flowering_jasmine_Red_spot",
    "Night_flowering_jasmine_healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Pepper__bell___Bacterial_spot",
    "Pepper__bell___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Raspberry___healthy",
    "Rose___blight",
    "Rose___healthy",
    "Soybean___healthy",
    "Strawberry___Leaf_scorch",
    "Strawberry___healthy",
    "Tomato_Bacterial_spot",
    "Tomato_Early_blight",
    "Tomato_Late_blight",
    "Tomato_Leaf_Mold",
    "Tomato_Septoria_leaf_spot",
    "Tomato_Spider_mites_Two_spotted_spider_mite",
    "Tomato__Target_Spot",
    "Tomato__Tomato_YellowLeaf__Curl_Virus",
    "Tomato__Tomato_mosaic_virus",
    "Tomato_healthy",
]


def preprocess_leaf_image(image_bytes):
    nparr  = np.frombuffer(image_bytes, np.uint8)
    img_cv = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    hsv    = cv2.cvtColor(img_cv, cv2.COLOR_BGR2HSV)

    mask_green  = cv2.inRange(hsv, np.array([25, 30, 30]), np.array([95, 255, 255]))
    mask_yellow = cv2.inRange(hsv, np.array([15, 30, 30]), np.array([35, 255, 255]))
    mask_brown  = cv2.inRange(hsv, np.array([5,  30, 20]), np.array([20, 255, 200]))

    combined = cv2.bitwise_or(mask_green, mask_yellow)
    combined = cv2.bitwise_or(combined, mask_brown)

    kernel   = np.ones((15, 15), np.uint8)
    combined = cv2.morphologyEx(combined, cv2.MORPH_CLOSE, kernel)
    combined = cv2.morphologyEx(combined, cv2.MORPH_OPEN,  kernel)

    contours, _ = cv2.findContours(combined, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        largest    = max(contours, key=cv2.contourArea)
        area       = cv2.contourArea(largest)
        total_area = img_cv.shape[0] * img_cv.shape[1]

        if area > total_area * 0.10:
            x, y, w, h = cv2.boundingRect(largest)
            pad_x = int(w * 0.10)
            pad_y = int(h * 0.10)
            x     = max(0, x - pad_x)
            y     = max(0, y - pad_y)
            w     = min(img_cv.shape[1] - x, w + 2 * pad_x)
            h     = min(img_cv.shape[0] - y, h + 2 * pad_y)
            img_cv = img_cv[y:y+h, x:x+w]

    img_rgb = cv2.cvtColor(img_cv, cv2.COLOR_BGR2RGB)
    return Image.fromarray(img_rgb)


@app.get("/")
def home():
    return {
        "message":       "Leaf Disease Detection API is running!",
        "total_classes": len(CLASS_NAMES),
        "version":       "v3 — 42 classes, 97.35% accuracy"
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()

    try:
        img = preprocess_leaf_image(contents)
    except Exception:
        img = Image.open(io.BytesIO(contents)).convert("RGB")

    img       = img.convert("RGB").resize((224, 224))
    img_array = np.array(img, dtype=np.float32)
    img_array = preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)

    predictions     = model.predict(img_array)
    predicted_index = np.argmax(predictions[0])
    confidence      = float(np.max(predictions[0])) * 100

    if confidence < 55:
        return {
            "disease":    "Not recognized",
            "confidence": round(confidence, 2),
            "message":    "Please take a clearer photo of a leaf"
        }

    disease_name = CLASS_NAMES[predicted_index]
    is_healthy   = "healthy" in disease_name.lower()

    return {
        "disease":    disease_name,
        "confidence": round(confidence, 2),
        "is_healthy": is_healthy,
        "plant":      disease_name.split("_")[0].split("(")[0].strip()
    }