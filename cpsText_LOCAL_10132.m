function h=jdText(str,varargin)
    
    % function jdText(str,varargin)
    %
    % Annotate a figure.
    %
    % Jacob Duijnhouwer, 2008
    %
    % 2015-06-08: aligment of string is now adjusted depending on axis orientation (e.g.
    % flipped when using imagesc, before the string would end up too high)
    %
    % 2015-12-17: normalized units .........
    %
    % See also: text
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Handle varargin list
    p = inputParser;   % Create an instance of the inputParser class.
    p.addRequired('str', @(x)ischar(x) || iscell(x) || isnumeric(x));
    p.addParamValue('location','topleft',@(x)any(strcmpi(x,{'topleft','topright','bottomleft','bottomright','free','central'})));
    p.addParamValue('xgain',.98,@isnumeric);%(x)x>=0&&x<=1); % no function when location is 'central'
    p.addParamValue('ygain',.98,@isnumeric);%(x)x>=0&&x<=1); % no function when location is 'central'
    p.addParamValue('FontSize',8, @(x)x>0); % if smaller than 1, interpreted as proportional to Y-axis, otherwise as points
    p.addParamValue('Color', [0 0 0 1]);
    p.addParamValue('BackGroundColor','none'); % e.g. [1 1 1 .75] or 'none'
    p.addParamValue('maxStrLen',200,@(x)dpxIsWholeNumber(x) && numel(x)>=numel('...[truncated]'));
    p.parse(str, varargin{:});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    if ~iscell(str)
        str={str};
    end
    for i=1:numel(str)
        if isnumeric(str{i}) || islogical(str{i})
            str{i}=num2str(str{i}(1:min(p.Results.maxStrLen,end))); % no need to num2str more than will be truncated anyway
        end
        % truncate the str if needed, trying to plot a very long string (passing an
        % array to num2str by accident for example) will freeze matlab
        % and eventually crash to desktop.
        if numel(str{i})>p.Results.maxStrLen
            str{i}=[str{i}(1:p.Results.maxStrLen-numel('...[truncated]')) '...[truncated]'];
        end
    end
           
            
    plotwid=max(jdXaxis)-min(jdXaxis);
    plothei=max(jdYaxis)-min(jdYaxis);
    xgain=p.Results.xgain;
    ygain=p.Results.ygain;
    
    % take care of plots that may have reversed axis orientations (e.g. default imagesc)
    loc=p.Results.location;
    if strcmpi(get(gca,{'XDir'}),'reverse')
        xgain=-xgain+1;
    end
    if strcmpi(get(gca,{'YDir'}),'reverse')
        ygain=-ygain+1;
    end
   
    switch lower(loc)
        case 'topleft'
            xgain=1-xgain;
            %x=jdGetMinXaxis+plotwid*(1-xgain);
            %y=jdGetMinYaxis+plothei*ygain;
            hAlign='left';
            vAlign='top';
        case 'topright'
          %  x=jdGetMinXaxis+plotwid*xgain;
          %  y=jdGetMinYaxis+plothei*ygain;
            hAlign='right';
            vAlign='top';
        case 'bottomleft'
                        xgain=1-xgain;
            ygain=1-ygain;
         %   x=jdGetMinXaxis+plotwid*(1-xgain);
          %  y=jdGetMinYaxis+plothei*(1-ygain);
            hAlign='left';
            vAlign='bottom';
        case 'bottomright'
         %   xgain=1-xgain;
            ygain=1-ygain;
         %   x=jdGetMinXaxis+plotwid*xgain;
         %   y=jdGetMinYaxis+plothei*(1-ygain);
            hAlign='right';
            vAlign='bottom';
        case 'free'
          %  x=jdGetMinXaxis+plotwid*xgain;
       %     y=jdGetMinYaxis+plothei*ygain;
            hAlign='center';
            vAlign='middle';
        case 'central'
            xgain=.5;
            ygain=.5;
        %    x=jdGetMinXaxis+plotwid*.5;
        %    y=jdGetMinYaxis+plothei*.5;
            hAlign='center';
            vAlign='middle';
        otherwise
            error(['[' mfilename '] Unknown location option: ' loc ]);
    end
    if strcmpi(get(gca,{'XDir'}),'reverse')
        if strcmpi(hAlign,'left')
            hAlign='right';
        else
            hAlign='left';
        end
    end
    if strcmpi(get(gca,{'YDir'}),'reverse')
        if strcmpi(vAlign,'top')
            vAlign='bottom';
        else
            vAlign='top';
        end
    end
            
    if p.Results.FontSize>1
        fu='points';
    else
        fu='normalized';
    end
    h=text(xgain,ygain,str,'FontUnits',fu,'VerticalAlignment',vAlign,'HorizontalAlignment',hAlign,'Color',p.Results.Color,'BackGroundColor',p.Results.BackGroundColor,'Units','Normalized');
    set(h,'FontSize',p.Results.FontSize);
end
