% =========================================================================
% สคริปต์เก็บข้อมูล Lab 1.3 สำหรับ BOURNS Encoder (หมุนทีละ 1 คลิก / 2 วิ)
% =========================================================================
clear; clc; close all;

% 1. ลำดับองศาที่ต้องการทดลอง (0, -15, -30, -15, 0, 15, ..., 390)
target_angles = [0, -15, -30, -15, 0:15:390];
num_points = length(target_angles);

model_name = 'sensorExpoler_encoder'; % ชื่อไฟล์ Simulink

% สร้าง Array สำหรับจดเวลาและค่า
snap_time = zeros(num_points, 1);
avg_raw   = zeros(num_points, 1);

fprintf('=== โปรแกรมเก็บข้อมูล Lab 1.3: BOURNS Encoder (เวลาปกติ 2 วิ) ===\n');
fprintf('เตรียมตัวจับ BOURNS ไว้ที่ 0 องศา (คลิกแรก)\n\n');

% เช็คว่าเปิดโมเดลไว้หรือยัง ถ้ายังให้เปิดขึ้นมา
if ~bdIsLoaded(model_name)
    open_system(model_name);
end

% 2. สั่งรัน Simulink ต่อเนื่อง
set_param(model_name, 'StopTime', 'inf');
set_param(model_name, 'SimulationCommand', 'start');
fprintf('ระบบกำลังสตาร์ท... รอ 3 วินาที\n');
pause(3); 

% 3. ลูปกำกับการหมุน
for i = 1:num_points
    fprintf('\n>> Step %d/%d: หมุน BOURNS ไปที่ [%d องศา]\n', i, num_points, target_angles(i));
    
    fprintf('ขยับได้ (2 วิ)... ');
    pause(2); % กลับมาใช้เวลา 2 วินาที เพื่อให้หมุนลงล็อกพอดี
    
    fprintf('ถือนิ่งๆ (2 วิ)... ');
    pause(2); % ถือนิ่ง 2 วินาที ให้สัญญาณเสถียร
    
    % จดเวลาปัจจุบันของ Simulink
    snap_time(i) = get_param(model_name, 'SimulationTime');
    fprintf('-> แชะ! บันทึกเวลาเรียบร้อย\n');
end

% 4. สั่งหยุดการจำลอง
fprintf('\n>> เก็บครบ %d จุดแล้ว! สั่งหยุด Simulink...\n', num_points);
set_param(model_name, 'SimulationCommand', 'stop');
pause(2); 

% =========================================================================
% 5. ค้นหาค่าและคำนวณ Wrap-around
% =========================================================================
try
    sim_out = evalin('base', 'out');
    if isprop(sim_out, 'tout')
        full_time = sim_out.tout;
    else
        full_time = sim_out.time_data;
    end
    full_raw = sim_out.raw_count;
catch
    full_raw = evalin('base', 'raw_count');
    try full_time = evalin('base', 'tout'); catch, full_time = evalin('base', 'time_data'); end
end

% ป้องกัน Error จาก timeseries format
if isa(full_raw, 'timeseries')
    full_raw = squeeze(double(full_raw.Data));
else
    full_raw = squeeze(double(full_raw));
end

for i = 1:num_points
    [~, idx] = min(abs(full_time - snap_time(i)));
    avg_raw(i) = full_raw(idx);
end

unwrap_count = zeros(num_points, 1);
unwrap_count(1) = avg_raw(1);
for k = 2:num_points
    delta = avg_raw(k) - avg_raw(k-1);
    % ดักการกระโดดของ Timer 16-bit (65535)
    if delta < -32768
        delta = delta + 65536;
    elseif delta > 32768
        delta = delta - 65536;
    end
    unwrap_count(k) = unwrap_count(k-1) + delta;
end

% =========================================================================
% 6. แปลงเป็นองศา (ตั้งค่า PPR ของ BOURNS)
% =========================================================================
% BOURNS มี 24 PPR
PPR = 24; 
MODE = 1; % ตั้งเป็น 4X ให้เลยตามที่คุณใช้งานได้ตอนนี้
TOTAL_PULSES_PER_REV = PPR * MODE; 

measured_degree = (unwrap_count / TOTAL_PULSES_PER_REV) * 360; 

% =========================================================================
% 7. สรุปผล สร้างตาราง และกราฟ
% =========================================================================
results_table = table(target_angles', avg_raw, unwrap_count, measured_degree, ...
    'VariableNames', {'Target_Degree', 'Raw_Count', 'Unwrapped_Count', 'Measured_Degree'});

disp('======================================================');
disp('สรุปผลการทดลอง:');
disp(results_table);

csv_filename = 'Lab1_3_Bourns_Encoder_NormalSpeed.csv';
writetable(results_table, csv_filename);
fprintf('>> บันทึกไฟล์ "%s" เรียบร้อยแล้ว\n', csv_filename);

% พล็อตกราฟผลลัพธ์
figure('Name', 'BOURNS Encoder Step Response', 'Position', [150, 150, 1000, 500]);
plot(1:num_points, target_angles, '--k', 'LineWidth', 1.5); hold on;
plot(1:num_points, measured_degree, '-rs', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
title(['BOURNS Encoder Linearity (Mode X', num2str(MODE), ') - Normal Speed']);
xlabel('Measurement Step Sequence');
ylabel('Angular Position (Degrees)');
legend('Target Angle (ทฤษฎี)', 'Measured Angle (วัดได้จริง)', 'Location', 'NorthWest');

yticks(-45:45:405);
grid on;
ax = gca; ax.GridAlpha = 0.6; ax.GridLineStyle = '--';