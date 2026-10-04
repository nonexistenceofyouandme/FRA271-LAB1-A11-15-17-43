% =========================================================================
% สคริปต์พล็อตกราฟ Homing Operation Analysis (แก้ข้อความทับเส้น)
% =========================================================================
clear; clc; close all;

% 1. ตั้งค่าพารามิเตอร์ไฟล์
filename = 'Set_home_2.csv'; 

% 2. สร้าง Figure ธีมสว่าง (แนวนอน 1x3)
fig = figure('Name', 'Homing Operation Analysis', 'Position', [50, 200, 1500, 450]);
set(fig, 'Color', 'w');

try
    % 3. อ่านข้อมูลจากไฟล์
    data = readtable(filename);
    
    % ดึงข้อมูลตามคอลัมน์ในไฟล์
    t = data{:, 1};               % คอลัมน์ 1: Time (s)
    trigger = data{:, 2};         % คอลัมน์ 2: Homing Trigger Signal (0/1)
    deg_raw = data{:, 3};         % คอลัมน์ 3: Raw Position (Degrees)
    deg_home = data{:, 4};        % คอลัมน์ 4: Position From Home (Degrees)
    
    % หาเวลาที่ Trigger ทำงานครั้งแรก
    idx_home = find(trigger == 1, 1);
    if ~isempty(idx_home)
        t_home = t(idx_home);
        val_raw = deg_raw(idx_home);
        val_home = deg_home(idx_home);
    else
        t_home = NaN;
    end
    
    % 4. พล็อต Subplot แนวนอน (1 แถว 3 คอลัมน์)
    
    % ==========================================
    % ชั้นที่ 1: Homing Trigger Signal
    % ==========================================
    ax1 = subplot(1, 3, 1);
    set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 
    
    plot(t, trigger, 'r', 'LineWidth', 2); 
    
    % วาดเส้นประและข้อความชี้ลงจากด้านบน
    if ~isnan(t_home)
        xline(t_home, 'k--', 'LineWidth', 1.5);
        plot(t_home, 1, 'ko', 'MarkerSize', 7, 'MarkerFaceColor', 'k');
        
        % ย้ายข้อความไปไว้ด้านบนจุดมาร์ก
        text(t_home, 1.08, '\downarrow Homing Activated', 'Color', 'k', ...
             'FontWeight', 'bold', 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    title('Homing Trigger Signal', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k'); 
    ylabel('State (0 or 1)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    ylim([-0.2 1.4]); % เผื่อพื้นที่ด้านบนให้ข้อความ
    yticks([0 1]);
    
    % ==========================================
    % ชั้นที่ 2: Raw Position
    % ==========================================
    ax2 = subplot(1, 3, 2);
    set(ax2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 
    
    plot(t, deg_raw, 'k', 'LineWidth', 2); 
    
    if ~isnan(t_home)
        xline(t_home, 'r--', 'LineWidth', 1.5);
        plot(t_home, val_raw, 'ro', 'MarkerSize', 7, 'MarkerFaceColor', 'r');
        
        % ย้ายข้อความไปไว้ด้านบนจุดมาร์ก (บวกเพิ่มไป 80 องศา)
        text(t_home, val_raw + 80, '\downarrow Offset Saved', 'Color', 'r', ...
             'FontWeight', 'bold', 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    title('Raw Position', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k'); 
    ylabel('Angle (Degrees)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    ylim([0 max(deg_raw)+250]); % เผื่อพื้นที่ด้านบนให้ข้อความไม่หลุดขอบ
    
    % ==========================================
    % ชั้นที่ 3: Position From Home (Reset value)
    % ==========================================
    ax3 = subplot(1, 3, 3);
    set(ax3, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
    hold on; 
    
    plot(t, deg_home, 'b', 'LineWidth', 2); 
    
    if ~isnan(t_home)
        xline(t_home, 'r--', 'LineWidth', 1.5);
        plot(t_home, val_home, 'ro', 'MarkerSize', 7, 'MarkerFaceColor', 'r');
        
        % ย้ายข้อความไปไว้ด้านบนจุดมาร์ก (บวกเพิ่มไป 80 องศา)
        text(t_home, val_home + 80, '\downarrow New Home (0^\circ)', 'Color', 'r', ...
             'FontWeight', 'bold', 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    title('Position From Home (Reset at Trigger)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    ylabel('Angle (Degrees)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    ylim([min(deg_home)-100 max(deg_home)+250]); % เผื่อพื้นที่ให้ข้อความด้านบน
    
    % ตกแต่งเส้นตาราง (Grid) ให้คลีนและดูเป็นมืออาชีพ
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
        xlim(axes_list(k), [min(t) max(t)]); 
    end
    
    % ชื่อหัวกราฟรวม
    sgt = sgtitle('Encoder Homing Operation Analysis', 'FontSize', 16, 'FontWeight', 'bold');
    sgt.Color = 'k';

catch ME
    fprintf('>> เกิดข้อผิดพลาด: %s\n', ME.message);
    fprintf('>> โปรดตรวจสอบไฟล์ %s ว่าโครงสร้างข้อมูลครบถ้วนหรือไม่\n', filename);
end