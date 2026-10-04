% =========================================================================
% สคริปต์เก็บข้อมูล Lab 1.3 แบบ Auto-Guided (ทำงานต่อเนื่อง ไม่ค้าง 100%)
% =========================================================================
clear; clc; close all;

% 1. ลำดับองศาที่ต้องการทดลอง (ทดสอบกลับทิศ และล้นรอบ)
target_angles = [0, -45, -90, -45, 0, 45, 90, 135, 180, 225, 270, 315, 360, 405, 450];
num_points = length(target_angles);

model_name = 'sensorExpoler_encoder'; 

% สร้าง Array สำหรับจดเวลาและค่า
snap_time = zeros(num_points, 1);
avg_raw   = zeros(num_points, 1);

fprintf('=== โปรแกรมเก็บข้อมูล Lab 1.3 (Auto-Guided) ===\n');
fprintf('เตรียมตัวจับ Encoder ไว้ที่ 0 องศา\n');
fprintf('โปรแกรมจะบอกให้ขยับทีละสเตป และบันทึกค่าให้เองอัตโนมัติ!\n\n');

% เช็คว่าเปิดโมเดลไว้หรือยัง ถ้ายังให้เปิดขึ้นมา
if ~bdIsLoaded(model_name)
    open_system(model_name);
end

% 2. สั่งรัน Simulink ให้ทำงานยาวๆ (รันเป็นฉากหลัง ไม่ต้องหยุด)
set_param(model_name, 'StopTime', 'inf');
set_param(model_name, 'SimulationCommand', 'start');
fprintf('ระบบกำลังสตาร์ท... รอ 3 วินาที\n');
pause(3); 

% 3. ลูปกำกับการหมุน (ให้คนทำตามสคริปต์)
for i = 1:num_points
    fprintf('\n>> Step %d/%d: รีบหมุนไปที่ [%d องศา] \n', i, num_points, target_angles(i));
    fprintf('ขยับได้ (2 วิ)... ');
    pause(2); % ให้เวลาคนขยับ
    
    fprintf('ถือนิ่งๆ ไว้ (2 วิ)... ');
    pause(2); % ให้เวลามือนิ่ง สัญญาณจะได้เสถียร
    
    % จดเวลาปัจจุบันของ Simulink ทันทีที่ครบกำหนด
    snap_time(i) = get_param(model_name, 'SimulationTime');
    fprintf('-> บันทึกเรียบร้อย!\n');
end

% 4. สั่งหยุดการจำลอง
fprintf('\n>> เก็บครบแล้ว! สั่งหยุด Simulink และกำลังประมวลผล...\n');
set_param(model_name, 'SimulationCommand', 'stop');
pause(2); % รอข้อมูลไหลลง Workspace ให้ครบ

% =========================================================================
% 5. ค้นหาค่าและคำนวณ Wrap-around
% =========================================================================
% ดึงข้อมูลจาก Workspace 
try
    % กรณีมีตัวแปร out ออกมาตัวเดียว
    sim_out = evalin('base', 'out');
    if isprop(sim_out, 'tout')
        full_time = sim_out.tout;
    else
        full_time = sim_out.time_data;
    end
    full_raw = sim_out.raw_count;
catch
    % กรณีตัวแปรกระจายใน Workspace ปกติ
    full_raw = evalin('base', 'raw_count');
    try full_time = evalin('base', 'tout'); catch, full_time = evalin('base', 'time_data'); end
end

if isa(full_raw, 'timeseries')
    full_raw = squeeze(double(full_raw.Data));
else
    full_raw = squeeze(double(full_raw));
end

% ค้นหาค่า Raw Count ณ เวลาที่เรา "แชะ" ภาพไว้
for i = 1:num_points
    [~, idx] = min(abs(full_time - snap_time(i)));
    avg_raw(i) = full_raw(idx);
end

% โค้ดแก้ Wrap-around 
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

% 6. แปลงเป็นองศา 
% *** ค่า 2048 สำหรับโหมด X1 และดิปสวิตช์เดิม *** 24
TOTAL_PULSES_PER_REV = (2048*4); 
measured_degree = -(unwrap_count / TOTAL_PULSES_PER_REV) * 360; 

% =========================================================================
% 7. สรุปผล สร้างตาราง และกราฟ
% =========================================================================
results_table = table(target_angles', avg_raw, unwrap_count, measured_degree, ...
    'VariableNames', {'Target_Degree', 'Raw_Count', 'Unwrapped_Count', 'Measured_Degree'});

disp('======================================================');
disp('สรุปผลการทดลอง:');
disp(results_table);

csv_filename = 'Lab1_3_Encoder_AutoGuided.csv';
writetable(results_table, csv_filename);
fprintf('>> บันทึกไฟล์ "%s" เรียบร้อยแล้ว\n', csv_filename);

% พล็อตกราฟผลลัพธ์
figure('Name', 'Encoder Step Response (Auto Guided)', 'Position', [100, 100, 1000, 500]);
plot(1:num_points, target_angles, '--k', 'LineWidth', 1.5); hold on;
plot(1:num_points, measured_degree, '-bo', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
title('Encoder Linearity (Auto-Guided Method)');
xlabel('Measurement Step Sequence');
ylabel('Angular Position (Degrees)');
legend('Target Angle (ทฤษฎี)', 'Measured Angle (วัดได้จริง)', 'Location', 'NorthWest');
yticks(-90:45:450);
grid on;
ax = gca; ax.GridAlpha = 0.6; ax.GridLineStyle = '--';