function [f] = PoleZero(pole,zero)
    %Creates a pole-zero plot in 3-D and then makes an animated
    %GIF titled 'AnimatedPoleZero.gif'
    %   Parameters:
    %           pole: a vector of poles for the plot
    %           zero: a vector of zeroes for the plot
    %   Output:
    %           f:  The frames generated to be used in the GIF
    %               They can be played back from MATLAB with
    %               movie(f);
    %   Figures Created:
    %           Fig1 - Used to animate the GIF
    %           Fig2 - The 2-D heat-map of the pole-zero plot
    %                  (not too helpful because you can't see zeroes)
    %           Fig3 - The scaterplot of the resulting Magnitude Response
    %
    
    %% Setup
    %Large complex plane to work in
    plotSize = 6001; 
    ZeroPole = ones(plotSize);
    
    midPlot = (plotSize-1)/2 + 1; % The middle of the plot
    unit = (plotSize-1)/16 + 1; % The radius of the unit cirle
    
    % Splitting poles and zeros into their rectangular form
    RealPole = unit*real(pole);
    ImagPole = unit*imag(pole);
    RealZero = unit*real(zero);
    ImagZero = unit*imag(zero);
    
    
    %% Constructing a generic pole and Zero
    % Constructing the pole
    poleSize = 2001;
    midPole = (poleSize-1)/2+1; % Middle of the pole
    POLE = zeros(poleSize);
    for n = 1:poleSize
        for m = 1:poleSize
            dist = ((midPole-m)^2 + (midPole-n)^2)^(1/2);
            % Peaks at the center and then dies of like 1/dist
            if ((midPole-1)/dist) > 1
                POLE(n,m) = (midPole-1)/dist;
            else % Makes sure poles only increase the plot
                POLE(n,m) = 1;
            end
        end
    end
    POLE(midPole,midPole) = midPole-1;
    
    % Constructing a generic zero by inverting a pole
    ZERO = zeros(poleSize);
    for n = 1:poleSize
        for m = 1:poleSize
            ZERO(n,m) = 1/POLE(n,m);
        end
    end
    
    %% Generating the 3-D Pole-Zero Plot
    for i = 1:length(RealPole)
        center = [round(midPlot+RealPole(i)), round(midPlot+ImagPole(i))];
        re = (center(1)-(midPole-1)):(center(1) + (midPole-1));
        im = (center(2)-(midPole-1)):(center(2)+(midPole-1));
        ZeroPole(im,re) = ZeroPole(im,re).*POLE; % Multiplies by the pole
    end
    
    for i = 1:length(RealZero)
        center = [round(midPlot+RealZero(i)), round(midPlot+ImagZero(i))];
        re = (center(1)-(midPole-1)):(center(1) + (midPole-1));
        im = (center(2)-(midPole-1)):(center(2)+(midPole-1));
        ZeroPole(im,re) = ZeroPole(im,re).*ZERO;
    end
    
    %% Generating the Unit Circle
    ZeroPole = ZeroPole((midPlot-unit-100):(midPlot+unit+100),(midPlot-unit-100):(midPlot+unit+100));
    midPlot = (size(ZeroPole,1)-1)/2 + 1;
    dista = zeros(size(ZeroPole));
    distb = zeros(size(ZeroPole));
    i = 1;
    nArr = zeros(1,size(ZeroPole,1));
    mArr = zeros(1,size(ZeroPole,1));
    for n = 1:size(ZeroPole,1)
        for m = 1:size(ZeroPole,2)
            % Calculates distance from the center
            dist = ((midPlot-m)^2 + (midPlot-n)^2)^(1/2);
            % Stores the indices if it's on the Unit Circle
            if round(dist) == unit
                dista(n,m) = poleSize/10;
                distb(n,m) = 1;
                nArr(i) = n; % the n values in the Unit Circle
                mArr(i) = m; % the m values in the Unit Circle
                i = i+1;
            else
                distb(n,m) = NaN; % Only plots the unit circle, itself
            end
        end
    end
    
    %% Making the GIF
    % Generating the colormap vector for Z
    z = size(ZeroPole,1);
    ZZ = zeros(z,z);
    for n = 1:z
        for m = 1:z
            ZZ(n,m) = log(ZeroPole(n,m));
        end
    end

    GIFLength = 30;%Roughly a quarter of the number of frames in the total GIF
    ZP = zeros(z,z,GIFLength); % Zero-Pole value matrix for GIF
    ZZ = zeros(z,z,GIFLength); % Zero-Pole color matrix for GIF
    for n = 1:z
        for m = 1:z
            ZP(n,m,:) = logspace(.02,log10(max(ZeroPole(n,m))),GIFLength);
            ZZ(n,m,:) = log(ZP(n,m,:));
        end
    end
    

    figure(1)
    
    for u = 1:GIFLength % Animating the poles and zeros
        S1 = surf((-z/2:z/2-1)/unit,(-z/2:z/2-1)/unit,ZP(:,:,u),ZZ(:,:,u));
        ax = gca;
        colormap(ax,'copper');
        hold on;
        surf((-z/2:z/2-1)/unit,(-z/2:z/2-1)/unit,distb);
        hold off;
        colorbar;
        set(S1,'LineStyle','none');
        title('Pole-Zero Plot');
        xlabel('Imaginary');
        ylabel('Real');
        zlabel('Magnitude');
        axis([[-1.2 1.2 -1.2 1.2] .0001 2400]);
        set(ax,'ZScale','log');
        caxis([-4,7]);
        set(ax,'View',[45 45]);
        ax.Units = 'pixels';
        f(u) = getframe(gcf,[0 0 525 422]);
    end
    
    % Rotating the pole-zero plot
    ang1 = [45*ones(1,GIFLength/2) linspace(45,45-360,4*GIFLength)];
    ang2 = [linspace(45,5,GIFLength/2) 5*ones(1,4*GIFLength)];
    for u = (GIFLength+1):GIFLength + length(ang1)
        set(ax,'View',[ang1(u-GIFLength) ang2(u-GIFLength)]);
        f(u) = getframe(gcf,[0,0,525,422]);
    end
    
    filename = 'AnimatedPoleZero.gif'; % Specify the output file name
    for idx = 1:length(f)
        ima = frame2im(f(idx));
        if idx == 1 % Makes or overwrites the file with the first frame
            imwrite(ima(:,:,1),filename,'gif','WriteMode','overwrite','LoopCount',Inf,'DelayTime',.1);
        else % Appends the frame to the file
            imwrite(ima(:,:,1),filename,'gif','WriteMode','append','DelayTime',.1,'DisposalMethod','restoreBG');
        end
    end
    %% Making the 2-D Pole-Zero Plot
    figure(2)
    imshow(ZeroPole + dista,[0,midPole/50])
    title('Pole-Zero Plot with Unit Circle')
    
    %% Generating the Magnitude Response
    
    MagRes = zeros(1,length(nArr)); % Magnitude Response Vector
    freq = zeros(1,length(nArr)); % Frequencies to plot against
    for i = 1:length(nArr)
        freq(i) = atan((midPlot-nArr(i))/(midPlot-mArr(i)));
        if nArr(i) > midPlot && mArr(i) < midPlot
            freq(i) = freq(i) + pi;
        end
        if (nArr(i) < midPlot && mArr(i) < midPlot)
            freq(i) = freq(i) - pi;
        end
    end
    
    for i = 1:length(nArr)
        MagRes(i) = ZeroPole(nArr(i),mArr(i));
    end
    
    figure(3)
    scatter(freq,MagRes,1,'g')
    title('Magnitude Response')
    axis([0 pi 0 (max(MagRes) + 1)])
    xlabel('Frequency (w-hat)')
end
