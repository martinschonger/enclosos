% Copyright © 2024 Martin Schonger
% This software is licensed under the GPLv3.


function [fig, ax] = setup_figure2(width, height, enable_legend, axis_equal, args)

arguments
    width = 3.41275152778 % in
    height = 3.41275152778 % in
    enable_legend = true
    axis_equal = true
    args.setup_axes = true
end

% columnwidth = 3.41275152778;
% textwidth = 7.02625;

% 2 side by side: 1.627635606409449
% 3 side by side: 1.058843685114173
% 4 side by side: 0.8236603228897639

% 2 side by side without margin: 1.70637576389
% 3 side by side without margin: 1.1375838425933333333333333333333

SPPI = get(0,'ScreenPixelsPerInch');
tmp_offset = 1/(SPPI-1);

% fig_width = textwidth;
% fig_height = 0.85 * fig_width;

fig = figure;
% set(findall(fig, 'Units', 'pixels'), 'Units', 'normalized');
% set(fig, 'visible', 'off');
fig.Units = 'inches';
fig.Position = [0 0 width height];
if args.setup_axes
    t = tiledlayout(1, 1, 'Padding', 'tight');
    % t.Units = 'inches';
    % t.OuterPosition = [0 0 width height];
end

% set all units inside figure to normalized so that everything is scaling accordingly


% set figure units to pixels & adjust figure size
% fig.Units = 'pixels';
% fig.OuterPosition = [0, 0, width, height] * args.res;

% recalculate figure size to be saved
set(fig, 'PaperPositionMode', 'manual');
fig.PaperUnits = 'inches';
fig.PaperPosition = [-tmp_offset -tmp_offset width+2*tmp_offset height+2*tmp_offset];
fig.PaperSize = [width height];

if args.setup_axes
    ax = nexttile;
    
    if axis_equal
        axis equal;
    end
    hold on;
    set(ax, 'TickLabelInterpreter', 'latex');
    
    if enable_legend
        leg = legend();
        set(leg, 'Interpreter', 'latex');
    end
end

fontsize(fig, 6, "points");

end