function show_history(obj,slNum)
%show_history  Animates the registration history

fSim = obj.similarityFcn;
hFig = figure('Name','Registration History');
if obj.n==2

    subplot(1,3,2); hDiff = imagesc(obj.imTarget-obj.transform);
    subplot(1,3,1); hItk  = plot(0,obj.wcHistory{end}(1,:)); title('ITK Similarity');
    subplot(1,3,3); hQt   = plot(0,0); title('QUATTRO Similarity');
    for i = 1:length(obj.wcHistory{end})
        drawnow;
        imTrafo = obj.transform(obj.wcHistory{end}(i,:));
        qtSim(i) = fSim(imTrafo);
        set(hDiff,'CData',(obj.imTarget-imTrafo));
        set(hItk,'XData',(1:i)-1,'YData',obj.simHistory{end}(1:i));
        set(hQt,'XData',(1:i)-1,'YData',qtSim);
    end
else
    imTrafo = obj.transform;
    if nargin==1
        m = size(imTrafo); m = round(m(3)/2);
    else
        m = slNum;
    end
    subplot(2,3,3); hDiff = imshow(obj.imTarget(:,:,m)-imTrafo(:,:,m),[]);
    subplot(2,3,1); hItk = plot(0,obj.wcHistory{end}(1,:)); title('ITK Similarity');
    subplot(2,3,2); imshow(obj.imTarget(:,:,m),[]);
    subplot(2,3,5); hImg = imshow(imTrafo(:,:,m),[]);
    subplot(2,3,4); hQt  = plot(0,0); title('QUATTRO Similarity');
    
    for i = 1:length(obj.wcHistory{end})
        drawnow;
        imTrafo = obj.transform(obj.wcHistory{end}(i,:));
        qtSim(i) = fSim(imTrafo);
        if any(~ishandle(hItk)) || ~ishandle(hQt) || ~ishandle(hDiff) || ~ishandle(hImg)
            return
        end
        if mod(i,2)==0
            set(hDiff,'CData',squeeze(obj.imTarget(:,:,m)-imTrafo(:,:,m)))
            set(hImg,'CData',squeeze(imTrafo(:,:,m)));
        end
        set(hItk,'XData',(1:i)-1,'YData',obj.simHistory{end}(1:i));
        set(hQt,'XData',(1:i)-1,'YData',qtSim);
    end
end