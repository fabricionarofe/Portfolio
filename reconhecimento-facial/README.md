# 👁️ Reconhecimento Facial — Facial Recognition System

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![OpenCV](https://img.shields.io/badge/OpenCV-5C3EE8?style=flat-square&logo=opencv&logoColor=white)](https://opencv.org)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)](#)

> A Computer Vision application that uses facial recognition to identify individuals and control access in physical environments. Built with Python, OpenCV, and the ace_recognition library.

---

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [How It Works](#-how-it-works)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [How to Run](#-how-to-run)
- [Technical Highlights](#-technical-highlights)

---

## 📌 About the Project

This project implements a real-time biometric identification system using facial recognition. The core idea is to provide an automated mechanism for verifying identities without physical credentials (cards, badges, or PINs), using only the camera feed.

**Real-world use case:** Designed for environments requiring controlled physical access — such as offices, labs, or government buildings — where knowing *who* is entering is as important as *when* they enter.

**Key capabilities:**
- Real-time face detection from a live camera feed.
- Comparison of detected faces against a pre-registered database of known individuals.
- Identification result logged with timestamp and subject name.
- Clear visual feedback on screen (bounding box + name label).

---

## ⚙️ How It Works

`
[Camera Feed] → [Face Detection (OpenCV)] → [Encoding Extraction] → [Database Comparison] → [Match / No Match]
`

1. **Frame Capture:** Each frame from the webcam is read continuously.
2. **Face Detection:** OpenCV locates face regions within each frame.
3. **Encoding:** The ace_recognition library converts each face into a 128-dimension numeric vector.
4. **Matching:** This vector is compared against pre-stored encodings using Euclidean distance.
5. **Output:** If a match is found above the confidence threshold, the person is identified on screen.

---

## 📁 Project Structure

`
reconhecimento-facial/
│
├── src/               # Core recognition engine (detection, encoding, matching)
├── docs/              # Architecture diagrams and technical documentation
├── outros/            # Auxiliary scripts (e.g., face registration utility)
│
├── requirements.txt   # Python dependencies
├── __version__.py     # Semantic versioning
├── .gitignore         # Excludes model files and local data
└── README.md          # This file
`

---

## ✅ Prerequisites

- **Python 3.8+**
- **pip**
- **A webcam** (or a video file for testing)
- **cmake** — Required to build dlib
  - Windows: [cmake.org](https://cmake.org/download/)
  - Linux: sudo apt-get install cmake
- **Visual C++ Build Tools** (Windows only) — [Download here](https://visualstudio.microsoft.com/visual-cpp-build-tools/)

---

## 📦 Installation & Setup

**Step 1 — Clone the repository:**
`ash
git clone https://github.com/fabricionarofe/portfolio.git
cd portfolio/reconhecimento-facial
`

**Step 2 — Create and activate a virtual environment:**
`ash
python -m venv venv
venv\Scripts\activate   # Windows
# source venv/bin/activate  # Linux/macOS
`

**Step 3 — Install dependencies:**
`ash
pip install -r requirements.txt
`
> ⚠️ **Note:** Installing dlib and ace_recognition may take several minutes as they compile native C++ code.

**Step 4 — Register known faces:**

Place one clear, front-facing photo per person in the designated folder, then run the registration utility to generate the encoding database.

---

## ▶️ How to Run

`ash
python src/__main__.py
`

A window will open showing the live camera feed with face detection overlays. Press Q to quit.

---

## 🔬 Technical Highlights

- **128-Dimension Face Encodings:** Uses dlib's ResNet deep learning model under the hood for robust face encodings resistant to lighting and angle variation.
- **Threshold-Based Matching:** Uses a configurable tolerance distance instead of a hard yes/no comparison.
- **Modular Design:** Detection, encoding, and matching logic are cleanly separated.
- **100% Local Processing:** No data is sent to any external server — critical for privacy-sensitive environments.
