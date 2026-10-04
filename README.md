# FRA271 Robotic Modeling and Experimentation
### Laboratory Workspaces & Experimental Data Acquisition Suite
**จัดทำขึ้นเพื่อการส่งงานรายวิชา FRA271 Robotic Modeling and Experimentation**  
*Institute of Field Robotics (FIBO), King Mongkut's University of Technology Thonburi (KMUTT)*

---

## 📌 ภาพรวมโครงสร้างระบบ (System Architecture)

Repository นี้เป็นชุดรวมไฟล์แบบจำลอง Simulink (`.slx`) และสคริปต์ควบคุมการทดลองใน MATLAB (`.m` / `.mlx`) สำหรับการศึกษาคุณลักษณะ การสอบเทียบ และการต่อประสานฮาร์ดแวร์เซนเซอร์ประเภทต่างๆ ในวิชา FRA271 โดยระบบทำงานประสานกัน 2 ระดับ:

1. **Hardware Interfacing & Simulink Modeling Layer (`.slx`):**
   - รับสัญญาณแอนะล็อกและดิจิทัลจากบอร์ดไมโครคอนโทรลเลอร์ผ่านการสื่อสารอนุกรมความเร็วสูง (`Host Serial Rx`, Baud rate 2,000,000 bps)
   - การปรับสภาพสัญญาณเบื้องต้น (Signal Conditioning) เช่น Gain Scaling[cite: 80, 84, 93], Moving Average Filter และ Simscape Electrical Physical Domain
   - ส่งออกตัวแปรสัญญาณไปยัง MATLAB Workspace ผ่านบล็อก `To Workspace`[cite: 80, 84, 90, 93]

2. **Automated Test Executive & Analytics Layer (`.m` / `.mlx`):**
   - ควบคุมขั้นตอนการทดสอบแบบเป็นลำดับ (Step-by-step) และแบบนำทางอัตโนมัติ (Auto-Guided)
   - บันทึกข้อมูลดิบความละเอียดสูงพร้อมประทับเวลา (Timestamped CSV)[cite: 81, 82, 83, 85, 91, 92]
   - คำนวณค่าทางสถิติ ขจัดสัญญาณรบกวน (Noise Averaging)[cite: 81, 83, 91] และแก้ปัญหาขอบเขตตัวนับ (16-bit Timer Wrap-around)
   - สร้างสมการสอบเทียบเชิงเส้น (Linear Calibration: $y = mx + c$) และวิเคราะห์ Error (MAE / Linearity Curve)[cite: 72, 82, 83, 91]

---

## 📂 โครงสร้าง Repository (Directory Structure)

```text
├── Lab1_1_Potentiometer/
│   ├── sensorExpoler_potentiometer.slx   # โมเดล Simulink อ่านค่า ADC 3 ช่อง และวงจร Schmitt Trigger
│   ├── labpoten.m                        # สคริปต์ทดสอบ Potentiometer 0-100% สเต็ปละ 5% พร้อม Live Plot
│   ├── schmitt_trigger_lab.m             # สคริปต์วิเคราะห์ Schmitt Trigger (Time Domain & Hysteresis)
│   └── lab1_1plot.mlx                    # Live Script โหลดไฟล์ Batch วิเคราะห์เปรียบเทียบ Rotary vs Linear (MAE)
│
├── Lab1_2_Hall_Effect/
│   ├── sensorExpoler_hall_sensor.slx     # โมเดล Simulink แปลง ADC และคำนวณฟลักซ์แม่เหล็ก (DRV5055)
│   └── Data_hall_sensor.m                # สคริปต์วัดระยะ 0-3.4 cm (ทีละ 0.2 cm) และพล็อตกราฟวิเคราะห์ 4 Subplots
│
├── Lab1_3_Rotary_Encoder/
│   ├── sensorExpoler_encoder.slx         # โมเดลถอดรหัส Quadrature Counter, Wrap-around และ Homing Logic
│   ├── data_encoder.m                    # สคริปต์ Auto-Guided 15 สเต็ป (Optical AMT Encoder: 2048 PPR)
│   ├── data_encoder_BOURNS.m             # สคริปต์ Auto-Guided ทีละคลิก 15° (Mechanical Bourns: 24 PPR)
│   ├── data_encoder_Realtime.m           # สคริปต์รันต่อเนื่อง 30 วินาที วิเคราะห์พัลส์ มุมเรเดียน และความเร็วเชิงมุม
│   └── homing_sequence.m                 # สคริปต์ทดสอบสับสวิตช์ Set Home 2 ครั้ง เพื่อรีเซ็ตตำแหน่งศูนย์สัมพัทธ์
│
├── Lab1_4_Load_Cell/
│   ├── sensorExpoler_loadcell.slx        # โมเดลชั่งน้ำหนัก Real-time (Filter + Gain M + Offset C)
│   ├── data_loadcell.m                   # สคริปต์สอบเทียบ 0-10 kg, หาค่าเฉลี่ย 5 วิ และคำนวณสมการ y = mx + c
│   └── data_loadcell_RealTime.m          # สคริปต์ชั่งน้ำหนักแบบ Real-time ต่อเนื่อง เปรียบเทียบกับ Digital Scale
│
└── README.md                             # เอกสารสารบัญและภาพรวมการใช้งาน (ไฟล์นี้)