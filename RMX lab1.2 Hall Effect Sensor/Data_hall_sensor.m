% =========================================================================
% สคริปต์เก็บข้อมูล Lab 1.2 Magnetic Sensor (0-3.4 cm, Step 0.2, Fast Enter)
% =========================================================================
clear; clc; close all;

% 1. ตั้งค่าพารามิเตอร์การทดลอง
distances = 0:0.2:3.4;      % ระยะห่างตั้งแต่ 0 ถึง 3.4 cm ขยับทีละ 0.2 cm
num_points = length(distances);
sim_time = 5;               % รัน Simulink 5 วินาทีต่อ 1 ระยะ
model_name = 'sensorExpoler_hall_sensor'; % *** แก้ไขชื่อนี้ให้ตรงกับไฟล์ .slx ของคุณ ***

% 2. สร้าง Array ว่างสำหรับเก็บค่าเฉลี่ยใน Workspace
avg_raw  = zeros(num_points, 1);
avg_vout = zeros(num_points, 1);
avg_B    = zeros(num_points, 1);

fprintf('=== เริ่มต้นโปรแกรมเก็บข้อมูล Lab 1.2 Magnetic Sensor ===\n');
fprintf('อย่าลืมตั้งค่า To Workspace (raw_data, vout_data, b_data) ใน Simulink ให้เป็น Array\n\n');

% 3. วนลูปเก็บข้อมูลตามระยะทาง
for i = 1:num_points
    fprintf('------------------------------------------------------\n');
    fprintf('จุดที่ %d/%d: กรุณาปรับระยะแม่เหล็กไปที่ระยะ %.1f cm\n', i, num_points, distances(i));
    
    % รอรับคำสั่ง
    user_cmd = input('*** ปรับระยะเสร็จแล้ว กด Enter เพื่อเก็บข้อมูล (หรือพิมพ์ q เพื่อยกเลิก): ', 's');
    
    if strcmpi(user_cmd, 'q')
        fprintf('>> ยกเลิกการทดลองโดยผู้ใช้\n');
        return; % ออกจากโปรแกรมทันที
    end
    
    fprintf('กำลังเก็บข้อมูล %d วินาที... ', sim_time);
    
    % สั่งรัน Simulink model
    out = sim(model_name, 'StopTime', num2str(sim_time));
    fprintf('เสร็จสิ้น!\n');
    
    % ดึงข้อมูล
    if isprop(out, 'raw_data')
        raw_array = out.raw_data;
        vout_array = out.vout_data;
        b_array = out.b_data;
    else
        raw_array = out.get('raw_data');
        vout_array = out.get('vout_data');
        b_array = out.get('b_data');
    end
    
    % 4. คำนวณหาค่าเฉลี่ยและบันทึกลง Array ทันที
    avg_raw(i) = mean(raw_array);
    avg_vout(i) = mean(vout_array);
    avg_B(i) = mean(b_array);
    
    fprintf('ผลลัพธ์เฉลี่ย -> Raw: %6.1f | Vout: %6.2f mV | B: %6.2f mT\n', ...
            avg_raw(i), avg_vout(i), avg_B(i));
    fprintf('>> บันทึกข้อมูลจุดที่ %d (ระยะ %.1f cm) เรียบร้อย\n', i, distances(i));
end

% 6. สรุปผลและสร้างเป็น Table
results_table = table(distances', avg_raw, avg_vout, avg_B, ...
    'VariableNames', {'Distance_cm', 'Raw_ADC', 'V_out_mV', 'B_mT'});

disp('======================================================');
disp('สรุปผลการทดลองทั้งหมด:');
disp(results_table);

% 7. บันทึกข้อมูลลงไฟล์ CSV และ TXT
csv_filename = 'Lab1_2_Magnetic_Results.csv';
writetable(results_table, csv_filename);
fprintf('>> บันทึกข้อมูลลงไฟล์ "%s" เรียบร้อยแล้ว\n', csv_filename);

txt_filename = 'Lab1_2_Magnetic_Results.txt';
writetable(results_table, txt_filename, 'Delimiter', '\t');
fprintf('>> บันทึกข้อมูลลงไฟล์ "%s" เรียบร้อยแล้ว\n', txt_filename);

% =========================================================================
% 8. พล็อตกราฟเบื้องต้น (4 Subplots แยกกัน)
% =========================================================================
figure('Name', 'Magnetic Sensor Lab 1.2 Results', 'Position', [100, 100, 1200, 800]);

% กราฟที่ 1: ความหนาแน่นสนามแม่เหล็ก (mT) vs ระยะทาง (cm)
subplot(2,2,1);
plot(distances, avg_B, '-bo', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
title('Magnetic Flux Density vs Distance');
xlabel('Distance (cm)');
ylabel('Magnetic Flux Density (mT)');
grid on;

% กราฟที่ 2: แรงดันไฟฟ้า (mV) vs ระยะทาง (cm)
subplot(2,2,2);
plot(distances, avg_vout, '-gs', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'g');
title('Output Voltage vs Distance');
xlabel('Distance (cm)');
ylabel('Output Voltage (mV)');
grid on;

% กราฟที่ 3: ข้อมูลดิบ (Raw Data) vs ระยะทาง (cm)
subplot(2,2,3);
plot(distances, avg_raw, '-md', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'm');
title('Raw ADC Data vs Distance');
xlabel('Distance (cm)');
ylabel('Raw ADC (0-4095)');
grid on;

% กราฟที่ 4: แรงดันไฟฟ้า (mV) vs ความหนาแน่นสนามแม่เหล็ก (mT)
subplot(2,2,4);
plot(avg_B, avg_vout, '-rx', 'LineWidth', 1.5, 'MarkerSize', 8);
title('Magnetic Response: Voltage vs B');
xlabel('Magnetic Flux Density (mT)');
ylabel('Output Voltage (mV)');
grid on;