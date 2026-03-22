import os
import sys
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications.efficientnet import preprocess_input
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, precision_score, recall_score, f1_score
import matplotlib.pyplot as plt
import seaborn as sns
from main import CLASS_NAMES

def main():
    root_folder = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ai_service_folder = os.path.join(root_folder, "ai_service")
    dataset_path = os.path.join(ai_service_folder, "test_dataset")

    # 1. Error Handling: check if test_dataset exists
    if not os.path.exists(dataset_path):
        print(f"ERROR: The test_dataset folder was not found at {dataset_path}")
        print("Please ensure you have placed your testing images in 'ai_service/test_dataset' organized by class folders.")
        sys.exit(1)

    print("Loading test dataset...")
    
    # 2. Data Pipeline: test data loader
    # Load dataset with target size 224x224 and shuffle=False to keep ordering for metrics
    test_ds = tf.keras.utils.image_dataset_from_directory(
        dataset_path,
        seed=123,
        image_size=(224, 224),
        batch_size=32,
        shuffle=False
    )

    class_names = test_ds.class_names
    num_classes = len(class_names)
    print(f"Found {num_classes} classes.")

    # Apply EfficientNet preprocessing
    def preprocess(images, labels):
        return preprocess_input(images), labels

    test_ds = test_ds.map(preprocess)

    # 3. Model Loading
    model_path = os.path.join(ai_service_folder, "leaf_model.keras")
    if not os.path.exists(model_path):
        print(f"ERROR: The model file 'leaf_model.keras' was not found at {model_path}")
        sys.exit(1)

    print("Loading model...")
    model = tf.keras.models.load_model(model_path)

    print("Generating predictions on the test dataset. This may take a while...")
    
    # Extract true labels from the dataset (these are local indices 0 to N based on folders)
    y_true_local = np.concatenate([y for x, y in test_ds], axis=0)
    
    # Map the local test_dataset indices to the model's global 42 CLASS_NAMES indices
    y_true = np.array([CLASS_NAMES.index(class_names[y]) if class_names[y] in CLASS_NAMES else y for y in y_true_local])
    
    # Generate predictions
    predictions = model.predict(test_ds)
    y_pred = np.argmax(predictions, axis=1)

    print("\n--- Metrics Generation ---")
    
    # Calculate metrics
    accuracy = accuracy_score(y_true, y_pred)
    macro_precision = precision_score(y_true, y_pred, average='macro', zero_division=0)
    macro_recall = recall_score(y_true, y_pred, average='macro', zero_division=0)
    macro_f1 = f1_score(y_true, y_pred, average='macro', zero_division=0)

    print(f"Overall Accuracy : {accuracy:.4f}")
    print(f"Macro Precision  : {macro_precision:.4f}")
    print(f"Macro Recall     : {macro_recall:.4f}")
    print(f"Macro F1-Score   : {macro_f1:.4f}")
    
    print("\n--- Detailed Classification Report ---")
    report = classification_report(y_true, y_pred, labels=range(len(CLASS_NAMES)), target_names=CLASS_NAMES, zero_division=0)
    print(report)

    # 4. Visual Output: Confusion Matrix
    print("\nGenerating Confusion Matrix plot...")
    cm = confusion_matrix(y_true, y_pred, labels=range(len(CLASS_NAMES)))
    
    plt.figure(figsize=(24, 20))
    sns.heatmap(cm, annot=False, cmap='Blues', fmt='g', 
                xticklabels=CLASS_NAMES, yticklabels=CLASS_NAMES)
    plt.xlabel('Predicted Labels', fontsize=16)
    plt.ylabel('True Labels', fontsize=16)
    plt.title('Plant Disease Detection Confusion Matrix', fontsize=20)
    plt.xticks(rotation=90, fontsize=10)
    plt.yticks(rotation=0, fontsize=10)
    plt.tight_layout()

    # Save to root folder
    cm_output_path = os.path.join(root_folder, "confusion_matrix.png")
    plt.savefig(cm_output_path, dpi=300)
    plt.close()

    print(f"DONE. Confusion Matrix automatically saved to: {cm_output_path}")

if __name__ == "__main__":
    main()
