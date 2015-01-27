function headers = sort_headers(headers,eType)
%sort_headers  Sorts DICOM headers according to an exam type.
%
%   H = sort_headers(H,type) sorts the structure array of headers according
%   to the exam type.
%
%   See also importDICOM

    % Loads appropriate data
    switch eType
        case {'DCE','DSC'}
            [fld,pos] = deal('InstanceNumber',1);
            headers = sortFields(headers,fld,pos);
        case {'DWI','eDWI','DTI'}
            [fld,pos] = deal('MultiB',1);
            headers = sortFields(headers,fld,pos);
        case 'MultiTI'
            [fld,pos] = deal('InversionTime',1);
            headers = sortFields(headers,fld,pos);
        case 'MultiFlip'
            [fld,pos] = deal('FlipAngle',1);
            headers = sortFields(headers,fld,pos);
        case 'MultiTR'
            [fld,pos] = deal('RepetitionTime',1);
            headers = sortFields(headers,fld,pos);
        case 'MultiTE'
            [fld,pos] = deal('EchoTime',1);
            headers = sortFields(headers,fld,pos);
        case 'GSI'
            [fld,pos] = deal(dicomlookup('0053','1075'),1);
            headers = sortFields(headers,fld,pos);
        otherwise
            [fld,pos] = deal('InstanceNumber',1);
    end

    % Determines if temporal or multi-exam data are present
    isMulti = any( isfield(headers, {dicomlookup('0043','1030'),...
                                     dicomlookup('0020','0100')}) );

    % Sorts according to slice location
    if ~strcmpi('GSI',eType)
        headers  = sortFields(headers,'SliceLocation',1);
        nSslices = unique_field_vals(headers,'SliceLocation');
    else
        headers  = sortFields(headers,'ImagePositionPatient',3);
        nSslices = unique_field_vals(headers,'ImagePositionPatient');
    end
    headers = reshape(headers, [], nSslices)';

    % Check for duplicate measuremetns
    if ~any( strcmpi(eType,{'dti','edwi','dwi'}) )
        headers = check_for_duplicates(headers,fld,pos,eType);
    end

    % Special formatting for multi-series exams
    if isMulti
        switch eType
            case 'eDWI'
                dirEdwiTag = dicomlookup('0043','1030');
                headers    = sortFields(headers,dirEdwiTag,1);
                n          = unique_field_vals(headers,dirEdwiTag);
                if any( [headers.(dirEdwiTag)]==14 )
                    n = n-1; %number of encoding directions, excluding T2
                    headers = prepare_edwi_w_t2(headers,dirEdwiTag,n);
                end
                headers = reshape(headers,nSslices,[],n);
            case 'MultiTE'
                temporalTag = dicomlookup('0020','0100');
                if isfield(headers,temporalTag)
                    headers = sortFields(headers,temporalTag,1);
                    n       = unique_field_vals(headers,temporalTag);
                    headers = reshape(headers,nSslices,[],n);
                end
        end
    end

end %sort_headers


% Sorts the DICOM header array by the specified field name
function headers = sortFields(headers,field_name,pos)

    % Sorting of standard DICOM tags
    if ~strcmpi(field_name, 'multib')
        % Stores/converts data
        if isnumeric(headers(1).(field_name)(pos))
            vals = cell2mat( {headers.(field_name)} );
        else
            vals = cellfun(@str2double, {headers.(field_name)} );
        end

        % Sort headers
        [~,I] = sort(vals(:));
        headers = headers(I);

    else
        % Find gradient directions
        [bVals,vectors] = calc_diffusion(headers);

        % Sorts according to directions (the absolute value is used to
        % force the b=0 to be the first image of the series)
        if size( unique(vectors,'rows'),1 ) > 1
            [~,I] = sortrows( abs(vectors) );
            headers         = headers(I);
        else
            [~,I] = sort( bVals );
            headers        = headers(I);
        end
    end

end %sortFields

% Check for duplicate measurements
function h = check_for_duplicates(h,fld,pos,e_type)

    % Stores/converts data
    if isnumeric(h(1).(fld)(pos))
        vals = cell2mat( {h(1,:).(fld)} );
    else
        vals = cellfun(@str2double, {h(1,:).(fld)} );
    end

    is_multiple = logical( mod(numel(vals), numel(unique(vals))) );
    if ~is_multiple || strcmpi(fld,dicomlookup('0043','1030'))
        return
    end

    % Ask the user
    quest_ans = questdlg({['A ' e_type ' exam was detected.'],...
                           'Multiple instances of one measurement were found.',...
                           'Remove?'},'Remove Extra Measurement','Yes','No','Yes');
    if strcmpi(quest_ans,'yes')
        [~,I] = unique(vals); h = h(:,I);
    end

end %check_for_duplicates

% Preps eDWI headers with a T2 image
function hds = prepare_edwi_w_t2(hds,fld,n)

    % Store the T2 stack
    t2 = hds([hds.(fld)]==14);
    hds([hds.(fld)]==14) = [];

    % Determines the number of T2 images
    m = length(t2);

    % Determines the unique directions
    dir_val = unique([hds.(fld)]); dir_val(dir_val==14) = [];

    % Replicates the T2 stack for each acquired direction
    t2 = repmat(t2,n,1);

    % Replaces the T2 tag with a directional tag
    for i = 1:n
        [t2((i-1)*m+1:i*m).(fld)] = deal(dir_val(i));
    end

    % Combines all headers
    hds = [hds; t2];

    % Resorts the header information
    hds = sortFields(hds,'SliceLocation',1);
    if unique_field_vals(hds,'AcquisitionTime') > 1
        hds = sortFields(hds,'AcquisitionTime',1);
    end
    hds = sortFields(hds,'MultiB',1);
    hds = sortFields(hds,fld,1);

end %prepare_edwi_w_t2