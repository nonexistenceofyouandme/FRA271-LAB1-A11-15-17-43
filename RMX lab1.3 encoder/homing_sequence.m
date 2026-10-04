% =========================================================================
% สคริปต์ Lab 1.3: Homing Sequence (เซ็ต Home 2 รอบ)
% =========================================================================
clear; clc; close all;

model_name = 'sensorExpoler_encoder'; % ตรวจสอบชื่อไฟล์ Simulink
sim_time = 20; % เพิ่มเวลาเป็น 20 วินาที

fprintf('=== โปรแกรมทดสอบ Homing Sequence (เซ็ต Home 2 รอบ) ===\n');
fprintf('เตรียมหน้าต่าง Simulink ให้พร้อมกดสับสวิตช์\n\n');
fprintf('นับถอยหลังเริ่มรัน... 3... 2... 1...\n');
pause(3);

% 1. สั่งรัน Simulink
set_param(model_name, 'StopTime', num2str(sim_time));
set_param(model_name, 'SimulationCommand', 'start');

fprintf('\n>> [0s] ระบบกำลังรัน เริ่มหมุน Encoder ไปเรื่อยๆ ได้เลยครับ!\n');
pause(5); % ให้เวลาหมุนช่วงแรก 5 วินาที

fprintf('\n>>> [5s] สับสวิตช์ SET HOME ครั้งที่ 1 ตอนนี้เลยครับ!!! (0 -> 1 -> 0) <<<\n');
pause(7); % ให้เวลาหมุนต่ออีก 7 วินาที

fprintf('\n>>> [12s] สับสวิตช์ SET HOME ครั้งที่ 2 ตอนนี้เลยครับ!!! (0 -> 1 -> 0) <<<\n');
pause(8); % ให้เวลาหมุนต่อจนจบ

fprintf('\n>> หมดเวลา 20 วินาที! กำลังดึงข้อมูลมาสร้างกราฟ...\n');
pause(2); % รอเวลาให้ Simulink โยนข้อมูลลง Workspace

% =========================================================================
% 2. ดึงข้อมูลจาก Workspace 
% =========================================================================
try
    sim_out = evalin('base', 'out');
    t            = sim_out.tout;
    homing_cmd   = sim_out.homing_cmd_out;
    deg_relative = sim_out.deg_relative_out;
    unwrap_raw   = sim_out.unwrap_raw_out;
catch
    t            = evalin('base', 'tout');
    homing_cmd   = evalin('base', 'homing_cmd_out');
    deg_relative = evalin('base', 'deg_relative_out');
    unwrap_raw   = evalin('base', 'unwrap_raw_out');
end

% เคลียร์ฟอร์แมตข้อมูล 
if isa(homing_cmd, 'timeseries')
    t = homing_cmd.Time;
    homing_cmd = homing_cmd.Data;
    deg_relative = deg_relative.Data;
    unwrap_raw = unwrap_raw.Data;
end

homing_cmd   = squeeze(double(homing_cmd));
deg_relative = squeeze(double(deg_relative));
unwrap_raw   = squeeze(double(unwrap_raw));

% =========================================================================
% 3. แปลงค่าเป็นองศา และพล็อตกราฟ
% =========================================================================
% *** แก้ตัวเลขนี้ตามฮาร์ดแวร์ (AMT = 8192, BOURNS = 96) ***
TOTAL_PULSES_PER_REV = 8192; 
deg_raw = -(unwrap_raw / TOTAL_PULSES_PER_REV) * 360;

figure('Name', 'Homing Sequence Analysis (2 Rounds)', 'Position', [150, 100, 900, 600]);

% ซับพล็อต 1: สัญญาณทริกเกอร์
subplot(3, 1, 1);
plot(t, homing_cmd, 'r', 'LineWidth', 2);
title('Homing Trigger Signal'); ylabel('State');
ylim([-0.2 1.2]); yticks([0 1]); yticklabels({'OFF', 'ON'});
grid on; ax = gca; ax.GridAlpha = 0.5;

% ซับพล็อต 2: เทียบองศา
subplot(3, 1, [2, 3]);
plot(t, deg_raw, '--k', 'LineWidth', 1.5); hold on;
plot(t, deg_relative, 'b', 'LineWidth', 2);

% ค้นหาจังหวะที่มีการสับสวิตช์ขึ้น (Rising Edge) เพื่อมาร์คจุดทั้งหมด
trigger_edges = find(diff(homing_cmd) > 0.5); 
if ~isempty(trigger_edges)
    for i = 1:length(trigger_edges)
        idx = trigger_edges(i) + 1; % จุดที่ค่าเปลี่ยนเป็น 1
        plot(t(idx), deg_relative(idx), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        text(t(idx) + 0.3, 15, ['\leftarrow Home ', num2str(i)], 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
        xline(t(idx), ':r', 'LineWidth', 1.5);
    end
end

title('Angular Position Comparison (Raw vs Relative to Home)');
xlabel('Time (s)'); ylabel('Degrees (\circ)');
legend('Absolute Position (องศาดิบ)', 'Relative Position (หักลบ Home)', 'Location', 'Best');
grid on; ax = gca; ax.GridAlpha = 0.5;

% บันทึกผลลง CSV 
results_table = table(t, homing_cmd, deg_raw, deg_relative, ...
    'VariableNames', {'Time_s', 'Homing_Trigger', 'Degrees_Raw', 'Degrees_From_Home'});
writetable(results_table, 'Lab1_3_HomingSequence_2Rounds.csv');
fprintf('>> กราฟสร้างเสร็จสมบูรณ์!\n');