function itkReg3D
%itkReg3D  Registers to 3D images
%
%   Usage:
%
%   itkReg3D fixedImageFile movingImageFile [outputImageFile] [stepSizeMax]
%            [stepSizeMin] [similarityMetric] [nSpatialSamples]
%
%
%   Description:
%
%   itkReg3D is an executable written using the ITK libraries that allows the
%   user to perform 3D rigid image registration. While the original design was
%   centered around integrating this function with the qt_reg class, the
%   executable can be run equally as well in a stand-alone capacity.
%
%
%   Inputs:
%
%   fixedImageFile  - the file name of the *.mha image containing the fixed
%                     image (see mhawrite) to which the moving image is
%                     registered 
%
%   movingImageFile - the file name of the *.mha file containing the moving
%                     image to be registered with the fixed image
%
%   iterHistFile    - name of file in which to write the iteration history
%
%
%   Options:
%
%   outputImageFile - the file name of an *.mha file to which the registered
%                     moving image will be written to. This file need not exist.
%
%   stepSizeMax     - the maximum step size that will be used when registering
%                     the smallest pyramid. Too large of a step size will
%                     potentially negatively affect the registration convergence
%                     to the "correct" solution. For each pyramid level, the
%                     maximum step size is halved. Default: 8.0
%
%   stepSizeMin     - the minimum step size that will be used when registering
%                     the smallest pyramid. Default: 1.0e-5
%
%   nSpatialSamples - the number of spatial samples to use (only for mutual
%                     information). The value you can either be the number of
%                     pixels (n>1) to use or a percentage (0<n<=1).
%
%   nPyramids       - the number of pyramids to use for multi-resolution
%                     registration. Default: 3
%
%   similarityType  - the similarity measure to use. Either 0 or 1 where the
%                     former uses Mattes mutual information and the latter uses
%                     normalized cross correlation. Default: 0 