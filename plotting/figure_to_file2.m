function figure_to_file2(fig, filepath, args)

arguments
    fig
    filepath
    args.format = '-dpdf'
    args.res = 600 % dpi
end

% set all units inside figure to normalized so that everything is scaling accordingly
% set(findall(fig, 'Units', 'pixels'), 'Units', 'normalized');

% do not show figure on screen
% set(fig, 'visible', 'off');

% set figure units to pixels & adjust figure size
% fig.Units = 'pixels';
% fig.OuterPosition = [0, 0, width, height] * args.res;

% recalculate figure size to be saved
% set(fig, 'PaperPositionMode', 'manual');
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0, 0, width, height];
% fig.PaperSize = fig.PaperPosition(3:4);

% set(fig, 'PaperPositionMode', 'manual');
% fig.PaperUnits = 'inches';
% fig.PaperPosition = [0 0 4 4];
% fig.PaperSize = fig.PaperPosition(3:4);

% save figure
switch args.format
    case '-dpdf'
        % print(fig, filepath, '-vector', '-dpdf');
        exportgraphics(fig,[filepath, '.pdf'],'ContentType','vector');
    case '-dpng'
        print(fig, filepath, '-dpng', sprintf('-r%d', args.res));
end

end