# 🎧 Seeing Through Sound

**AI-Based Object Detection and Assistance for the Blind**

## 📌 Overview

**Seeing Through Sound** is a mobile application that helps blind and visually impaired individuals recognize surrounding objects and understand their spatial environment using artificial intelligence. The system detects objects and estimates their distance, then translates this data into audio feedback — enhancing the user’s independence and safety.

> This project was developed as a graduation project at Hadramout University, Computer Science Department (2025).

---

## 🎯 Problem Statement

Traditional tools for the visually impaired often lack real-time feedback and spatial awareness, while modern assistive technologies tend to be expensive and inaccessible. Our project aims to deliver a **smart**, **affordable**, and **real-time** software-based solution using AI.

---

## 🛠️ Technologies Used

- **Flutter** – For building the mobile application interface.
- **YOLOv8** – For object detection.
- **MiDaS** – For monocular depth estimation.
- **pyttsx3** – For offline text-to-speech conversion.
- **Python (Flask)** – For hosting AI models on a separate server.
- **VPS Hosting** – For remote access to the AI server (was initially developed locally).

---

## 📱 App Features

- Real-time object detection and distance estimation.
- Voice feedback (offline).
- User-friendly and accessible UI.
- Operates entirely using camera input and software — no hardware sensors required.

---

## 📷 Screenshots

| Home Interface | Video Mode | Picture Mode |
|----------------|------------|---------------|
| [splash](https://github.com/user-attachments/assets/1f88d04f-5614-4d67-806c-f035966c8dbd)
hots/home.png) | ![Video](assets/screenshots/video.png) | ![Capture](assets/screenshots/capture.png) |


---

## 🚀 How It Works

1. The user opens the mobile app (Flutter-based).
2. A frame is captured from the camera.
3. The image is sent to a remote server (Python/Flask API).
4. The server:
   - Detects objects using **YOLOv8**.
   - Estimates distances using **MiDaS**.
   - Converts the result to text and speech (using **pyttsx3**).
5. The audio message is returned to the user in real-time.

---

## 🌐 Run the Server Locally (Optional)

If you want to run the AI backend server yourself:

### Requirements:
- Python 3.8+
- pip
- Flask
- YOLOv8 model (`yolov8.pt`)
- MiDaS model
- pyttsx3

### Steps:

```bash
git clone https://github.com/HashemMudahig/SeeingThroughSound.git
cd SeeingThroughSound/server
pip install -r requirements.txt
python app.py

