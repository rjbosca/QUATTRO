function initialize(src,eventdata)
%initialize  qt_exam object data initialization event
%
%   initialize(SRC,EVENT) initializes properties of the qt_exam object OBJ. Most
%   importantly, this event handler performs consistency checks on the meta-data
%   for each image, forcing consistent meta-data structures where necessary.

    % Images are the minimum necessary data. Also, validate the calling event
    if ~src.exists.images.any || ~strcmpi(eventdata.EventName,'initializeExam')
        return
    end

    % Get the image meta data
    imgs = src.imgs;
    hdrs = reshape( cell2mat({imgs.metaData}), size(imgs) );
    
    % Create the generic display information
    switch lower(hdrs(1).Modality)
        case 'ct'
            dispFrmt = {'Loc: %3.3f'
                        'Im: %d'
                        'Series: %d'
                        'FOV:%5.0f mm'};
            dispFlds = {'SliceLocation',...
                        'InstanceNumber',...
                        'SeriesNumber',...
                        dicomlookup('0018','1100')};
        case 'mr'
            dispFrmt = {'Loc: %s %3.3f'
                        'Im: %d'
                        'Series: %d'
                        'FOV:%5.0f mm'
                        'TR/TE/FA/NEX: %5.1f / %3.1f / %2.0f / %1.0f'};
            dispFlds = {dicomlookup('2001','108b'),...
                        'SliceLocation',...
                        'InstanceNumber',...
                        'SeriesNumber',...
                        dicomlookup('0018','1100'),...
                        'RepetitionTime',...
                        'EchoTime',...
                        'FlipAngle',...
                        'NumberOfAverages'};

        % Special cases...
        switch lower(hdrs(1).Manufacturer)
            case {'ge medical systems','philips medical systems','siemens'}
                dispFlds(1) = [];
                dispFrmt{1} = 'Loc: %3.3f';
            otherwise
                dispFlds([1 5]) = [];
                dispFrmt{1}     = 'Loc: %3.3f';
                dispFrmt(4)     = [];
        end

    end

    % Sort the QT_EXAM object before continuing
    src.sort;

    % Prepare some exam specific options
    switch lower(src.type)
        case 'dce'

            % Use the imaging data on the center slice to attempt to determine
            % the arrival of the bolus
            slCenter  = round( size(src.imgs,1)/2 );
            imData    = permute( src.imgs(slCenter,:).img2mat,[3 1 2] );
            [tIdx,ok] = detect_bolus_arrival( imData );
            if (tIdx>1)
                src.opts.injectionTime = src.modelXVals.value(tIdx);
            end
            if ~ok
                warning(['qt_exam:' mfilename ':undetectableBolusArrTime'],...
                        ['Unable to automatically detect the bolus arrival ',...
                         'time. Setting the "injectionTime" option to the ',...
                         'frame: %d'],src.opts.injectionTime);
                if src.guiDialogs
                    h = warndlg({'Unable to detect bolus arrival time. Please set ',...
                                 '"Base Images" under DCE Options.'},'Unknown BAT','modal');
                    add_logo(h);
                end
            end


        case 'dsc'
            tIdx = detect_bolus_arrival({src.imgs.image},false);
            src.opts.injectionTime = src.modelXVals.value(tIdx);

        case 'multiflip'
            hdrs = reshape(cell2mat({src.imgs(:).metaData}),size(src.imgs));
            trs  = unique( cell2mat( {hdrs(1,:).RepetitionTime} ) );
            tes  = unique( cell2mat( {hdrs(1,:).EchoTime} ) );
            if (numel( trs )>1)
                warning(['qt_exam:' mfilename ':tooManyTrs'],...
                        ['More than one TR was detected for this multiple\n',...
                         'flip angle exam, but modeling assumes only one.\n']);
                if src.guiDialogs
                    errordlg('Multiple TRs found; expected only one.',...
                             'ERROR: Variable Flip Angle Exam','modal');
                end
            end
            if (numel( tes )>1)
                warning(['qt_exam:' mfilename ':tooManyTes'],...
                        ['More than one TE was detected for this multiple\n',...
                         'flip angle exam, but modeling assumes only one.\n']);
                if src.guiDialogs
                    errordlg('Multiple TEs found; expected only one.',...
                             'ERROR: Variable Flip Angle Exam','modal');
                end
            end

        case 'multiti'
            dispFrmt{end+1} = 'TI: %4.1fms';
            dispFlds{end+1} = 'InversionTime';
            hdrs = reshape( cell2mat({src.imgs(:).metaData}), size(src.imgs) );
            tis  = unique( cell2mat( {hdrs(1,:).InversionTime} ) );

        case 'surgery'
            src.calc_ijk2ras
    end

    % Update display information
    [imgs(:).dispFormat] = deal(dispFrmt);
    [imgs(:).dispFields] = deal(dispFlds); %#ok - these are image objects that
                                           %don't require storage

    % Update the "mapModel" property only after the exam pre-processing steps
    % are complete. Since the "x" property is set during this notification it is
    % important that the images be sorted properly before notifying this
    % listener.
    %TODO: there should be a way to notify the map modeling object of changes to
    %the exam sorting
    notify(src,'newModel');

end %qt_exam.initialize