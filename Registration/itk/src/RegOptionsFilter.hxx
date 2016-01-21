
#ifndef REGOPTIONSFILTER_HXX
#define REGOPTIONSFILTER_HXX


// QUATTRO headers
#include "RegOptionsFilter.h"

//  Image IO and computation headers
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkCastImageFilter.h"


/*
 *	RegOptsFilter()
 *
 *	Class constructor that pre-processes the command prompt 
 *	option inputs corresponding to the image registration task
 *
 */
RegOptsFilter::RegOptsFilter(int argc, char *argv[]){

    /*	Define the default registration options	*/
	this->stepSizeMax			= 5.0;
	this->stepSizeMin			= 1.0e-5;
	this->numberOfBins			= 128;
	this->numberOfIter			= 500;
	this->numberOfSamples		= 0;
	this->numberOfPyramids		= 3;
	this->intensityThreshold	= 0;
	this->learningRate			= 0.9;
	this->dimensions			= 0;
	this->similarity			= NormalizedCrossCorrelation;
	this->transform				= Euler;
	this->interpolator			= Linear;
	this->optimizer				= RegularGradientStep;
	this->targetFile			= "";
	this->movingFile			= "";
	this->historyFile			= "";

	/*	Handle the necessary inputs	*/
	if( argc > 4) {
		this->dimensions	= atoi( argv[1] );
		this->targetFile	= argv[2];
		this->movingFile	= argv[3];
		this->historyFile	= argv[4];
	};


	/*	Currently, all options (image files, registration options, etc.)
	 *	are passed directly to the registration executable via the 
	 *	command prompt. In the future, an INI file will handle these
	 *	options. For now they are parsed here,...	*/
	if( argc > 5 ) {	//	maximum step size
		this->stepSizeMax = atof( argv[5] );
	};
	std::cout << "Setting maximun step size to: " << this->stepSizeMax << std::endl;
	if( argc > 6 ) {	//	minimum step size
		this->stepSizeMin = atof( argv[6] );
	};
	std::cout << "Setting minimun step size to: " << this->stepSizeMin << std::endl;
	if( argc > 7 ) {	//	number of spatial samples
		this->numberOfSamples = atof(argv[7]);
		if( (numberOfSamples>1) || (numberOfSamples<=0) ) {
			std::cerr << "The number of spatial samples should be provided as" << std::endl
					  << "a fraction (i.e., value between 0 and 1) of voxels" << std::endl
					  << "to use in computing the image similarity" << std::endl;
			this->numberOfSamples = 0.1;
		};
	};
	std::cout << "Setting # of spatial samples to: " << numberOfSamples*100 << "%" << std::endl;
	if( argc > 8 ) {	//  number of pyramids to use
		this->numberOfPyramids = atoi( argv[8] );
	};
	if( argc > 9 ) {	//	minimum pixel value to use
		this->intensityThreshold = atof( argv[9] );
	};
	if( argc > 10 ) {	//  similarity metric to use
		this->similarity = static_cast<similarityType>(atoi( argv[10] ));
		if( (this->similarity<0) | (this->similarity>6) ) {
			std::cerr << "Invalid similarity specifier: " << this->similarity << std::endl;
			std::cerr << "0 - Mean squares" << std::endl;
			std::cerr << "1 - Gradient difference" << std::endl;
			std::cerr << "2 - Mutual information" << std::endl;
			std::cerr << "3 - Normalized cross correlation" << std::endl;
			std::cerr << "4 - Mattes mutual information" << std::endl;
			std::cerr << "5 - Mutual information histogram" << std::endl;
			std::cerr << "6 - Normalized mutual information histogram" << std::endl << std::endl;
			std::cerr << "Setting the metric to normalized cross correlation" << std::endl;
			this->similarity = NormalizedCrossCorrelation;
		};
	};
	if( argc > 11 ) {	//	number of iterations
		this->numberOfIter = atoi( argv[11] );
		if( this->numberOfIter<1 ) {
			std::cerr << "Invalid maximum number of iterations: " << this->numberOfIter << std::endl;
			std::cerr << "# of iterations must be greater than 1" << std::endl << std::endl;
			std::cerr << "Setting the # of iterations to the default: 500" << std::endl;
			this->numberOfIter = 500;
		};
	};
	if( argc > 12 ) {	//	transformation type
		this->transform = static_cast<transformType>(atoi( argv[12] ));
		if( (this->transform<0) | (this->transform>1) ) {
			std::cerr << "Invalid transform specifier: " << this->transform << std::endl;
			std::cerr << "0 - 3D Euler transformation"   << std::endl;
			std::cerr << "1 - 3D affine transformation"  << std::endl <<std::endl;
			std::cerr << "Setting the transformation to the default: Euler" << std::endl;
			this->transform = Euler;
		};
	};

};


/*
 *	GetImagePointerFromFile()
 *
 *	Function for getting an ITK image pointer from an MHA file.
 *
 */
template <class TPixel, unsigned int VImageDimension>
typename itk::Image<TPixel,VImageDimension>::Pointer RegOptsFilter::GetImagePointerFromFile(std::string FName)
{
	/*	Instantiate the image reader and apply the file name	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::ImageFileReader<TImage> TImageReader;
	TImageReader::Pointer imageReader = TImageReader::New();
	imageReader->SetFileName( FName );

	/*	Instantitate an image caster and apply the output of 
	 *	the image reader	*/
	typedef itk::CastImageFilter<TImage,TImage> TCastFilter;
	TCastFilter::Pointer imageCaster = TCastFilter::New();
	imageCaster->SetInput( imageReader->GetOutput() );

	/*	Update the image caster to fire the image read operation
	 *	and send the output	*/
	imageCaster->Update();
	return imageCaster->GetOutput();

};


