% =========================================================================
% สคริปต์เก็บข้อมูล Lab 1.4: Real-time Weight Measurement (แบบสั่งหยุดเอง)
% สำหรับเก็บข้อมูลไปเปรียบเทียบเครื่องชั่ง Digital และวิเคราะห์ Error
% =========================================================================
clear; clc; close all;

% แก้ไขชื่อไฟล์ Simulink ของคุณตรงนี้
model_name = 'sensorExpoler_loadcell'; 

fprintf('=== โปรแกรมบันทึกค่าน้ำหนัก Real-time (รันต่อเนื่อง) ===\n');
fprintf('แผนการทดลองเพื่อเก็บคะแนนเปรียบเทียบ Digital Scale:\n');
fprintf('1. เตรียมสิ่งของหรือถุงทราย 3-4 น้ำหนัก ที่ผ่านการชั่งด้วยเครื่องชั่ง Digital มาแล้ว\n');
fprintf('2. ระหว่างที่โปรแกรมรัน ให้ทยอยนำของมาวางบน Load Cell ทีละชิ้น\n');
fprintf('3. แนะนำให้วางแช่ไว้ชิ้นละ 10-15 วินาที แล้วค่อยเปลี่ยนชิ้น เพื่อให้กราฟนิ่ง\n\n');

% เช็คว่าเปิดโมเดลไว้หรือยัง
if ~bdIsLoaded(model_name)
    open_system(model_name);
end

input('*** พร้อมแล้วกด Enter เพื่อเริ่มบันทึกข้อมูล Real-time ***', 's');

% 1. บังคับตั้งค่า Stop Time เป็น inf เพื่อให้รันต่อเนื่องไปเรื่อยๆ
set_param(model_name, 'StopTime', 'inf');

% 2. สั่งรันโมเดล Simulink
fprintf('\n>> ระบบกำลังบันทึกข้อมูลแบบต่อเนื่อง... (เริ่มวางของได้เลย!)\n');
set_param(model_name, 'SimulationCommand', 'start');

% 3. รอรับคำสั่งหยุดจากผู้ใช้
user_cmd = '';
while ~strcmpi(user_cmd, 'q')
    user_cmd = input('*** พิมพ์ q แล้วกด Enter เมื่อต้องการ "หยุด" ทดลองและบันทึกไฟล์: ', 's');
end

% 4. สั่งหยุดการจำลอง
set_param(model_name, 'SimulationCommand', 'stop');
fprintf('\n>> หยุดการทดลองเรียบร้อยแล้ว กำลังประมวลผลดึงข้อมูลมาทำ CSV...\n');

% หน่วงเวลา 2 วินาที ให้ระบบส่งข้อมูลจาก Simulink มายัง MATLAB Workspace จนครบ
pause(2); 

% =========================================================================
% 5. ดึงข้อมูลน้ำหนัก Real-time จาก Workspace
% =========================================================================
try
    % รองรับกรณีข้อมูลอยู่ใน simOut หรือ Base Workspace
    if evalin('base', 'exist(''out'', ''var'')') && evalin('base', 'isprop(out, ''weight_kg'')')
        w_ts = evalin('base', 'out.weight_kg');
    else
        w_ts = evalin('base', 'weight_kg');
    end
    
    % แยกเวลาและค่าน้ำหนัก
    t = w_ts.Time;
    weight_val = squeeze(double(w_ts.Data));
    
catch ME
    fprintf('\n[Error]: ไม่พบตัวแปร "weight_kg" หรือดึงข้อมูลไม่ได้\n');
    fprintf('วิธีแก้: โปรดเช็คใน Simulink ว่ามีบล็อก To Workspace ตั้งชื่อ "weight_kg" ชนิด timeseries แล้ว\n');
    fprintf('ข้อความ Error: %s\n', ME.message);
    return;
end

% =========================================================================
% 6. สร้างตารางและบันทึกเป็น CSV
% =========================================================================
results_table = table(t, weight_val, 'VariableNames', {'Time_sec', 'Measured_Weight_kg'});
csv_filename = 'Lab1_4_Realtime_Continuous.csv';
writetable(results_table, csv_filename);
fprintf('>> บันทึกไฟล์ข้อมูล "%s" เรียบร้อยแล้ว (เก็บไปทั้งหมด %d จุด)\n', csv_filename, length(t));

% =========================================================================
% 7. พล็อตกราฟผลลัพธ์ (Output เป็นน้ำหนัก ในหน่วย SI Derived)
% =========================================================================
figure('Name', 'Continuous Real-time Load Cell Measurement', 'Position', [150, 150, 1000, 500]);
plot(t, weight_val, 'b', 'LineWidth', 1.5);
hold on; grid on;

% ตกแต่งกราฟ
title('Continuous Real-time Load Cell Measurement (SI Derived Unit: kg)', 'FontSize', 14);
xlabel('Time (Seconds)', 'FontSize', 12);
ylabel('Measured Weight (kg)', 'FontSize', 12);

% หาค่าสูงสุดเพื่อตั้งเพดานกราฟให้สวยงาม (เผื่อวางเกิน 10 kg)
max_w = max(weight_val);
if max_w < 11
    ylim([-0.5 11]);
    yticks(0:1:11);
else
    ylim([-0.5 ceil(max_w)+1]);
end

ax = gca; 
ax.GridAlpha = 0.5; 
ax.GridLineStyle = '--';

% เติมเส้นอ้างอิงที่ 0 kg เพื่อให้ดูง่ายขึ้น
yline(0, 'r-', 'LineWidth', 1.5);

hold off;