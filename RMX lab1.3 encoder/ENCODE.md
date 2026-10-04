# Lab 1.3: Rotary Encoder Linearity, Dynamic Tracking & Homing Sequence

ชุดทดลองศึกษาคุณลักษณะของตัวเข้ารหัสสัญญาณการหมุน (Quadrature Rotary Encoder) ทั้งแบบ Optical ความละเอียดสูง (AMT203: 2048 PPR) และแบบ Mechanical (Bourns: 24 PPR) ครอบคลุมการแก้ปัญหา 16-bit Timer Wrap-around, การติดตามความเร็วเชิงมุมแบบ Real-time และระบบกำหนดจุดอ้างอิงศูนย์ (Homing Sequence)

---

## 📁 รายการไฟล์ในโฟลเดอร์ (File Inventory)

| ชื่อไฟล์ | ฮาร์ดแวร์ที่ใช้ | หน้าที่การทำงาน |
| :--- | :--- | :--- |
| `sensorExpoler_encoder.slx` | AMT / Bourns | แบบจำลอง Simulink ถอดรหัสสัญญาณ Quadrature Decoder, บล็อกชดเชย Wrap-around, คำนวณความเร็ว และประมวลผล Homing |
| `data_encoder.m` | Optical AMT (2048 PPR) | สคริปต์ Auto-Guided 15 สเต็ป (ทดสอบหมุนกลับทิศและล้น 360°), แก้ Wrap-around 16-bit และวิเคราะห์ Linearity |
| `data_encoder_BOURNS.m` | Mechanical Bourns (24 PPR) | สคริปต์ Auto-Guided ปรับสเต็ปการหมุนทีละคลิก (15°/คลิก) ตั้งแต่ -30° ถึง 390° เพื่อทดสอบความแม่นยำเชิงกล |
| `data_encoder_Realtime.m` | AMT / Bourns | สคริปต์รันต่อเนื่อง 30 วินาที (CW 15 วิ / CCW 15 วิ) พล็อตกราฟเปรียบเทียบ Pulses, Radians และ Velocity (rad/s) |
| `homing_sequence.m` | AMT / Bourns | สคริปต์ทดสอบสับสวิตช์ Set Home 2 รอบ (ที่วินาทีที่ 5 และ 12) เพื่อวิเคราะห์การหักลบ Offset และรีเซ็ตมุมสัมพัทธ์สู่ 0° |

---

## ⚙️ ขั้นตอนการรันการทดลอง (How to Run)

### 1. ทดสอบ Linearity แบบ Auto-Guided (`data_encoder.m` หรือ `data_encoder_BOURNS.m`)
1. เปิดโมเดล `sensorExpoler_encoder.slx` และตรวจสอบการเชื่อมต่อพอร์ต Serial (`COM3`, Baud rate 2,000,000 bps)
2. รันสคริปต์ `data_encoder.m` (สำหรับ AMT) หรือ `data_encoder_BOURNS.m` (สำหรับ Bourns)
3. ระบบจะสั่งรัน Simulink ต่อเนื่องในพื้นหลัง (Background)
4. ปฏิบัติตามจังหวะบนหน้าจอ: สคริปต์จะให้เวลาหมุน 2 วินาที และถือนิ่ง 2 วินาทีในแต่ละองศาเป้าหมายจนครบทุกสเต็ป
5. สคริปต์จะสั่งหยุด Simulink อัตโนมัติ แก้ปัญหา Wrap-around ส่งออกไฟล์ CSV และแสดงผลกราฟ Linearity ทันที

### 2. วิเคราะห์สัญญาณต่อเนื่องและความเร็ว (`data_encoder_Realtime.m`)
1. รันสคริปต์ `data_encoder_Realtime.m`
2. ระบบจะนับถอยหลัง 3 วินาที และเริ่มบันทึกข้อมูลเป็นเวลา 30 วินาที:
   - ช่วง 0–15 วินาที: ค่อยๆ หมุน Encoder ไปข้างหน้าตามเข็มนาฬิกา (CW)
   - ช่วง 15–30 วินาที: หมุนย้อนกลับทวนเข็มนาฬิกา (CCW)
3. เมื่อครบ 30 วินาที สคริปต์จะเปิดหน้าต่างกราฟ 3 Subplots (Pulses, Radians, Velocity) และบันทึกลง `Lab1_3_RealtimeData_30s.csv`

### 3. ทดสอบระบบ Set Home (`homing_sequence.m`)
1. วางหน้าต่าง MATLAB และ Simulink คู่กันเพื่อให้กดสวิตช์ได้สะดวก
2. รันสคริปต์ `homing_sequence.m` (เวลารันรวม 20 วินาที)
3. ปฏิบัติตามคำสั่ง: เริ่มหมุน Encoder ไปเรื่อยๆ -> เมื่อครบ 5 วินาที ให้ดับเบิลคลิกสับสวิตช์ `Manual Switch` บน Simulink (Set Home ครั้งที่ 1) -> หมุนต่อจนถึงวินาทีที่ 12 ให้สับสวิตช์อีกครั้ง (Set Home ครั้งที่ 2)
4. สคริปต์จะตรวจจับขอบสัญญาณ พล็อตกราฟเปรียบเทียบองศาดิบกับองศาเทียบกับจุด Home พร้อมมาร์กเกอร์สีแดง และบันทึกลง `Lab1_3_HomingSequence_2Rounds.csv`