# Sensor Interfacing & Characterization Laboratory Suite
### Automated Data Acquisition (DAQ) & Signal Processing using MATLAB/Simulink

ชุดซอฟต์แวร์และแบบจำลองสำหรับการทดสอบ สอบเทียบ และวิเคราะห์คุณลักษณะของเซนเซอร์และวงจรประมวลผลสัญญาณทางวิศวกรรม โดยเชื่อมต่อฮาร์ดแวร์จริงผ่านการสื่อสารอนุกรมความเร็วสูง (High-Speed Serial Communication) เข้ากับแบบจำลอง Simulink และสคริปต์ควบคุมอัตโนมัติใน MATLAB

---

## 📌 ภาพรวมโครงสร้างของระบบ (System Architecture)

ระบบประกอบด้วย 2 ชั้นการทำงานหลัก:
1. **Simulink Modeling Layer (`.slx`):** รับสัญญาณดิจิทัล/แอนะล็อกแบบ Real-time ผ่านบล็อก `Host Serial Rx` (Baud rate 2,000,000 bps) ทำการปรับสภาพสัญญาณ (Gain Scaling, Moving Average, Simscape Physical Network) และส่งตัวแปรออกสู่ MATLAB Workspace
2. **MATLAB Scripting Layer (`.m` / `.mlx`):** สคริปต์ควบคุมการรัน (Test Executive), บันทึกข้อมูลดิบพร้อมประทับเวลา (Timestamped CSV), ปรับปรุงความคลาดเคลื่อน (Wrap-around / Homing), หาสมการสอบเทียบ (Linear Regression) และพล็อตกราฟเปรียบเทียบ

---

## 📂 โครงสร้าง Repository (Repository Structure)

```text
├── Lab1_1_Potentiometer/
│   ├── sensorExpoler_japan.slx         # โมเดล Simulink อ่านค่า ADC 3 ช่อง (A, B, C)
│   ├── data_poten_acquisition.m        # สคริปต์ลูปวัด 0-100% สเต็ปละ 5% พร้อม Live Plot
│   ├── lab1_1plot.mlx                  # สคริปต์ Batch Loading วิเคราะห์ Rotary vs Linear (MAE)
│   └── README.md                       # รายละเอียดเฉพาะของ Lab 1.1
│
├── Lab1_2_Hall_Effect/
│   ├── sensorExpoler_hall_sensor.slx   # โมเดลแปลง ADC เป็นฟลักซ์แม่เหล็ก (DRV5055)
│   ├── data_hall_acquisition.m         # สคริปต์วัดระยะ 0-3.4 cm และพล็อต 4 มิติ
│   └── README.md                       # รายละเอียดเฉพาะของ Lab 1.2
│
├── Lab1_3_Rotary_Encoder/
│   ├── sensorExpoler_encoder.slx       # โมเดลถอดรหัส Quadrature Counter (Mode X1/X4)
│   ├── data_encoder.m                  # สคริปต์ Auto-Guided & Wrap-around (AMT: 2048 PPR)
│   ├── data_encoder_BOURNS.m           # สคริปต์ทดสอบ Mechanical Encoder (Bourns: 24 PPR)
│   ├── data_encoder_Realtime.m         # สคริปต์ติดตามความเร็วและตำแหน่งต่อเนื่อง 30 วินาที
│   ├── homing_sequence.m               # สคริปต์ทดสอบระบบรีเซ็ตจุดอ้างอิงศูนย์ (Home Position)
│   └── README.md                       # รายละเอียดเฉพาะของ Lab 1.3
│
├── Lab1_4_Load_Cell/
│   ├── sensorExpoler_loadcell.slx      # โมเดลชั่งน้ำหนัก Real-time (Filter + Gain + Offset)
│   ├── data_loadcell.m                 # สคริปต์สอบเทียบ 0-10 kg และคำนวณสมการ y = mx + c
│   ├── data_loadcell_RealTime.m        # สคริปต์บันทึกค่าน้ำหนักต่อเนื่องแบบสั่งหยุดเอง
│   └── README.md                       # รายละเอียดเฉพาะของ Lab 1.4
│
├── Schmitt_Trigger_Lab/
│   ├── sensorExpoler_japan.slx         # โมเดล Simscape จำลองวงจร Schmitt Trigger
│   ├── schmitt_trigger_analysis.m      # สคริปต์วิเคราะห์ Time Domain & Hysteresis Loop
│   └── README.md                       # รายละเอียดเฉพาะของ Schmitt Trigger
│
└── README.md                           # สารบัญและคำแนะนำภาพรวม (ไฟล์นี้)