/*
 * MatlabRegHeader.hxx
 *
 * Class to provide an interface to read registration options from an input
 * structure. This provides a convenient and efficient means of communicating
 * various options to the image registration tasks.
 *
 * When adding options for a specific implementation, those options should be
 * added here. All options must define a default value in the class definition
 *
 */

#ifndef REGOPTIONSFILTER_H
#define REGOPTIONSFILTER_H


/*	C++ headers	*/
#include <iostream>
#include <vector>
#include <string>

/*	General ITK headers	*/
#include "itkImageRegistrationMethod.h"
#include "itkMultiResolutionImageRegistrationMethod.h"

/*	QUATTRO headers	*/



//	Define common types
enum similarityType{		//	Similarity flag - see SetSimilarity above for details
	MeanSquares,
	GradientDifference,
	MutualInformation,
	NormalizedCrossCorrelation,
	MattesMutualInformation,
	MutualInformationHistogram,
	NormalizedMutualInformationHistogram
};

enum transformType{		//	Transform flag - see the "Initialize transformation type" below
	Euler,
	Affine
};

enum optimizerType{
	RegularGradientStep
};

enum interpolationType{
	Linear
};




class RegOptsFilter{

 public:

     /*
	  * Public properties
	  *===================
	  */

     float	stepSizeMax;		//	Maximum step size
     float	stepSizeMin;		//	Minimum step size
     float	numberOfBins;		//	Number of bins to use for histogram based similarity metrics
     float	numberOfIter;		//	Maximum number of iterations to use
     float	numberOfSamples;	//	Number of spatial samples to use when calculating
								//	the similarity metric
     float	numberOfPyramids;	//	Number of pyramids to use in multi-resolution scheme
     float	intensityThreshold;	//	Minimum threshold of pixel for selection by metric
	 float	learningRate;		//	Gradient descent optimizer learning rate
	 float	dimensions;			//	Number of image dimension

	 similarityType		similarity;		/*	Similarity metric to be used	*/
	 transformType		transform;		/*	Type of transformation	*/
	 interpolationType	interpolator;	/*	type of image interpolation	*/
	 optimizerType		optimizer;		/*	type of registration optimizer	*/

	 std::string targetFile;
	 std::string movingFile;
	 std::string historyFile;

	 std::ofstream historyOut;

     /*
	  * Public methods
	  *================
	  */

	 /*
	  *	RegOptsFilter()
	  *
	  *	Class constructor
	  */
     RegOptsFilter(int argc, char *argv[]);

	 /*
	  *	GetImagePointerFromFile()
	  *
	  *	Function to read an image from a specified file name and return
	  *	the ITK image pointer.
	  */
	 template <class TPixel, unsigned int VImageDimension>
	 typename itk::Image<TPixel,VImageDimension>::Pointer GetImagePointerFromFile(std::string FName);

	 /*
	  *	WriteImagePointerToFile()
	  *
	  *	Function to write an image from an ITK image pointer to a file
	  */
	 template <class TPixel, unsigned int VImageDimension>
	 void WriteImagePointerToFile(std::string FName,
								  typename itk::Image<TPixel,VImageDimension>::Pointer image);

	 /*
	  *	isReady()
	  *
	  *	Helper function to determine if all necessary inputs
	  *	and options have been specified
	  */
	 bool isReady(int nArgs);

	 /*
	  *	parseInterpolatorToTemplate()
	  *
	  *	Uses the template parameters to call specialized classes
	  *	that attach an interpolation scheme to the registration
	  *	process object.
	  */
	 template <class TPixel, unsigned int VImageDimension, class TImage>
	 void parseInterpolatorToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration);

	 /*
	  *	parseOptimizerToTemplate()
	  *
	  *	Uses the template parameters to call specialized classes
	  *	that attach an optimizer scheme to the registration
	  *	process object.
	  */
	 template <class TPixel, unsigned int VImageDimension, class TImage>
	 void parseOptimizerToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration);

	 /*
	  *	parseInputSimilarityToTemplate()
	  *
	  *	Uses the template parameters to call specialized classes
	  *	that attach a similarity metric to the registration
	  *	process object.
	  */
	 template <class TPixel, unsigned int VImageDimension, class TImage>
	 void parseSimilarityToTemplate(itk::MultiResolutionImageRegistrationMethod<TImage,TImage>* registration);

};


#ifndef ITK_MANUAL_INSTANTIATION
#include "RegOptionsFilter.hxx"
#endif

#endif // REGOPTIONSFILTER_H