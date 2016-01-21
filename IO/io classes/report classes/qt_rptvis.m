classdef qt_rptvis
%QUATTRO report visualization base class
%
%   qt_rptvis is an abstract class that defines common properties for report
%   objects that define visualizations.
%
%   Type "doc qt_rptvis" for a summary of all properties and methods that are
%   common to report visualization classes


    %------------------------------- Properties --------------------------------
    properties

        % qt_rptfig object
        %
        %   "fig" is a qt_rptfig object that allows the user to define custom
        %   figure properties when creating visualizations for reports
        fig = qt_rptfig;

        % Output image format
        %
        %   "imageFormat" is a string that specifies the output format of the
        %   image. Default: 'png'
        imageFormat = 'png'

        % Output image resolution
        %
        %   "imageRes" is the resolution at which the visualization is printed.
        %   For more information the documentation for PRINT. Default: 300
        imageRes = 300;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rptvis(varargin)
        %qt_rptvis  Constructor for qt_rptvis class
        %
        %   qt_rptvis is an abstract class and, as such, creating an instance of
        %   this class is not allowed.
        end %qt_rptvis.qt_rptvis

    end %class constructor

end %qt_rptvis