import os
import tensorflow as tf
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
from tensorflow.keras.applications.efficientnet import preprocess_input
import numpy as np
from PIL import Image
import io

model = tf.keras.models.load_model("ai_service/leaf_model.keras")

dataset_path = "ai_service/test_dataset"
test_ds_raw = tf.keras.utils.image_dataset_from_directory(
    dataset_path, seed=123, image_size=(224, 224), batch_size=32, shuffle=False
)
file_paths = getattr(test_ds_raw, 'file_paths', [])
first_file = file_paths[0]

def preprocess(images, labels):
    return preprocess_input(images), labels
test_ds = test_ds_raw.map(preprocess)

for images, labels in test_ds.take(1):
    first_image_ds = images[0:1]
    break

preds_ds = model.predict(first_image_ds, verbose=0)
out1 = f"1. Dataset Pipeline\n   Max Logit/Prob: {np.max(preds_ds[0]):.4f}, Class: {np.argmax(preds_ds[0])}\n   Pixel 0: {first_image_ds.numpy()[0, 0, 0, :3]}\n"

with open(first_file, "rb") as f:
    contents = f.read()

img_tensor = tf.io.decode_image(contents, channels=3, expand_animations=False)
img_tensor = tf.image.resize(img_tensor, [224, 224], method='bilinear')
img_array = img_tensor.numpy()
img_array = preprocess_input(img_array)
img_array = np.expand_dims(img_array, axis=0)

preds_api = model.predict(img_array, verbose=0)
out2 = f"\n2. API Pipeline\n   Max Logit/Prob: {np.max(preds_api[0]):.4f}, Class: {np.argmax(preds_api[0])}\n   Pixel 0: {img_array[0, 0, 0, :3]}\n"

img_pil = Image.open(io.BytesIO(contents)).convert("RGB").resize((224, 224))
img_pil_arr = np.array(img_pil, dtype=np.float32)
img_pil_arr = preprocess_input(img_pil_arr)
img_pil_arr = np.expand_dims(img_pil_arr, axis=0)
preds_old_api = model.predict(img_pil_arr, verbose=0)
out3 = f"\n3. Old PIL API Pipeline\n   Max Logit/Prob: {np.max(preds_old_api[0]):.4f}, Class: {np.argmax(preds_old_api[0])}\n   Pixel 0: {img_pil_arr[0, 0, 0, :3]}\n"

with open("discrepancy_results.txt", "w", encoding="utf-8") as f:
    f.write(out1 + out2 + out3)
