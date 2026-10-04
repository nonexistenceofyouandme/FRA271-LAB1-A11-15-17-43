% =========================================================
% ตั้งค่าเริ่มต้นการทดลอง Schmitt Trigger
% =========================================================
model_name = 'sensorExpoler_japan'; % <--- ใส่ชื่อไฟล์ Simulink
run_time = 20; % เวลาในการรัน (วินาที)

% ---> กำหนดค่า Threshold ตามทฤษฎีที่คำนวณได้ <---
V_TH_theory = 1.3; % แก้ไขค่า Upper Threshold Voltage (V) ตรงนี้
V_TL_theory = 0.7; % แก้ไขค่า Lower Threshold Voltage (V) ตรงนี้

disp('--- เริ่มการเก็บข้อมูล Schmitt Trigger ---');
fprintf('>> ระบบจะรัน Simulink เป็นเวลา %d วินาที\n', run_time);
input('กด Enter เมื่อพร้อม เพื่อเริ่มบันทึกข้อมูล...');
fprintf('>> กำลังบันทึกข้อมูล %d วินาที... (ค่อยๆ หมุน Poten ไป-กลับ ได้เลย)\n', run_time);

% สั่งรัน Simulink
simOut = sim(model_name, 'StopTime', num2str(run_time));

% ดึงข้อมูล
try
    t_stamp = simOut.tout; v_in = simOut.V_in; v_out = simOut.V_out;
    if isa(v_in, 'timeseries'), v_in = v_in.Data; end
    if isa(v_out, 'timeseries'), v_out = v_out.Data; end
catch
    t_stamp = evalin('base', 'tout'); v_in = evalin('base', 'V_in'); v_out = evalin('base', 'V_out');
end

% บันทึก CSV
data_matrix = [t_stamp(:), v_in(:), v_out(:)];
dataTable = array2table(data_matrix, 'VariableNames', {'Timestamp', 'V_in', 'V_out'});
csv_filename = sprintf('Schmitt_Data_%s.csv', char(datetime('now', 'Format', 'yyyyMMdd_HHmmss')));
writetable(dataTable, csv_filename);

% =========================================================
% พล็อตกราฟ พร้อมเส้นประ V_TH และ V_TL
% =========================================================
figure('Name', 'Schmitt Trigger Analysis', 'Position', [100, 100, 1000, 400]);

% --- กราฟที่ 1: Time Domain Response ---
subplot(1, 2, 1);
plot(t_stamp, v_in, 'b', 'LineWidth', 1.5); hold on;
plot(t_stamp, v_out, 'r', 'LineWidth', 1.5);

% ใช้ yline สร้างเส้นประแนวนอน พร้อมใส่ Label
yline(V_TH_theory, '--m', 'V_{TH} (Theory)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
yline(V_TL_theory, '--c', 'V_{TL} (Theory)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');

grid on;
title('Time Domain Response');
xlabel('Time (s)'); ylabel('Voltage (V)');
legend('V_{in} (Input)', 'V_{out} (Output)', 'Location', 'best');
ylim([-0.5 max(max(v_in), max(v_out))+1]); 

% --- กราฟที่ 2: Hysteresis Loop ---
subplot(1, 2, 2);
plot(v_in, v_out, 'k', 'LineWidth', 1.5); hold on;

% ใช้ xline สร้างเส้นประแนวตั้ง (เพราะ V_in อยู่บนแกน X) พร้อมใส่ Label
xline(V_TH_theory, '--m', 'V_{TH}', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
xline(V_TL_theory, '--c', 'V_{TL}', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');

grid on;
title('Transfer Characteristic (Hysteresis Loop)');
xlabel('Input Voltage (V_{in})'); ylabel('Output Voltage (V_{out})');
ylim([-0.5 max(v_out)+1]); xlim([-0.5 max(v_in)+1]);

disp('>> กราฟพร้อมใช้งานแล้วครับ!');