/*
 *	WriteImagePointerToFile()
 *
 *	Function for writing an ITK image pointer to an MHA file
 */
template <class TPixel, unsigned int VImageDimension>
void RegOptsFilter::WriteImagePointerToFile(std::string FName,
											typename itk::Image<TPixel,VImageDimension>::Pointer image) {

	/*	Instantiate the caster and writer filters	*/
	typedef itk::Image<TPixel,VImageDimension>	TImage;
	typedef itk::CastImageFilter<TImage,TImage>	TCaster;
	typedef itk::ImageFileWriter<TImage>		TWriter;
	TWriter::Pointer	writer = TWriter::New();
	TCaster::Pointer	caster = TCaster::New();

	/*	Update the writer and caster with the file information	*/
	caster->SetInput( image );
	writer->SetInput( caster->GetOutput() );
	writer->SetFileName(FName);

	/*	Write the image	*/
	writer->Update();

};


/*
 *	isReady()
 *
 */
bool RegOptsFilter::isReady(int nArgs)
{
	/*	Input/output validation.	*/
	
	/*	At a minimum, there should be three inputs corresponding to 
	 *	the target image file, moving image file and output iteration 
	 *	history file. Any fewer and the user should be notified of 
	 *	the appropriate syntax and the program should exit.	*/
	if( nArgs < 4 ) { /*check for minimum # of inputs*/
		std::cerr << "Missing Parameters " << std::endl;
		std::cerr << "Usage: itkReg";
		std::cerr << " DIMENSIONS   TARGETFILE   MOVINGFILE   ITERATIONFILE";
		std::cerr << "[OUTPUTIMAGE] [STEPSIZEMAX] [STEPSIZEMIN] ";
		std::cerr << "[PIXELTHRESH] [METRIC] [#ITERATIONS]" << std::endl;
		return false;
	};

	/*	Ensure that the output history file can be written to	*/
	if( !historyOut.is_open() ) {
		historyOut.open(historyFile, std::ofstream::out | std::ofstream::trunc);
		if( !historyOut.is_open() ) {
			std::cerr << "Unable to open the iteration history file" << std::endl;
			return false;
		};
	};
	
	/*	Ensure that the image dimensionality was ready properly	*/
	if( dimensions==0 ) {
		std::cerr << "Invalid or missing image dimensions input" << std::endl;
		return false;
	};

	return true;
};


/*
 *	parseInterpolatorToTemplate()
 *
 *	Uses the template parameters to call specialized classes
 *	that attach an interpolation scheme to the registration
 *	process object.
 */
template <class TPixel, unsigned int VImageDimension, class TImage>
void
RegOptsFilter::parseInterpolatorToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
{
	switch (interpolator) {
		case Linear:
			InterpolatorWrapper<TPixel,VImageDimension,Linear>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
			break;
		default:
			std::cerr << "Only Linear transformations are supported currently." << std::endl;
			break;
	};
};


/*
 *	parseOptimizerToTemplate()
 *
 *	Uses the template parameters to call specialized classes
 *	that attach an interpolation scheme to the registration
 *	process object.
 */
template <class TPixel, unsigned int VImageDimension, class TImage>
void
RegOptsFilter::parseOptimizerToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
{
	switch (optimizer) {
	case RegularGradientStep:
		OptimizerWrapper<TPixel,VImageDimension,RegularGradientStep>(*this,
			dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
		break;
	default:
		std::cerr << "Unknown or unsupported optimizer scheme." << std::endl;
		break;
	};
};


/*
 *	parseInputSimilarityToTemplate()
 *
 *	Uses the template parameters to call specialized classes
 *	that attach a similarity metric to the registration
 *	process object.
 */
template<class TPixel, unsigned int VImageDimension, class TImage>
void 
RegOptsFilter::parseSimilarityToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
{
	if (similarity==MeanSquares) {
		SimilarityWrapper<TPixel,VImageDimension,MeanSquares>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==NormalizedCrossCorrelation) {
		SimilarityWrapper<TPixel,VImageDimension,NormalizedCrossCorrelation>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==GradientDifference) {
		SimilarityWrapper<TPixel,VImageDimension,GradientDifference>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==MutualInformation) {
		SimilarityWrapper<TPixel,VImageDimension,MutualInformation>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==MattesMutualInformation) {
		SimilarityWrapper<TPixel,VImageDimension,MattesMutualInformation>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==MutualInformationHistogram) {
		SimilarityWrapper<TPixel,VImageDimension,MutualInformationHistogram>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else if (similarity==NormalizedMutualInformationHistogram) {
		SimilarityWrapper<TPixel,VImageDimension,NormalizedMutualInformationHistogram>(*this,
				dynamic_cast<itk::MultiResolutionImageRegistrationMethod<TImage,TImage>*>(registration) );
	}
	else {
		std::cerr << "Unknown or unsupported similarity metric." << std::endl;
	};

};

#endif	/*REGOPTIONSFILTER_HXX*/