% =========================================================================
% สคริปต์พล็อตกราฟ Encoder Real-Time Analysis (BOURNS, แนวนอน 1x3)
% =========================================================================
clear; clc; close all;

% 1. ตั้งค่าพารามิเตอร์
encoder_name = 'BOURNS'; 
filename = 'BOURNS_Realtime.csv'; % *** เปลี่ยนชื่อไฟล์ตรงนี้หากไม่ตรง ***

base_PPR = 24;        % ของ BOURNS มี PPR = 24
mode_mult = 4;        % โหมด 4X
total_pulses = base_PPR * mode_mult; % = 96 pulses/rev

% 2. สร้าง Figure ธีมสว่าง (แนวนอน 1x3)
fig = figure('Name', sprintf('Encoder Real-Time Analysis - %s', encoder_name), 'Position', [50, 200, 1500, 450]);
set(fig, 'Color', 'w');

try
    % 3. อ่านข้อมูลจากไฟล์
    data = readtable(filename);

    % ดึงข้อมูลให้ถูกคอลัมน์
    t = data{:, 1};               % คอลัมน์ A (1) = Time (s)
    unwrapped_count = data{:, 2}; % คอลัมน์ B (2) = Pulses 
    vel_rad_s = data{:, 4};       % คอลัมน์ D (4) = Velocity (rad/s)

    % 4. ตัด Spike ขยะตอนรันโปรแกรมทิ้ง (เกิน 1500 ให้เป็น NaN)
    vel_rad_s(abs(vel_rad_s) > 1500) = NaN;

    % คำนวณเป็น Radians
    rad_pos = (unwrapped_count / total_pulses) * (2 * pi);

    % 5. พล็อต Subplot แนวนอน (1 แถว 3 คอลัมน์)

    % ==========================================
    % ชั้นที่ 1: Relative Position (Pulses)
    % ==========================================
    ax1 = subplot(1, 3, 1);
    set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 

    plot(t, unwrapped_count, 'k', 'LineWidth', 1.5); 

    title('Relative Position (Pulses)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k'); 
    ylabel('Pulses', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    xlim([0 30]);

    % ==========================================
    % ชั้นที่ 2: Angular Position (Radians)
    % ==========================================
    ax2 = subplot(1, 3, 2);
    set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 

    plot(t, rad_pos, 'b', 'LineWidth', 1.5); 

    title('Angular Position (Radians)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k'); 
    ylabel('Radians', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    xlim([0 30]);

    % ==========================================
    % ชั้นที่ 3: Angular Velocity (rad/s)
    % ==========================================
    ax3 = subplot(1, 3, 3);
    set(ax3, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 

    plot(t, vel_rad_s, 'r', 'LineWidth', 1.2); 

    title('Angular Velocity (rad/s)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    ylabel('Velocity (rad/s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    xlim([0 30]);

    % ตกแต่งเส้นตาราง (Grid)
    axes_list = [ax1, ax2, ax3];
    for k = 1:3
        grid(axes_list(k), 'on');
        grid(axes_list(k), 'minor');
        axes_list(k).GridColor = 'k';          
        axes_list(k).MinorGridColor = 'k';     
        axes_list(k).GridLineStyle = '--';     
        axes_list(k).MinorGridLineStyle = ':'; 
        axes_list(k).GridAlpha = 0.4;          
        axes_list(k).MinorGridAlpha = 0.2;
    end

    % ชื่อหัวกราฟรวม (sgtitle)
    sgt = sgtitle(sprintf('Encoder Real-Time Analysis (%s)', encoder_name), 'FontSize', 16, 'FontWeight', 'bold');
    sgt.Color = 'k';

catch ME
    fprintf('>> เกิดข้อผิดพลาด: %s\n', ME.message);
    fprintf('>> โปรดตรวจสอบไฟล์ %s ว่าคอลัมน์ถูกต้องหรือไม่\n', filename);
end