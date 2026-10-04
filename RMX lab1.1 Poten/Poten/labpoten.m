% กำหนดช่วงของ % ที่ต้องการวัด (0 ถึง 100 ทีละ 5)
percent_steps = 0:5:100;
num_steps = length(percent_steps);

% เตรียมตัวแปรสำหรับเก็บค่าเฉลี่ยของทั้ง 3 พิน
mean_A = zeros(1, num_steps);
mean_B = zeros(1, num_steps);
mean_C = zeros(1, num_steps);

% ตั้งค่ากราฟสำหรับ 3 เส้น
figure;
hold on; grid on;
hPlotA = plot(NaN, NaN, '-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'Color', 'r');
hPlotB = plot(NaN, NaN, '-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'g', 'Color', 'g');
hPlotC = plot(NaN, NaN, '-^', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'Color', 'b');
title('Potentiometer Voltage Response (3 Pins)');
xlabel('Potentiometer Position (%)');
ylabel('Average Voltage (V)');
xlim([0 100]);
ylim([0 5]); % ปรับตาม Voltage สูงสุด
legend('v\_raw\_A', 'v\_raw\_B', 'v\_raw\_C', 'Location', 'northwest');

disp('--- เริ่มกระบวนการเก็บข้อมูล 3 ตัวแปร จาก Simulink ---');

for i = 1:num_steps
    fprintf('\nขั้นตอนที่ %d/%d (ตำแหน่ง %d%%):\n', i, num_steps, percent_steps(i));
    fprintf('  1) หมุน Potentiometer ไปที่ %d%%\n', percent_steps(i));
    fprintf('  2) กด "Run" ในหน้าต่าง Simulink (รัน 5 วินาที)\n');
    
    input('  3) เมื่อรันเสร็จแล้ว กด Enter ที่นี่เพื่อดึงข้อมูลและบันทึก CSV...');
    
    % ดึงข้อมูลจาก Workspace
    try
        t_stamp = out.tout;
        val_A = out.v_raw_A;
        val_B = out.v_raw_B;
        val_C = out.v_raw_C;
        
        if isa(val_A, 'timeseries'), val_A = val_A.Data; end
        if isa(val_B, 'timeseries'), val_B = val_B.Data; end
        if isa(val_C, 'timeseries'), val_C = val_C.Data; end
    catch
        t_stamp = evalin('base', 'tout');
        val_A = evalin('base', 'v_raw_A');
        val_B = evalin('base', 'v_raw_B');
        val_C = evalin('base', 'v_raw_C');
    end
    
    % บันทึกข้อมูล Matrix ลงไฟล์ CSV
    data_matrix = [t_stamp(:), val_A(:), val_B(:), val_C(:)];
    dataTable = array2table(data_matrix, 'VariableNames', {'Timestamp', 'v_raw_A', 'v_raw_B', 'v_raw_C'});
    time_str = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    csv_filename = sprintf('PotenData_%dPct_%s.csv', percent_steps(i), time_str);
    writetable(dataTable, csv_filename);
    
    % หาค่าเฉลี่ย
    mean_A(i) = mean(val_A);
    mean_B(i) = mean(val_B);
    mean_C(i) = mean(val_C);
    
    % อัปเดตกราฟ
    set(hPlotA, 'XData', percent_steps(1:i), 'YData', mean_A(1:i));
    set(hPlotB, 'XData', percent_steps(1:i), 'YData', mean_B(1:i));
    set(hPlotC, 'XData', percent_steps(1:i), 'YData', mean_C(1:i));
    drawnow;
end

% บันทึกค่าลง .mat
save('Simulink_Poten_Summary.mat', 'percent_steps', 'mean_A', 'mean_B', 'mean_C');

% =========================================================
% แปลงค่าเฉลี่ยให้อยู่ในรูปแบบ Array String และแสดงผล
% =========================================================
disp(' ');
disp('--- รูปแบบ Array สำหรับนำไปพล็อตแยก ---');

% ฟังก์ชันแปลง Array เป็น String คั่นด้วยลูกน้ำ (ใช้ %g เพื่อไม่ให้มีเลข 0 ต่อท้ายเยอะเกินไป)
format_array = @(arr) sprintf('%g,', arr);

% แปลงและตัดลูกน้ำตัวสุดท้ายออก
str_A = format_array(mean_A); str_A = str_A(1:end-1);
str_B = format_array(mean_B); str_B = str_B(1:end-1);
str_C = format_array(mean_C); str_C = str_C(1:end-1);

% สร้างประโยคผลลัพธ์
output_A = sprintf('A = [%s];', str_A);
output_B = sprintf('B = [%s];', str_B);
output_C = sprintf('C = [%s];', str_C);

% 1. แสดงบนหน้าจอ Command Window (ให้ก๊อปปี้ได้เลย)
disp(output_A);
disp(output_B);
disp(output_C);

% 2. เซฟข้อความนี้ลงไฟล์ Text
txt_filename = sprintf('Poten_Arrays_%s.txt', char(datetime('now', 'Format', 'yyyyMMdd_HHmmss')));
fileID = fopen(txt_filename, 'w');
fprintf(fileID, '%s\n%s\n%s\n', output_A, output_B, output_C);
fclose(fileID);

fprintf('\n>> บันทึก Array Text ลงไฟล์ %s เรียบร้อยแล้ว\n', txt_filename);
disp('--- สิ้นสุดการทดลอง ---');