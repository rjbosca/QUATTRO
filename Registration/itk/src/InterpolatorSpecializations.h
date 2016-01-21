/*
 *	InterpolatorSpecializations.h
 *
 *	Partial specialization templated class implementation for attaching
 *	an ITK image registration interpolator to an ITK image registration
 *	process object.
 */


#ifndef INTERPOLATORSPECIALIZATIONS_H
#define INTERPOLATORSPECIALIZATIONS_H


/*	Default specialization	*/
template <class TPixel, unsigned int VImageDimension, unsigned int InterpolatorEnum>
class InterpolatorWrapper
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> ImType;

	/*	Class constructor	*/
	InterpolatorWrapper(RegOptsFilter &opts,
						itk::MultiResolutionImageRegistrationMethod<ImType,ImType>* registration)
	{
		mexErrMsgIdAndTxt("QUATTRO:ItkImReg:invalidInterpolatorSettings",
						  "Unknown or unsupported interpolator settings");
	};
};

/*	Linear specialization	*/
template <class TPixel, unsigned int VImageDimension>
class InterpolatorWrapper <TPixel,VImageDimension,Linear>
{

public:

	/*	Template type needed for the image registration
	 *	process object pointer	*/
	typedef itk::Image<TPixel,VImageDimension> ImType;
	typedef itk::LinearInterpolateImageFunction<ImType,TPixel>	InterpolatorType;

	/*	Class constructor	*/
	InterpolatorWrapper(RegOptsFilter &opts,
						itk::MultiResolutionImageRegistrationMethod<ImType,ImType>* registration)
	{

		/*	Instantiate and attach the interpolator to the
		 *	registration process object	*/
		InterpolatorType::Pointer	interpolator = InterpolatorType::New();
		registration->SetInterpolator(interpolator);

	};
};

#endif