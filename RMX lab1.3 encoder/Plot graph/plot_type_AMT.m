% =========================================================================
% สคริปต์พล็อตกราฟ Linearity (BOURNS Encoder, ไม่ Invert ค่า, สเกล Y ขนาดเล็ก)
% =========================================================================
clear; clc; close all;

% 1. ตั้งค่าพารามิเตอร์ของ Encoder
encoder_name = 'BOURNS'; % ตั้งชื่อเป็น BOURNS
base_PPR = 24;           % *** BOURNS มีค่า PPR = 24 ***

modes = {'1X', '2X', '4X'};
mode_mults = [1, 2, 4];
mode_titles = {'X1 Mode', 'X2 Mode', 'X4 Mode'};

% ชุดสีสำหรับ Set 1, 2, 3
set_colors = {'#0072BD', '#D95319', '#77AC30'}; 

% 2. สร้าง Figure พื้นหลังสีขาว
fig = figure('Name', sprintf('Linearity (Thick Lines) - %s', encoder_name), 'Position', [50, 150, 1400, 500]);
set(fig, 'Color', 'w');

% 3. ลูปพล็อต Subplot ทั้ง 3 โหมด
for i = 1:length(modes)
    ax = subplot(1, 3, i); 
    set(ax, 'Color', 'w');
    
    ax.XColor = 'k';
    ax.YColor = 'k';
    
    hold on;
    
    total_pulses = base_PPR * mode_mults(i); 
    saved_target_deg = []; 
    h_data = gobjects(1,3);
    
    % ลูปดึงไฟล์ CSV ทั้ง 3 รอบ
    for set_num = 1:3
        filename = sprintf('%s_%s_set%d.csv', encoder_name, modes{i}, set_num);
        
        try
            data = readtable(filename);
            
            target_deg = data{:, 1};         
            
            % *** ดึงค่า Unwrapped Count ตรงๆ (ไม่ต้อง Invert) ***
            unwrapped_count = data{:, 3};    
            
            if isempty(saved_target_deg)
                saved_target_deg = target_deg; 
            end
            
            label_name = sprintf('Set %d', set_num);
            
            % วาดกราฟเส้นข้อมูล ความหนา 2.5
            h_data(set_num) = plot(target_deg, unwrapped_count, '-', ...
                'Color', set_colors{set_num}, ...
                'LineWidth', 2.5, 'DisplayName', label_name);
                
        catch
            fprintf('>> แจ้งเตือน: ไม่พบไฟล์ %s\n', filename);
        end
    end
    
    % วาดเส้น Ideal Line ไว้หน้าสุด 
    if ~isempty(saved_target_deg)
        % *** คำนวณเส้น Ideal ตรงๆ (ไม่ต้อง Invert) ***
        ideal_count = (saved_target_deg / 360) * total_pulses; 
        h_ideal = plot(saved_target_deg, ideal_count, 'k--', 'LineWidth', 3, 'DisplayName', 'Ideal Line (PPR x Mode)');
    end
    
    % 4. ตกแต่งกราฟ 
    title(sprintf('%s Encoder : %s\n(Max Pulses/Rev = %d)', encoder_name, mode_titles{i}, total_pulses), 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    xlabel('Target Angle (Degrees)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
    ylabel('Unwrapped Count (Pulses)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k'); 
    
    grid on;
    grid minor;
    ax.GridColor = 'k';          
    ax.MinorGridColor = 'k';     
    ax.GridLineStyle = '--';     
    ax.MinorGridLineStyle = ':'; 
    ax.GridAlpha = 0.4;          
    ax.MinorGridAlpha = 0.2;
    
    xlim([-100 460]);
    xticks(-90:45:450); 
    xtickangle(45); 
    
    % *** ปรับสเกลแกน Y ให้เหมาะกับ BOURNS ***
    y_step = 10 * mode_mults(i); % ซอยสเตปย่อยให้ละเอียด (X1 ทีละ 10, X2 ทีละ 20, X4 ทีละ 40)
    
    % หาค่า Y สูงสุดทางทฤษฎีเพื่อเผื่อพื้นที่ให้ Legend
    max_deg = 450; 
    if ~isempty(saved_target_deg), max_deg = max(saved_target_deg); end
    max_y_expected = (max_deg / 360) * total_pulses;
    
    yticks(-y_step : y_step : ceil(max_y_expected/y_step)*y_step + y_step*2);
    ylim([-y_step/1.5 (max_y_expected * 1.4)]); % เว้นพื้นที่ด้านบน 40% ให้กล่อง Legend
    
    % กล่อง Legend
    h_valid_data = h_data(isgraphics(h_data));
    if exist('h_ideal', 'var') && isgraphics(h_ideal)
        lgd = legend([h_ideal, h_valid_data], 'Location', 'northwest', 'FontSize', 9); 
    else
        lgd = legend(h_valid_data, 'Location', 'northwest', 'FontSize', 9); 
    end
    lgd.Color = 'w';        
    lgd.TextColor = 'k';    
    lgd.EdgeColor = 'k';    
end

sgt = sgtitle(sprintf('Linearity & Repeatability Analysis (%s Encoder)', encoder_name), 'FontSize', 16, 'FontWeight', 'bold');
sgt.Color = 'k';