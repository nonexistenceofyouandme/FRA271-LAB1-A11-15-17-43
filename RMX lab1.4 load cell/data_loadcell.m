% =========================================================================
% สคริปต์เก็บข้อมูล Lab 1.4: Load Cell (กด Enter -> รัน 5 วิ -> หาค่าเฉลี่ย)
% + เพิ่มฟังก์ชันบันทึกค่าสมการ m, c ลงไฟล์ Txt แยกต่างหาก
% =========================================================================
clear; clc; close all;

% 1. ลำดับน้ำหนักที่ต้องการทดลอง (0 - 10 กิโลกรัม)
target_weights_kg = 0:1:10; 
num_points = length(target_weights_kg);

% กำหนดชื่อโมเดล Simulink (แก้ไขให้ตรงกับชื่อไฟล์ Simulink ของคุณ)
model_name = 'sensorExpoler_loadcell'; 

% สร้าง Array สำหรับเก็บค่าเฉลี่ย RAW Data ของแต่ละจุด
avg_raw = zeros(num_points, 1);

fprintf('=== โปรแกรมเก็บข้อมูล Lab 1.4 Load Cell (โหมด Average 5 วินาที) ===\n');
fprintf('โปรแกรมจะรอให้คุณวางน้ำหนัก เมื่อกด Enter ระบบจะเก็บค่า 5 วินาทีแล้วหาค่าเฉลี่ยให้\n\n');

% เช็คว่าเปิดโมเดลไว้หรือยัง ถ้ายังให้เปิดขึ้นมา
if ~bdIsLoaded(model_name)
    open_system(model_name);
end

% 2. ลูปกำกับการวางน้ำหนักและการรัน Simulink ทีละ 5 วินาที
for i = 1:num_points
    fprintf('\n>> Step %d/%d: วางน้ำหนักให้ได้ [%d kg]\n', i, num_points, target_weights_kg(i));
    
    % รอให้ผู้ใช้จัดน้ำหนักและกด Enter
    input('   เมื่อถุงทรายนิ่งแล้ว ให้กด Enter เพื่อเริ่มเก็บค่า (5 วิ)...', 's');
    fprintf('   [กำลังบันทึกข้อมูล 5 วินาที... โปรดอย่าขยับโต๊ะ]\n');
    
    % สั่งรัน Simulink เป็นเวลา 5 วินาที
    simOut = sim(model_name, 'StopTime', '5');
    
    % ดึงข้อมูลที่รันเสร็จแล้วออกมา
    try
        if isprop(simOut, 'raw_data')
            raw_ts = simOut.raw_data; 
        else
            raw_ts = evalin('base', 'raw_data'); 
        end
        
        raw_array = squeeze(double(raw_ts.Data));
        
        % หาค่าเฉลี่ย (Mean) ของ RAW Data ทั้งหมดในช่วง 5 วินาที
        avg_raw(i) = mean(raw_array);
        
        fprintf('   -> เก็บข้อมูลสำเร็จ! ค่าเฉลี่ย RAW = %.2f\n', avg_raw(i));
        
    catch ME
        fprintf('   [Error]: ดึงข้อมูลไม่ได้ โปรดเช็คบล็อก To Workspace ว่าตั้งชื่อ "raw_data" และเป็น "timeseries" หรือไม่\n');
        error(ME.message);
    end
end

fprintf('\n>> เก็บครบ %d จุดแล้ว! กำลังประมวลผลสมการและกราฟ...\n', num_points);

% =========================================================================
% 3. สร้างสมการ Calibration และแปลงค่า RAW เป็นน้ำหนัก
% =========================================================================
p = polyfit(avg_raw, target_weights_kg', 1);
m = p(1);
c = p(2);

fprintf('\n********************************************************\n');
fprintf(' นำตัวเลขสองค่านึ้ไปใส่ในบล็อก Simulink เพื่อทำ Real-time\n');
fprintf('   บล็อก Gain (ค่า m)     = %.6f\n', m);
fprintf('   บล็อก Constant (ค่า c) = %.6f\n', c);
fprintf('********************************************************\n');

measured_weight_kg = m * avg_raw + c;
error_kg = measured_weight_kg - target_weights_kg';

% =========================================================================
% 4. สรุปผล สร้างตาราง และบันทึก CSV & TXT
% =========================================================================
results_table = table(target_weights_kg', avg_raw, measured_weight_kg, error_kg, ...
    'VariableNames', {'Target_Weight_kg', 'Avg_Raw_ADC', 'Measured_Weight_kg', 'Error_kg'});

disp('สรุปผลการทดลอง:');
disp(results_table);

% 4.1 บันทึกข้อมูลตารางลง CSV
csv_filename = 'Lab1_4_LoadCell_Avg5Sec.csv';
writetable(results_table, csv_filename);
fprintf('>> บันทึกไฟล์ข้อมูล "%s" เรียบร้อยแล้ว\n', csv_filename);

% 4.2 บันทึกค่าสมการ m และ c แยกเป็นไฟล์ TXT
txt_filename = 'Lab1_4_Calibration_Eq.txt';
fid = fopen(txt_filename, 'w');
if fid ~= -1
    fprintf(fid, '--- Load Cell Calibration Parameters ---\n');
    fprintf(fid, 'Equation: Weight (kg) = m * RAW + c\n\n');
    fprintf(fid, 'm (Gain)     = %.8f\n', m);
    fprintf(fid, 'c (Constant) = %.8f\n', c);
    fclose(fid);
    fprintf('>> บันทึกค่า m และ c ลงไฟล์ "%s" เรียบร้อยแล้ว\n', txt_filename);
else
    fprintf('>> [Warning]: ไม่สามารถสร้างไฟล์ %s ได้\n', txt_filename);
end

% =========================================================================
% 5. พล็อตกราฟผลลัพธ์
% =========================================================================
figure('Name', 'Load Cell Linearity (5-Sec Averaged)', 'Position', [150, 150, 800, 500]);
hold on; grid on;

plot(target_weights_kg, target_weights_kg, '--k', 'LineWidth', 1.5); 
plot(target_weights_kg, measured_weight_kg, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b', 'Color', 'b');

title('Load Cell Linearity (5-Second Averaged Method)', 'FontSize', 14);
xlabel('True Weight (kg)', 'FontSize', 12);
ylabel('Measured Weight (kg)', 'FontSize', 12);
legend('Ideal Line (Ground Truth)', 'Measured Line', 'Location', 'NorthWest', 'FontSize', 11);

xlim([0 10]);
ylim([0 11]);
yticks(0:1:11);

ax = gca; ax.GridAlpha = 0.6; ax.GridLineStyle = '--';
hold off;