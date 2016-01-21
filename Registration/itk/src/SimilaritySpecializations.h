/*
 *	SimilaritySpecialization.h
 *
 *	Partial specialization templated class implementation for attaching
 *	an ITK image registration similarity process object to an ITK image 
 *	registration process object.
 */


#ifndef SIMILARITYSPECIALIZATIONS_H
#define SIMILARITYSPECIALIZATIONS_H


/*	ITK similarity metric headers	*/
#include "itkMeanSquaresImageToImageMetric.h"
#include "itkMutualInformationImageToImageMetric.h"
#include "itkGradientDifferenceImageToImageMetric.h"
#include "itkNormalizedCorrelationImageToImageMetric.h"
#include "itkMattesMutualInformationImageToImageMetric.h"
#include "itkMutualInformationHistogramImageToImageMetric.h"
#include "itkNormalizedMutualInformationHistogramImageToImageMetric.h"

/*	ITK image processing headers	*/
#include "itkNormalizeImageFilter.h"


/*	Default specialization	*/
template <class TPixel, unsigned int VImageDimension, unsigned int SimilarityEnum>
class SimilarityWrapper
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{
		mexErrMsgIdAndTxt("QUATTRO:ItkImReg:invalidSimilaritySettings",
						  "Unknown or unsupported similarity settings");
	};
};

/*	Mean squares specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, MeanSquares>
{

public:

	/*	Template types needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::MeanSquaresImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{
		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric( metric );
	};

};

/*	Normalized cross correlation specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, NormalizedCrossCorrelation>
{

public:

	/*	Template types needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::NormalizedCorrelationImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{
		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric( metric );
	};

};

/*	Gradient difference specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, GradientDifference>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::GradientDifferenceImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{

		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric( metric );

		//	TODO: this should likely be an option
		metric->SetDerivativeDelta( 0.5 );
	};

};

/*	Mutual information specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, MutualInformation>
{

public:

	/*	Template types needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::MutualInformationImageToImageMetric<TImage,TImage> MetricType;
	typedef itk::NormalizeImageFilter<TImage,TImage> NormalizeFilterType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{
		std::cout << "Viola mutual information is unsupported currently" << std::endl;

		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric( metric );

		/*  The metric requires a number of parameters to be selected, including
		 *	the standard deviation of the Gaussian kernel for the fixed image
		 *	density estimate, the standard deviation of the kernel for the moving
		 *	image density and the number of samples use to compute the densities
		 *	and entropy values. Experience has shown that a kernel standard deviation
		 *	of 0.4 works well for images which have been normalized to a mean of zero
		 *	and unit variance. Note that the images are normalized above. */
		metric->SetUseAllPixels(true);
		metric->SetFixedImageStandardDeviation(0.4);	//TODO: this input should be an option
		metric->SetMovingImageStandardDeviation(0.4);	//TODO: this input should be an option
		metric->SetNumberOfSpatialSamples(opts.numberOfSamples);

		/*	Grab the images from the registration object	*/
		TImage*	fImage = (TImage*)registration->GetFixedImage();
		TImage*	mImage = (TImage*)registration->GetMovingImage();

		/*	Viola mutual information performs substantially better when the 
		 *	images are normalized	*/
		//	TODO: grab the blurb from the ITK documentation/example
		NormalizeFilterType::Pointer fNormalizer = NormalizeFilterType::New();
		NormalizeFilterType::Pointer mNormalizer = NormalizeFilterType::New();
		fNormalizer->SetInput(fImage);
		mNormalizer->SetInput(mImage);
//		registration->SetFixedImage( (TImage*)fNormalizer);
//		registration->SetMovingImage(mNormalizer->GetOutput()		);
//		fNormalizer->Update();
		mNormalizer->Update();
	};

};

/*	Mattes mutual information specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, MattesMutualInformation>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::MattesMutualInformationImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{

		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric( metric );

		/*  The metric requires two parameters to be selected: the number of bins
		 *	used to compute the entropy and the number of spatial samples used to
		 *	compute the density estimates. In typical application 50 histogram bins
		 *	are sufficient. Note however, that the number of bins may have dramatic
		 *	effects on the optimizer's behavior. The number of spatial samples to be
		 *	used depends on the content of the image. If the images are smooth and do
		 *	not contain much detail, then using approximately $1$ percent of the
		 *	pixels will do. On the other hand, if the images are detailed, it may be
		 *	necessary to use a much higher proportion, such as $20$ percent. */
		metric->SetNumberOfHistogramBins(opts.numberOfBins);
		metric->SetNumberOfSpatialSamples(opts.numberOfSamples);
		metric->ReinitializeSeed(76926294);

	};

};

/*	Mutual information histogram specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, MutualInformationHistogram>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::MutualInformationHistogramImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{

		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric(metric);

		//	Set the histogram size
		typedef MetricType::HistogramSizeType	HistogramSizeType;
		HistogramSizeType						histogramSize;
		histogramSize.SetSize(2); //TODO: is there ever a reason to have a value > 2?
		histogramSize[0] = opts.numberOfBins;
		histogramSize[1] = opts.numberOfBins;
		metric->SetHistogramSize( histogramSize );

	};

};

/*	Normalized mutual information histogram specialization	*/
template <class TPixel, unsigned int VImageDimension>
class SimilarityWrapper <TPixel, VImageDimension, NormalizedMutualInformationHistogram>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> TImage;
	typedef itk::NormalizedMutualInformationHistogramImageToImageMetric<TImage,TImage> MetricType;

	/*	Class constructor	*/
	SimilarityWrapper(RegOptsFilter &opts,
					  itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration)
	{

		/*	Instantiate the metric and attach it to the registration 
		 *	process object	*/
		MetricType::Pointer metric = MetricType::New();
		registration->SetMetric(metric);

		/*	Set the histogram size	*/
		typedef MetricType::HistogramSizeType	HistogramSizeType;
		HistogramSizeType						histogramSize;
		histogramSize.SetSize(2); //TODO: is there ever a reason to have a value > 2?
		histogramSize[0] = opts.numberOfBins;
		histogramSize[1] = opts.numberOfBins;
		metric->SetHistogramSize( histogramSize );

		//TODO: in the example "ImageRegistration15", the "SetDerivativeStepLengthScales"
		//is set. Should that be done here?
	};

};


#endif