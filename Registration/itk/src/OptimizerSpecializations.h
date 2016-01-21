/*
 *	OptimizerSpecialization.h
 *
 *	Partial specialization templated class implementation for attaching
 *	an ITK image registration optimizer to an ITK image registration
 *	process object.
 */


#ifndef OPTIMIZERSPECIALIZATIONS_H
#define OPTIMIZERSPECIALIZATIONS_H

//	Optimizer headers
#include "itkGradientDescentOptimizer.h"
#include "itkRegularStepGradientDescentOptimizer.h"


/*	Default specialization	*/
template <class TPixel, unsigned int VImageDimension, unsigned int OptimizerEnum>
class OptimizerWrapper
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> ImageType;

	/*	Class constructor	*/
	OptimizerWrapper(RegOptsFilter &opts,
					 itk::MultiResolutionImageRegistrationMethod<ImageType,ImageType>* registration)
	{
		std::cerr << "Unknown or unsupported optimizer settings" << std::endl;
	};
};

/*	2D regular gradient step sepcialization	*/
template <class TPixel, unsigned int VImageDimension>
class OptimizerWrapper<TPixel, VImageDimension, RegularGradientStep>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> ImageType;

	/*	Class constructor	*/
	OptimizerWrapper(RegOptsFilter &opts,
					 itk::MultiResolutionImageRegistrationMethod<ImageType,ImageType>* registration)
	{
		
		/*	Initialize the workspace */
		bool isMaximize =	(opts.similarity==MutualInformation) ||
							(opts.similarity==MattesMutualInformation) ||
							(opts.similarity==MutualInformationHistogram) ||
							(opts.similarity==NormalizedCrossCorrelation) ||
							(opts.similarity==NormalizedMutualInformationHistogram);

		/*	Create the optimizer	*/
		typedef itk::RegularStepGradientDescentOptimizer	OptimizerType;
		OptimizerType::Pointer								optimizer = OptimizerType::New();
		registration->SetOptimizer(optimizer);

		/*	Set the optimizer options	*/
		optimizer->SetMaximumStepLength(opts.stepSizeMax);
		optimizer->SetMinimumStepLength(opts.stepSizeMin);
		optimizer->SetNumberOfIterations(opts.numberOfIter);
		optimizer->SetRelaxationFactor( 0.9 );

		/*	Invert the optimization if necessary. By default the gradient descent 
		 *	optimizers are set to minimize the similarity metric */
		if (isMaximize)
		{
			optimizer->MaximizeOn(); //TODO: which metrics is this switch needed for?
		};

		/*	Create the Command observer and register it with the optimizer	*/
		//CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();
		//optimizer->AddObserver( itk::IterationEvent(), observer );

	};
};


#endif