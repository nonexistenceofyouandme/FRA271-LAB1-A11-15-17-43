# Lab 1.1: Potentiometer Response & Schmitt Trigger Characterization

ชุดทดลองศึกษาการตอบสนองแรงดันไฟฟ้าของตัวต้านทานปรับค่าได้ (Potentiometer) และคุณลักษณะการทำงานของวงจรชมิตต์ทริกเกอร์ (Schmitt Trigger) โดยเชื่อมต่อฮาร์ดแวร์จริงเข้ากับแบบจำลอง Simulink และควบคุมการทดสอบด้วยสคริปต์ MATLAB

---

## 📁 รายการไฟล์ในโฟลเดอร์ (File Inventory)

| ชื่อไฟล์ | หน้าที่การทำงาน |
| :--- | :--- |
| `sensorExpoler_japan.slx` | แบบจำลอง Simulink รับสัญญาณอนุกรม (Serial COM) แปลงสเกลแรงดัน $0 - 3.3\text{ V}$ และจำลองวงจร Simscape Schmitt Trigger |
| `labpoten.m` | สคริปต์ควบคุมการวัดตำแหน่ง Potentiometer 0–100% (สเต็ปละ 5%), บันทึก CSV รายสเต็ป, พล็อต Real-time และสรุป Array |
| `schmitt_trigger_lab.m` | สคริปต์สั่งรันโมเดล 20 วินาทีอัตโนมัติ เพื่อวิเคราะห์รูปคลื่นในโดเมนเวลาและวงรอบ Hysteresis Loop ของ Schmitt Trigger |

---

## ⚙️ ขั้นตอนการรันการทดลอง (How to Run)

### 1. การทดลอง Potentiometer (`labpoten.m`)
1. เปิดโมเดล `sensorExpoler_japan.slx` และตรวจสอบว่าบล็อก `Host Serial Setup` เชื่อมต่อพอร์ต COM ถูกต้อง
2. รันสคริปต์ `labpoten.m` ใน MATLAB Command Window
3. ปฏิบัติตามคำแนะนำบนหน้าจอ: หมุนตัวต้านทานไปยังเปอร์เซ็นต์ที่ระบุ -> กด Run ใน Simulink (5 วินาที) -> กด Enter ใน Command Window เพื่อบันทึกข้อมูล
4. ระบบจะอัปเดตกราฟสด และเมื่อครบ 100% จะบันทึกไฟล์สรุป `Simulink_Poten_Summary.mat` และ `Poten_Arrays_*.txt` โดยอัตโนมัติ

### 2. การทดลอง Schmitt Trigger (`schmitt_trigger_lab.m`)
1. รันสคริปต์ `schmitt_trigger_lab.m`
2. เมื่อขึ้นข้อความแจ้งเตือน ให้กด Enter เพื่อเริ่มการทดสอบ (ระบบจะสั่งรัน Simulink อัตโนมัติเป็นเวลา 20 วินาที)
3. ในระหว่าง 20 วินาที ให้ค่อยๆ หมุน Potentiometer ไปและกลับอย่างสม่ำเสมอ
4. สคริปต์จะบันทึกข้อมูลดิบลง `Schmitt_Data_*.csv` และแสดงหน้าต่างกราฟวิเคราะห์ Time Domain และ Hysteresis Loop เปรียบเทียบกับ Threshold ทางทฤษฎี ($V_{TH} = 1.3\text{ V}, V_{TL} = 0.7\text{ V}$) ทันที