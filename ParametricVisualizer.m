%% =========================================================================
%  ParametricVisualizer.m
%  Real Space vs Parametric Space Visualization Tool
%
%  USAGE: Run this file in MATLAB R2019b or later.
%         >> ParametricVisualizer
%
%  FEATURES:
%   - Dual-panel plots: Real Space (left) and Parametric Space (right)
%   - 3 built-in examples: Circle, Ellipse, Helix
%   - 2 built-in surfaces: Cylinder, Sphere
%   - Arc length and surface area computation
%   - Animated curve tracing
%   - Highlighted corresponding points via sliders
%   - Full GUI with buttons, sliders, dropdowns
%
%  AUTHOR: Generated MATLAB Project
%  =========================================================================

function ParametricVisualizer()
    %% ---- App State ---------------------------------------------------------
    app = struct();
    app.N        = 500;          % Number of sample points
    app.animRunning = false;
    app.animFrame   = 1;
    app.animTimer   = [];
    app.currentType = 'curve';   % 'curve' | 'surface'

    %% ---- Main Figure -------------------------------------------------------
    fig = uifigure('Name','Real Space ↔ Parametric Space Visualizer', ...
                   'Position',[60 60 1260 760], ...
                   'Color',[0.13 0.14 0.17], ...
                   'Resize','on');

    %% ---- Title Bar ---------------------------------------------------------
    uilabel(fig,'Text','Real Space  ↔  Parametric Space Visualizer', ...
        'Position',[0 720 1260 36], ...
        'HorizontalAlignment','center', ...
        'FontSize',18,'FontWeight','bold', ...
        'FontColor',[0.95 0.95 0.95], ...
        'BackgroundColor',[0.18 0.20 0.25]);

    %% ---- Left Axes: Real Space ---------------------------------------------
    ax1 = uiaxes(fig,'Position',[30 200 560 500]);
    ax1.Title.String  = 'Real Space';
    ax1.Title.Color   = [0.9 0.9 0.9];
    ax1.XLabel.String = 'x';  ax1.XLabel.Color = [0.8 0.8 0.8];
    ax1.YLabel.String = 'y';  ax1.YLabel.Color = [0.8 0.8 0.8];
    ax1.Color         = [0.10 0.11 0.14];
    ax1.GridColor     = [0.35 0.35 0.35];
    ax1.GridAlpha     = 0.5;
    ax1.XColor        = [0.7 0.7 0.7];
    ax1.YColor        = [0.7 0.7 0.7];
    grid(ax1,'on'); hold(ax1,'on');

    %% ---- Right Axes: Parametric Space -------------------------------------
    ax2 = uiaxes(fig,'Position',[660 200 560 500]);
    ax2.Title.String  = 'Parametric Space  (t  or  u–v)';
    ax2.Title.Color   = [0.9 0.9 0.9];
    ax2.XLabel.String = 't (or u)';  ax2.XLabel.Color = [0.8 0.8 0.8];
    ax2.YLabel.String = 'parameter value (or v)'; ax2.YLabel.Color=[0.8 0.8 0.8];
    ax2.Color         = [0.10 0.11 0.14];
    ax2.GridColor     = [0.35 0.35 0.35];
    ax2.GridAlpha     = 0.5;
    ax2.XColor        = [0.7 0.7 0.7];
    ax2.YColor        = [0.7 0.7 0.7];
    grid(ax2,'on'); hold(ax2,'on');

    %% ---- Control Panel Background ------------------------------------------
    uipanel(fig,'Position',[0 0 1260 198], ...
        'BackgroundColor',[0.16 0.17 0.21], ...
        'BorderType','none');

    panelColor = [0.16 0.17 0.21];
    lblColor   = [0.80 0.82 0.88];
    fldBG      = [0.22 0.23 0.28];
    fldFG      = [0.95 0.95 0.95];
    btnBG      = [0.25 0.45 0.78];
    btnFG      = [1 1 1];

    %% ---- Preset Dropdown ---------------------------------------------------
    uilabel(fig,'Text','Preset Example','Position',[30 162 110 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');

    presetDD = uidropdown(fig, ...
        'Items',{'Circle','Ellipse','Helix (3D)','Cylinder (Surface)','Sphere (Surface)'}, ...
        'Position',[30 138 180 26], ...
        'BackgroundColor',fldBG,'FontColor',fldFG, ...
        'ValueChangedFcn',@(src,evt) loadPreset(src.Value));

    %% ---- Parameter a / b --------------------------------------------------
    uilabel(fig,'Text','Param  a','Position',[230 162 70 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    aField = uieditfield(fig,'numeric','Value',1, ...
        'Position',[230 138 70 26], ...
        'BackgroundColor',fldBG,'FontColor',fldFG, ...
        'ValueChangedFcn',@(~,~) refreshPlot());

    uilabel(fig,'Text','Param  b','Position',[310 162 70 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    bField = uieditfield(fig,'numeric','Value',1, ...
        'Position',[310 138 70 26], ...
        'BackgroundColor',fldBG,'FontColor',fldFG, ...
        'ValueChangedFcn',@(~,~) refreshPlot());

    %% ---- t range -----------------------------------------------------------
    uilabel(fig,'Text','t  min','Position',[398 162 60 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    tminField = uieditfield(fig,'numeric','Value',0, ...
        'Position',[398 138 60 26], ...
        'BackgroundColor',fldBG,'FontColor',fldFG, ...
        'ValueChangedFcn',@(~,~) refreshPlot());

    uilabel(fig,'Text','t  max','Position',[468 162 60 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    tmaxField = uieditfield(fig,'numeric','Value',2*pi, ...
        'Position',[468 138 60 26], ...
        'BackgroundColor',fldBG,'FontColor',fldFG, ...
        'ValueChangedFcn',@(~,~) refreshPlot());

    %% ---- Point-highlight slider -------------------------------------------
    uilabel(fig,'Text','Highlight Point  (t slider)', ...
        'Position',[545 162 160 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    ptSlider = uislider(fig,'Limits',[0 1],'Value',0.5, ...
        'Position',[545 158 200 3], ...
        'ValueChangedFcn',@(src,~) highlightPoint(src.Value));

    %% ---- Animate Button ----------------------------------------------------
    animBtn = uibutton(fig,'push','Text','▶  Animate', ...
        'Position',[760 138 110 30], ...
        'BackgroundColor',btnBG,'FontColor',btnFG,'FontWeight','bold', ...
        'ButtonPushedFcn',@(~,~) toggleAnimation());

    %% ---- Plot Button -------------------------------------------------------
    uibutton(fig,'push','Text','↺  Refresh Plot', ...
        'Position',[880 138 120 30], ...
        'BackgroundColor',[0.22 0.55 0.35],'FontColor',btnFG,'FontWeight','bold', ...
        'ButtonPushedFcn',@(~,~) refreshPlot());

    %% ---- Results Labels ----------------------------------------------------
    uilabel(fig,'Text','Arc Length:', ...
        'Position',[30 100 100 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    arcLenLbl = uilabel(fig,'Text','—', ...
        'Position',[135 100 200 22], ...
        'FontColor',[0.4 0.9 0.6],'BackgroundColor',panelColor,'FontSize',13);

    uilabel(fig,'Text','Surface Area:', ...
        'Position',[360 100 110 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    surfAreaLbl = uilabel(fig,'Text','N/A (curve mode)', ...
        'Position',[475 100 260 22], ...
        'FontColor',[0.4 0.8 1.0],'BackgroundColor',panelColor,'FontSize',13);

    %% ---- Formula Display ---------------------------------------------------
    uilabel(fig,'Text','Parametric Equations:', ...
        'Position',[30 66 160 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    formulaLbl = uilabel(fig,'Text','', ...
        'Position',[195 60 1050 30], ...
        'FontColor',[1.0 0.85 0.4],'BackgroundColor',panelColor,'FontSize',12);

    uilabel(fig,'Text','Real-Space Equation:', ...
        'Position',[30 34 160 22], ...
        'FontColor',lblColor,'BackgroundColor',panelColor,'FontWeight','bold');
    realEqLbl = uilabel(fig,'Text','', ...
        'Position',[195 28 1050 26], ...
        'FontColor',[0.9 0.6 1.0],'BackgroundColor',panelColor,'FontSize',12);

    %% ---- Stored handles ----------------------------------------------------
    % We use persistent plot-handle containers so we can delete/redraw
    plotHandles = struct('realCurve',[],'paramLines',[],'hlReal',[],'hlParam',[]);

    %% ======================================================================
    %                         PRESET LOADER
    %% ======================================================================
    function loadPreset(name)
        switch name
            case 'Circle'
                aField.Value = 1;  bField.Value = 1;
                tminField.Value = 0; tmaxField.Value = 2*pi;
                app.currentType = 'curve';
            case 'Ellipse'
                aField.Value = 2;  bField.Value = 1;
                tminField.Value = 0; tmaxField.Value = 2*pi;
                app.currentType = 'curve';
            case 'Helix (3D)'
                aField.Value = 1;  bField.Value = 0.2;
                tminField.Value = 0; tmaxField.Value = 4*pi;
                app.currentType = 'curve';
            case 'Cylinder (Surface)'
                aField.Value = 1;  bField.Value = 2;
                tminField.Value = 0; tmaxField.Value = 2*pi;
                app.currentType = 'surface';
            case 'Sphere (Surface)'
                aField.Value = 1;  bField.Value = 1;
                tminField.Value = 0; tmaxField.Value = pi;
                app.currentType = 'surface';
        end
        refreshPlot();
    end

    %% ======================================================================
    %                         MAIN REFRESH / PLOT
    %% ======================================================================
    function refreshPlot()
        % Read UI values
        a    = aField.Value;
        b    = bField.Value;
        tmin = tminField.Value;
        tmax = tmaxField.Value;
        preset = presetDD.Value;

        if tmax <= tmin
            uialert(fig,'t max must be greater than t min.','Input Error');
            return;
        end

        N = app.N;
        t = linspace(tmin, tmax, N);

        % Clear axes
        cla(ax1); cla(ax2);
        hold(ax1,'on'); hold(ax2,'on');
        grid(ax1,'on'); grid(ax2,'on');

        % ----------------------------------------------------------------
        % Dispatch by type
        % ----------------------------------------------------------------
        if strcmp(app.currentType,'surface')
            plotSurface(preset, a, b, tmin, tmax);
        else
            plotCurve(preset, a, b, t, tmin, tmax);
        end
    end

    %% ======================================================================
    %                         CURVE PLOTTING
    %% ======================================================================
    function plotCurve(preset, a, b, t, tmin, tmax)
        %% Compute parametric coordinates
        switch preset
            case 'Circle'
                x = a * cos(t);
                y = a * sin(t);
                z = zeros(size(t));
                is3D   = false;
                fStr   = sprintf('x(t)=%.2g·cos(t),  y(t)=%.2g·sin(t)',a,a);
                realStr= sprintf('x²+y²=%.4g  (circle, r=%.2g)',a^2,a);

            case 'Ellipse'
                x = a * cos(t);
                y = b * sin(t);
                z = zeros(size(t));
                is3D   = false;
                fStr   = sprintf('x(t)=%.2g·cos(t),  y(t)=%.2g·sin(t)',a,b);
                realStr= sprintf('x²/%.4g + y²/%.4g = 1  (ellipse)',a^2,b^2);

            case 'Helix (3D)'
                x = a * cos(t);
                y = a * sin(t);
                z = b * t;
                is3D   = true;
                fStr   = sprintf('x(t)=%.2g·cos(t),  y(t)=%.2g·sin(t),  z(t)=%.2g·t',a,a,b);
                realStr= sprintf('x²+y²=%.4g  (helix on cylinder, z=%.2g·t)',a^2,b);

            otherwise   % fallback → circle
                x = cos(t); y = sin(t); z = zeros(size(t));
                is3D = false;
                fStr = 'x(t)=cos(t), y(t)=sin(t)';
                realStr = 'x²+y²=1';
        end

        formulaLbl.Text = fStr;
        realEqLbl.Text  = realStr;

        %% ---- LEFT: Real Space plot ----------------------------------------
        ax1.XLabel.String = 'x';
        ax1.YLabel.String = 'y';
        if is3D
            ax1.ZLabel.String = 'z';
            ax1.ZLabel.Color  = [0.8 0.8 0.8];
            plot3(ax1, x, y, z, 'Color',[0.35 0.75 1.0], ...
                'LineWidth',2.0, 'DisplayName','Curve');
            view(ax1,3); axis(ax1,'equal');
        else
            plot(ax1, x, y, 'Color',[0.35 0.75 1.0], ...
                'LineWidth',2.0, 'DisplayName','Curve');
            axis(ax1,'equal');
        end

        %% ---- RIGHT: Parametric Space plot ---------------------------------
        % Show x(t), y(t), [z(t)] as separate lines vs t
        ax2.XLabel.String = 't';
        ax2.YLabel.String = 'Component value';
        plot(ax2, t, x, 'Color',[0.35 0.75 1.0], 'LineWidth',1.8, 'DisplayName','x(t)');
        plot(ax2, t, y, 'Color',[1.0 0.60 0.20], 'LineWidth',1.8, 'DisplayName','y(t)');
        if is3D
            plot(ax2, t, z, 'Color',[0.5 1.0 0.5], 'LineWidth',1.8, 'DisplayName','z(t)');
        end
        legend(ax2,'Location','best','TextColor',[0.85 0.85 0.85], ...
               'Color',[0.14 0.15 0.18],'EdgeColor',[0.4 0.4 0.4]);

        %% ---- Arc Length ---------------------------------------------------
        L = computeArcLength(t, x, y, z);
        arcLenLbl.Text  = sprintf('%.6f  units', L);
        surfAreaLbl.Text = 'N/A  (curve mode)';

        %% ---- Store for highlight slider -----------------------------------
        app.x = x; app.y = y; app.z = z;
        app.t = t; app.is3D = is3D;
        app.currentType = 'curve';

        % Initial highlight at midpoint
        highlightPoint(ptSlider.Value);
    end

    %% ======================================================================
    %                         SURFACE PLOTTING
    %% ======================================================================
    function plotSurface(preset, a, b, tmin, tmax)
        app.currentType = 'surface';
        Nu = 60; Nv = 60;

        switch preset
            case 'Cylinder (Surface)'
                % r=a, height=b, u=angle, v=height
                u = linspace(0, 2*pi, Nu);
                v = linspace(0, b, Nv);
                [U,V] = meshgrid(u,v);
                X = a*cos(U);
                Y = a*sin(U);
                Z = V;
                fStr   = sprintf('x=%.2g·cos(u), y=%.2g·sin(u), z=v;  u∈[0,2π], v∈[0,%.2g]',a,a,b);
                realStr= sprintf('x²+y²=%.4g  (cylinder, radius=%.2g, height=%.2g)',a^2,a,b);
                % Surface area of open cylinder = 2πrh
                A_analytic = 2*pi*a*b;

            case 'Sphere (Surface)'
                % radius=a, u=azimuth, v=elevation
                u = linspace(0, 2*pi, Nu);
                v = linspace(0, pi, Nv);
                [U,V] = meshgrid(u,v);
                X = a*sin(V).*cos(U);
                Y = a*sin(V).*sin(U);
                Z = a*cos(V);
                fStr   = sprintf('x=%.2g·sin(v)·cos(u), y=%.2g·sin(v)·sin(u), z=%.2g·cos(v)',a,a,a);
                realStr= sprintf('x²+y²+z²=%.4g  (sphere, r=%.2g)',a^2,a);
                % Surface area = 4πr²
                A_analytic = 4*pi*a^2;

            otherwise
                return;
        end

        formulaLbl.Text = fStr;
        realEqLbl.Text  = realStr;

        %% LEFT: Real Space 3D surface
        cla(ax1); hold(ax1,'on'); grid(ax1,'on');
        surf(ax1, X, Y, Z, 'EdgeColor','none', 'FaceAlpha',0.85, ...
            'FaceColor','interp');
        colormap(ax1, cool(256));
        axis(ax1,'equal'); view(ax1,3);
        ax1.XLabel.String='x'; ax1.YLabel.String='y';
        ax1.ZLabel.String='z'; ax1.ZLabel.Color=[0.8 0.8 0.8];
        ax1.Title.String='Real Space  (3D Surface)';

        %% RIGHT: Parametric u-v domain (flat coloured rectangle map)
        cla(ax2); hold(ax2,'on'); grid(ax2,'on');
        % colour-map magnitude of position vector |r(u,v)|
        R_mag = sqrt(X.^2+Y.^2+Z.^2);
        imagesc(ax2, u, v, R_mag);
        colormap(ax2, cool(256));
        cb = colorbar(ax2); cb.Color=[0.8 0.8 0.8];
        cb.Label.String='|r(u,v)|';
        ax2.YDir='normal';
        ax2.XLabel.String='u  (azimuth)';
        ax2.YLabel.String='v  (elevation / height)';
        ax2.Title.String='Parametric Domain  (u–v space)';

        %% Surface area (numerical + analytic)
        A_num = computeSurfaceArea(X, Y, Z, u, v);
        surfAreaLbl.Text = sprintf('Numerical: %.5f  |  Analytic: %.5f', A_num, A_analytic);
        arcLenLbl.Text  = 'N/A  (surface mode)';
    end

    %% ======================================================================
    %                       ARC LENGTH  (parametric)
    %% ======================================================================
    function L = computeArcLength(t, x, y, z)
        % L = ∫ sqrt((dx/dt)² + (dy/dt)² + (dz/dt)²) dt
        % Numerical via trapezoidal rule on finite differences
        dt = diff(t);
        dx = diff(x); dy = diff(y); dz = diff(z);
        speed = sqrt((dx./dt).^2 + (dy./dt).^2 + (dz./dt).^2);
        L = trapz(t(1:end-1), speed);
    end

    %% ======================================================================
    %                     SURFACE AREA  (cross-product method)
    %% ======================================================================
    function A = computeSurfaceArea(X, Y, Z, u, v)
        % A = ∬ |∂r/∂u × ∂r/∂v| du dv
        % Numerical finite-difference gradients
        [Xu,Xv] = gradient(X, u, v);
        [Yu,Yv] = gradient(Y, u, v);
        [Zu,Zv] = gradient(Z, u, v);
        % Cross product magnitude
        Cx = Yu.*Zv - Zu.*Yv;
        Cy = Zu.*Xv - Xu.*Zv;
        Cz = Xu.*Yv - Yu.*Xv;
        dA = sqrt(Cx.^2 + Cy.^2 + Cz.^2);
        % Double integral via trapz
        A = trapz(v, trapz(u, dA, 2));
    end

    %% ======================================================================
    %                     HIGHLIGHT CORRESPONDING POINT
    %% ======================================================================
    function highlightPoint(frac)
        if ~strcmp(app.currentType,'curve'), return; end
        if ~isfield(app,'t') || isempty(app.t), return; end

        t_ = app.t; x_ = app.x; y_ = app.y; z_ = app.z;
        idx = max(1, round(frac * (numel(t_)-1) + 1));
        idx = min(idx, numel(t_));

        ti = t_(idx); xi = x_(idx); yi = y_(idx); zi = z_(idx);

        % Delete old highlight markers
        if ~isempty(plotHandles.hlReal) && isvalid(plotHandles.hlReal)
            delete(plotHandles.hlReal);
        end
        if ~isempty(plotHandles.hlParam) && isvalid(plotHandles.hlParam)
            delete(plotHandles.hlParam);
        end

        if app.is3D
            plotHandles.hlReal  = plot3(ax1, xi, yi, zi, 'o', ...
                'MarkerSize',10,'MarkerFaceColor',[1 0.2 0.2],'MarkerEdgeColor','w','LineWidth',1.5);
        else
            plotHandles.hlReal  = plot(ax1, xi, yi, 'o', ...
                'MarkerSize',10,'MarkerFaceColor',[1 0.2 0.2],'MarkerEdgeColor','w','LineWidth',1.5);
        end

        % Param space: mark on x(t) and y(t) lines
        plotHandles.hlParam = plot(ax2, [ti ti ti], [xi yi zi], ...
            's','MarkerSize',8,'MarkerFaceColor',[1 0.8 0.1], ...
            'MarkerEdgeColor','w','LineWidth',1.2);
    end

    %% ======================================================================
    %                          ANIMATION
    %% ======================================================================
    function toggleAnimation()
        if app.animRunning
            % Stop
            stop(app.animTimer);
            delete(app.animTimer);
            app.animTimer   = [];
            app.animRunning = false;
            animBtn.Text    = '▶  Animate';
        else
            % Start
            if ~isfield(app,'t') || isempty(app.t) || ...
               strcmp(app.currentType,'surface')
                uialert(fig,'Animation is only available for curves.','Info');
                return;
            end
            app.animRunning = true;
            app.animFrame   = 1;
            animBtn.Text    = '⏹  Stop';
            app.animTimer = timer('ExecutionMode','fixedRate','Period',0.03, ...
                'TimerFcn',@animStep);
            start(app.animTimer);
        end
    end

    function animStep(~,~)
        if ~isvalid(fig)
            stop(app.animTimer); return;
        end
        n = numel(app.t);
        frac = (app.animFrame - 1) / (n - 1);
        ptSlider.Value = frac;
        highlightPoint(frac);
        app.animFrame = mod(app.animFrame, n) + 1;
    end

    %% ======================================================================
    %                     INITIAL DRAW
    %% ======================================================================
    loadPreset('Circle');

end % ParametricVisualizer
