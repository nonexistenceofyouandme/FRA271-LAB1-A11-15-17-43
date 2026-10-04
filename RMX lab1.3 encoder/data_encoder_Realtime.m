% =========================================================================
% สคริปต์ Lab 1.3: Continuous Data (ดึงค่าจาก Simulink มาพล็อตเปรียบเทียบ)
% =========================================================================
clear; clc; close all;

model_name = 'sensorExpoler_encoder'; 
sim_time = 30; % ปรับเวลาทดลองเป็น 30 วินาที

fprintf('=== เก็บข้อมูล Real-time 30 วินาที ===\n');
fprintf('แผน: 0-15 วิ หมุนเดินหน้า (CW) | 15-30 วิ หมุนกลับ (CCW)\n');
fprintf('เตรียมตัวจับ Encoder... 3... 2... 1...\n');
pause(3);

% สั่งรัน Simulink 30 วินาที (Simulink จะคำนวณและเก็บค่าลงตัวแปรให้เอง)
fprintf('>> กำลังบันทึกข้อมูล (เริ่มหมุนได้เลย!)...\n');
out = sim(model_name, 'StopTime', num2str(sim_time));
fprintf('>> สิ้นสุดการบันทึก!\n');

% -------------------------------------------------------------------------
% ดึงข้อมูลที่ Simulink คำนวณเสร็จแล้วจาก Workspace
% -------------------------------------------------------------------------
try
    t = out.tout;
    pos_pulse = squeeze(double(out.pos_pulse));
    pos_rad   = squeeze(double(out.pos_rad));
    vel_rad   = squeeze(double(out.vel_rad));
catch
    % รองรับกรณีไม่ได้เซฟข้อมูลรวมใน out
    t = evalin('base', 'tout');
    pos_pulse = squeeze(double(evalin('base', 'pos_pulse')));
    pos_rad   = squeeze(double(evalin('base', 'pos_rad')));
    vel_rad   = squeeze(double(evalin('base', 'vel_rad')));
end

% กรอง Noise เริ่มต้นของความเร็วที่อาจพุ่งสูงผิดปกติ (Spike) ตอนเปิดเชื่อมต่อ
vel_rad(abs(vel_rad) > 100) = 0; 

% -------------------------------------------------------------------------
% พล็อตกราฟผลลัพธ์
% -------------------------------------------------------------------------
figure('Name', 'Encoder Real-Time Analysis', 'Position', [100, 50, 800, 700]);

% กราฟ 1: Relative Position (Pulses)
subplot(3,1,1);
plot(t, pos_pulse, 'k', 'LineWidth', 1.5);
title('Relative Position (Pulses)');
ylabel('Pulses');
grid on; ax = gca; ax.GridAlpha = 0.5;

% กราฟ 2: Angular Position (Radians)
subplot(3,1,2);
plot(t, pos_rad, 'b', 'LineWidth', 1.5);
title('Angular Position (Radians)');
ylabel('Radians');
grid on; ax = gca; ax.GridAlpha = 0.5;

% กราฟ 3: Angular Velocity (rad/s)
subplot(3,1,3);
plot(t, vel_rad, 'r', 'LineWidth', 1.2);
title('Angular Velocity (rad/s) - วิเคราะห์คุณภาพสัญญาณ');
xlabel('Time (s)');
ylabel('Velocity (rad/s)');
grid on; ax = gca; ax.GridAlpha = 0.5;

% บันทึกผลลง CSV สำหรับทำรายงาน
results_table = table(t, pos_pulse, pos_rad, vel_rad, ...
    'VariableNames', {'Time_s', 'Relative_Pulses', 'Position_Rad', 'Velocity_Rad_s'});
writetable(results_table, 'Lab1_3_RealtimeData_30s.csv');
fprintf('>> บันทึกไฟล์ Lab1_3_RealtimeData_30s.csv เรียบร้อย\n');