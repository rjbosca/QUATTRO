/*
 *	itkReg.cxx
 *
 *
 *	Inputs:
 *	=======
 *
 *		TARGET: full file name to an MHA image file to
 *				be used as the target image
 *
 *		MOVING: full file name to an MHA image file to
 *				be used as the moving image
 *
 *		HISTORY: full file name to the iteration history
 *
 *		OUTPUT: full file name to a target output file
 *				that will contain the registered moving
 *				image
 *
 *		MAXSTEP: maximum gradient step size
 *
 *		MINSTEP: minimum gradient step size
 *
 *		THRESH: minimum image signal intensity threshold
 *
 *		METRIC: numeric value specifying the similarity
 *				metric to use when computing similarity
 *				between the target and moving images.
 *
 *		ITER: maximum number of optimizer iterations
 */


#ifndef ITKREG_CXX
#define ITKREG_CXX


//  Transformation headers
#include "itkEuler3DTransform.h"                          //Transform header (Rigid 3D)
#include "itkEuler2DTransform.h"
#include "itkCenteredTransformInitializer.h"              //Additional transform header (only for Rigid 3D)
#include "itkAffineTransform.h"							  //Transform header (Affine 3D)

//  Optimizer headers
#include "itkRegularStepGradientDescentOptimizer.h"       //Optimizer header (must be itkVersorRigid3DTransformOptimizer for Rigid 3D)

//  Image processing headers
#include "itkNormalizeImageFilter.h"
#include "itkResampleImageFilter.h"
#include "itkExtractImageFilter.h"
#include "itkImageMaskSpatialObject.h"

/*	QUATTRO headers	*/
#include "RegOptionsFilter.h"
#include "InterpolatorSpecializations.h"
#include "OptimizerSpecializations.h"
#include "SimilaritySpecializations.h"

//  Command observer for monitoring registration evolution
#include "itkCommand.h"



//	Command observer called after each registration iteration
class CommandIterationUpdate : public itk::Command
{
public:
  typedef CommandIterationUpdate    Self;
  typedef itk::Command              Superclass;
  typedef itk::SmartPointer<Self>   Pointer;
  itkNewMacro( Self );

protected:
  CommandIterationUpdate() {};

public:
  typedef itk::RegularStepGradientDescentOptimizer	TOptimizer;
  typedef const TOptimizer *						OptimizerPointer;
  std::string										regHistFileName;

  void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *)caller, event);
    }
  void Execute(const itk::Object * object, const itk::EventObject & event)
    {
    OptimizerPointer optimizer =
      dynamic_cast< OptimizerPointer >( object );
    if( ! itk::IterationEvent().CheckEvent( &event ) )
      {
      return;
      }
	std::fstream outFile;
	if( !outFile.is_open() ) {
		outFile.open(regHistFileName,std::fstream::out | std::fstream::app);
	};
	if( outFile.is_open() )
	{
		outFile.precision(10);
	    outFile << optimizer->GetCurrentIteration() << '\t';
	    outFile << optimizer->GetValue() << '\t';
		outFile << optimizer->GetCurrentPosition() << std::endl;
	}
    std::cout << optimizer->GetCurrentIteration() << "   ";
    std::cout << optimizer->GetValue() << "   ";
    std::cout << optimizer->GetCurrentPosition() << std::endl;
    }
  void SetFileName(std::string fileName)
	{
	  regHistFileName	 = fileName;
    }
};


//  The following section of code implements the multi-resolution
//  registration command interface
template <typename TRegistration>
class RegistrationInterfaceCommand : public itk::Command
{
public:
  typedef  RegistrationInterfaceCommand   Self;
  typedef  itk::Command                   Superclass;
  typedef  itk::SmartPointer<Self>        Pointer;
  itkNewMacro( Self );

protected:
  RegistrationInterfaceCommand() {};

public:
  typedef   TRegistration								TRegistration;
  typedef   TRegistration *								RegistrationPointer;
  typedef   itk::RegularStepGradientDescentOptimizer	TOptimizer;
  typedef   TOptimizer *								OptimizerPointer;
  std::string											regHistFileName;
//  RegOptionsFilter 							&opts;
  float													pixelPct;

  void Execute(itk::Object * object, const itk::EventObject & event)
    {
    if( !(itk::IterationEvent().CheckEvent( &event )) )
      {
      return;
      }
    RegistrationPointer registration = dynamic_cast< RegistrationPointer >( object );
    OptimizerPointer    optimizer    = dynamic_cast< OptimizerPointer >( registration->GetOptimizer() );

	// Create an optimizer scale variable
    typedef TOptimizer::ScalesType       OptimizerScalesType;
	OptimizerScalesType optimizerScales = optimizer->GetScales();

	// Create the image size
    typedef itk::Image<double,3>	ImageType;
	const unsigned int numPixels = registration->GetFixedImageRegion().GetNumberOfPixels();

	// Get the scales
	typedef itk::MultiResolutionPyramidImageFilter<ImageType,ImageType>   ImagePyramidType;
    ImagePyramidType::ScheduleType  pyramidSchedule = registration->GetMovingImagePyramidSchedule();

	// Open file for writing
	std::ofstream outFile;
	outFile.precision(2);
	outFile.open(regHistFileName,std::ofstream::out | std::ofstream::app);

	//	Calculate the new number of spatial samples to use
	if( (registration->GetMetric()->GetNameOfClass()=="MattesMutualInformationImageToImageMetric") |
		(registration->GetMetric()->GetNameOfClass()=="MutualInformationImageToImageMetric") )
	{
		const unsigned int	lvl      = registration->GetCurrentLevel();
		const unsigned int	nSamples = pixelPct * numPixels / (pyramidSchedule[lvl][0] * pyramidSchedule[lvl][1]);
		registration->GetMetric()->SetNumberOfSpatialSamples( nSamples );
		outFile << "Number of spatial samples: "
				<< registration->GetMetric()->GetNumberOfSpatialSamples()
				<< " of " << numPixels / (pyramidSchedule[lvl][0] * pyramidSchedule[lvl][1])
				<< std::endl;

		//	Reduce the number of spatial samples
		pixelPct = pixelPct*0.5;
	}

	// Print info for the user
	if( outFile.is_open() )
	{
		outFile << "Maximum Step Length: "
				<< optimizer->GetMaximumStepLength() << std::endl;
		outFile << "Minimum Step Length: "
				<< optimizer->GetMinimumStepLength() << std::endl;
		outFile << "-------------------------------------" << std::endl;
		outFile << "Pyramid Schedule: [" << pyramidSchedule[registration->GetCurrentLevel()][0] 
				<< " " << pyramidSchedule[registration->GetCurrentLevel()][1]
				<< " " << pyramidSchedule[registration->GetCurrentLevel()][2] << "]" << std::endl;
		outFile << "MultiResolution Level: "
				<< registration->GetCurrentLevel()  << std::endl << std::endl;
		outFile.close();
	}
	std::cout << std::endl << "Maximum Step Length: " 
		      << optimizer->GetMaximumStepLength() << std::endl;
	std::cout << "Minimum Step Length: "
		      << optimizer->GetMinimumStepLength() << std::endl;
	std::cout << "Number of Spatial Samples: "
			  << registration->GetMetric()->GetNumberOfSpatialSamples() << std::endl;
	std::cout << "-------------------------------------" << std::endl;
    std::cout << "MultiResolution Level: "
              << registration->GetCurrentLevel()  << std::endl << std::endl;

    if ( registration->GetCurrentLevel() == 0 )
    {
		// Set the scales. Note that the rotation scale for the Euler 3D transform is static
		if ( registration->GetTransform()->GetNameOfClass()=="Euler3DTransform" )
		{
			optimizerScales[0] = 1.0; // scale for rotation about x axis
			optimizerScales[1] = 1.0; // scale for rotation about y axis
			optimizerScales[2] = 1.0; // scale for rotation about z axis
			optimizerScales[3] = 1.0e-3; // scale for x translations
			optimizerScales[4] = 1.0e-3; // scale for y translations
			optimizerScales[5] = 1.0e-3; // scale for z translations
		}
		if (registration->GetTransform()->GetNameOfClass()=="AffineTransform")
		{
			for(int idx=0;idx<=8;idx++)
			{
					optimizerScales[0] = 1.0; // scale for Mij
			}
			optimizerScales[9]  = 1.0e-6; // scale for x translations
			optimizerScales[10] = 1.0e-6; // scale for y translations
			optimizerScales[11] = 1.0e-6; // scale for z translations
		}

		// Note that the minimum/maximum step lengths and number of iterations would normally 
		// be set here, but these values were initialized in main()
    }
	else
    {
		optimizer->SetMaximumStepLength(  optimizer->GetMaximumStepLength() / 2.0 );
		optimizer->SetMinimumStepLength(  optimizer->GetMinimumStepLength() / 10.0 );
		optimizer->SetNumberOfIterations( optimizer->GetNumberOfIterations() );
    }

	// Set the optimizer scales before returning
    optimizer->SetScales( optimizerScales );
    }

  void Execute(const itk::Object * , const itk::EventObject & )
    { return; }

  void SetFileName(std::string outFile)
  {
	  regHistFileName = outFile;
  }

  void SetPixelPercentage( float pct )
  {
	  pixelPct = pct;
  }
};



/*
 *	RegWrapper():
 *
 *	Class definition for the templated class RegWrapper. This 
 *	class is used to specialize the registration task based on 
 *	user input from MATLAB.
 *
 *	As stated in the comments of the Gerardus project, defining
 *	this class allows partial specialization with instantiation
 *	of various ITK objects without error checking on the task
 *	specific requirements (i.e., an 2D Euler transform will not
 *	work with 3D images). Otherwise these instantiating such
 *	objects would give compilation errors.
 */
template <class TPixel, unsigned int VImageDimension, unsigned int TransformEnum>
class RegWrapper{

 public:

	 RegWrapper(RegOptsFilter &opts)
	 {
		 std::cerr << "Unknown or unsupported registration task." << std::endl;
	 };

};


/* ----------------------
 *	Euler transformation
 * ----------------------*/

//	2D specialization
template <class TPixel>
class RegWrapper<TPixel,2,Euler>{

	/*	Common types	*/
	typedef itk::Image<TPixel,2>	TImage;	/*all images from QUATTRO are
											 *expected to be doubles*/
	typedef itk::Euler2DTransform<double>								TTransform;
	typedef itk::RegularStepGradientDescentOptimizer					TOptimizer;
	typedef itk::MultiResolutionImageRegistrationMethod<TImage,TImage>	TRegistration;
	typedef itk::MultiResolutionPyramidImageFilter<TImage,TImage>		TImagePyramid;

 public:

	 RegWrapper(RegOptsFilter &opts){

		 /*=============================*
		  *	Registration object setup
		  *=============================*/

		 /*  Instantiate the registration components (except for 
		  *	the similarty and transformation types as these will
		  *	be handled by the specialization parsers to follow)	*/
		 TRegistration::Pointer	registration		= TRegistration::New();
		 TImagePyramid::Pointer	fixedImagePyramid	= TImagePyramid::New();
		 TImagePyramid::Pointer	movingImagePyramid	= TImagePyramid::New();

		 /*	Register the various process objects with the
		  *	registration object	*/
		 opts.parseSimilarityToTemplate<TPixel,2,TImage>(registration);
		 opts.parseInterpolatorToTemplate<TPixel,2,TImage>(registration);
		 opts.parseOptimizerToTemplate<TPixel,2,TImage>(registration);
		 registration->SetFixedImagePyramid(  fixedImagePyramid );
		 registration->SetMovingImagePyramid( movingImagePyramid );


		 /*==============*
		  *	Image setup
		  *==============*/

		 TImage::Pointer fixedImage = opts.GetImagePointerFromFile<TPixel,2>(opts.targetFile);
		 TImage::Pointer movingImage = opts.GetImagePointerFromFile<TPixel,2>(opts.movingFile);

		 if( opts.similarity!=MutualInformation ) {
			 registration->SetFixedImage(fixedImage);
			 registration->SetMovingImage(movingImage);
		 }
		 else {	//	Special case for Viola mutual information

			 /*	Create a normalizing filter	*/
			 typedef itk::NormalizeImageFilter<TImage,TImage> TNormalizeFilter;
			 TNormalizeFilter::Pointer	fixedNormalizer		= TNormalizeFilter::New();
			 TNormalizeFilter::Pointer	movingNormalizer	= TNormalizeFilter::New();
			 fixedNormalizer->SetInput(fixedImage);
			 movingNormalizer->SetInput(movingImage);
			 
			 /*	Set fixed/moving images	*/
			 registration->SetFixedImage( fixedNormalizer->GetOutput() );
			 registration->SetMovingImage( movingNormalizer->GetOutput() );
			 fixedNormalizer->Update();
			 movingNormalizer->Update();
		 };
		 registration->SetFixedImageRegion(fixedImage->GetLargestPossibleRegion());


		 /*================================*
		  *	Transformation initialization
		  *================================*/

		 /*	Initialize the scales	*/
		 /*TODO: this is temporary. The problem is that I need to find a
		  *		way to set the optimizer scales and relaxation factor,
		  *		but these settings are dependent on the type of transform.
		  *		Regardless, fix this...	*/
		 TOptimizer*			optimizer = (TOptimizer*)registration->GetOptimizer();
		 TTransform::Pointer	transform = TTransform::New();

		 /*	Register the transformation object to the registration object	*/
		 registration->SetTransform( transform );
	 
		 /*	Instantiate the transform initializer	*/
		 typedef itk::CenteredTransformInitializer<TTransform,TImage,TImage> TInitializer;
		 TInitializer::Pointer initializer = TInitializer::New();
	 
		 /*	Initialize the registration parameters and link to the registration object	*/
		 initializer->SetTransform(transform);
		 initializer->SetFixedImage(fixedImage);
		 initializer->SetMovingImage(movingImage);
		 initializer->MomentsOn();
		 initializer->InitializeTransform();
		 registration->SetInitialTransformParameters( transform->GetParameters() );	//	initial transform

		 /*	Set some final transformation links	*/
		 typedef TOptimizer::ScalesType  OptimizerScalesType;
		 OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() ); // inital scales
		 for(int i=0; i<optimizerScales.size();i++) {
			 optimizerScales[i] = 1;
		 };
		 registration->GetOptimizer()->SetScales( optimizerScales );


		 /*=============================*
		  *	Registration initialization
		  *=============================*/

		 // Set up the pyramid schedule
		 typedef TImage::SizeType	TSize;
		 const TSize				fixedSize = fixedImage->GetLargestPossibleRegion().GetSize();
		 TImagePyramid::Pointer		fauxImagePyramid = TImagePyramid::New();
		 fauxImagePyramid->SetNumberOfLevels(opts.numberOfPyramids);
		 TImagePyramid::ScheduleType  pyramidSchedule = fauxImagePyramid->GetSchedule();
		 if( (fixedSize[0]/pyramidSchedule[0][1] < 64) & (opts.numberOfPyramids > 1) )
		 {
			 opts.numberOfPyramids = opts.numberOfPyramids-1;
			 fauxImagePyramid->SetNumberOfLevels(opts.numberOfPyramids);
			 pyramidSchedule = fauxImagePyramid->GetSchedule();
		 };
		 registration->SetSchedules(pyramidSchedule,pyramidSchedule);
		 
		 // Create the Command observer and register it with the optimizer.
		 CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();
		 optimizer->AddObserver( itk::IterationEvent(), observer );
		 observer->SetFileName( opts.historyFile );
		 
		 typedef RegistrationInterfaceCommand<TRegistration> CommandType;
		 CommandType::Pointer command = CommandType::New();
		 command->SetFileName(opts.historyFile);
		 std::cerr << "Percentage: " << opts.numberOfSamples*100 << std::endl;
		 command->SetPixelPercentage( opts.numberOfSamples );
		 registration->AddObserver( itk::IterationEvent(), command );


		 /*=====================*
		  *	Register the images
		  *=====================*/

		 // Perform the rigid registration
		 try {
			 registration->Update();
			 opts.historyOut	<< "Optimizer stop condition: "
								<< registration->GetOptimizer()->GetStopConditionDescription()
								<< std::endl;
			 std::cout	<< "Optimizer stop condition: "
						<< registration->GetOptimizer()->GetStopConditionDescription()
						<< std::endl;
		 }
		 catch( itk::ExceptionObject & err ) {
			 std::cerr	<< "ExceptionObject caught !" << std::endl;
			 std::cerr	<< err << std::endl;
			 return;
		 };


		 /*	Create a new transformation object, setting the values for the final 
		  *	transoformation, matrix, and offset (then display the output) */
		 transform->SetParameters( registration->GetLastTransformParameters() );
		 TTransform::MatrixType		finalMatrix	= transform->GetMatrix();
		 TTransform::OffsetType		offset		= transform->GetOffset();
		 std::cout << "Offset = " << std::endl << offset << std::endl;
		 std::cout << "Final matrix = " << std::endl << finalMatrix << std::endl;

	 };
};

//	3D specialization
template <class TPixel>
class RegWrapper<TPixel,3,Euler>{

	/*	Common types	*/
	typedef itk::Image<TPixel,3>	TImage;	/*all images from QUATTRO are
											 *expected to be doubles*/
	typedef itk::Euler3DTransform<double>								TTransform;
	typedef itk::RegularStepGradientDescentOptimizer					TOptimizer;
	typedef itk::MultiResolutionImageRegistrationMethod<TImage,TImage>	TRegistration;
	typedef itk::MultiResolutionPyramidImageFilter<TImage,TImage>		TImagePyramid;


 public:

	 RegWrapper(RegOptsFilter &opts){

		 /*=============================*
		  *	Registration object setup
		  *=============================*/

		 /*  Instantiate the registration components (except for 
		  *	the similarty and transformation types as these will
		  *	be handled by the specialization parsers to follow)	*/
		 TRegistration::Pointer	registration		= TRegistration::New();
		 TImagePyramid::Pointer	fixedImagePyramid	= TImagePyramid::New();
		 TImagePyramid::Pointer	movingImagePyramid	= TImagePyramid::New();

		 /*	Register the various process objects with the
		  *	registration object	*/
		 opts.parseSimilarityToTemplate<TPixel,3,TImage>(registration);
		 opts.parseInterpolatorToTemplate<TPixel,3,TImage>(registration);
		 opts.parseOptimizerToTemplate<TPixel,3,TImage>(registration);
		 registration->SetFixedImagePyramid(  fixedImagePyramid );
		 registration->SetMovingImagePyramid( movingImagePyramid );


		 /*==============*
		  *	Image setup
		  *==============*/

		 TImage::Pointer fixedImage = opts.GetImagePointerFromFile<TPixel,3>(opts.targetFile);
		 TImage::Pointer movingImage = opts.GetImagePointerFromFile<TPixel,3>(opts.movingFile);

		 if( opts.similarity!=MutualInformation ) {
			 registration->SetFixedImage(fixedImage);
			 registration->SetMovingImage(movingImage);
		 }
		 else {	//	Special case for Viola mutual information

			 /*	Create a normalizing filter	*/
			 typedef itk::NormalizeImageFilter<TImage,TImage> TNormalizeFilter;
			 TNormalizeFilter::Pointer	fixedNormalizer		= TNormalizeFilter::New();
			 TNormalizeFilter::Pointer	movingNormalizer	= TNormalizeFilter::New();
			 fixedNormalizer->SetInput(fixedImage);
			 movingNormalizer->SetInput(movingImage);
			 
			 /*	Set fixed/moving images	*/
			 registration->SetFixedImage( fixedNormalizer->GetOutput() );
			 registration->SetMovingImage( movingNormalizer->GetOutput() );
			 fixedNormalizer->Update();
			 movingNormalizer->Update();
		 };
		 registration->SetFixedImageRegion(fixedImage->GetLargestPossibleRegion());


		 /*================================*
		  *	Transformation initialization
		  *================================*/

		 /*	Initialize the scales	*/
		 /*TODO: this is temporary. The problem is that I need to find a
		  *		way to set the optimizer scales and relaxation factor,
		  *		but these settings are dependent on the type of transform.
		  *		Regardless, fix this...	*/
		 TOptimizer*			optimizer = (TOptimizer*)registration->GetOptimizer();
		 TTransform::Pointer	transform = TTransform::New();

		 /*	Register the transformation object to the registration object	*/
		 registration->SetTransform( transform );
	 
		 /*	Instantiate the transform initializer	*/
		 typedef itk::CenteredTransformInitializer<TTransform,TImage,TImage> TInitializer;
		 TInitializer::Pointer initializer = TInitializer::New();
	 
		 /*	Initialize the registration parameters and link to the registration object	*/
		 initializer->SetTransform(transform);
		 initializer->SetFixedImage(fixedImage);
		 initializer->SetMovingImage(movingImage);
		 initializer->MomentsOn();
		 initializer->InitializeTransform();
		 registration->SetInitialTransformParameters( transform->GetParameters() );	//	initial transform

		 /*	Set some final transformation links	*/
		 typedef TOptimizer::ScalesType  OptimizerScalesType;
		 OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() ); // inital scales
		 for(int i=0; i<optimizerScales.size();i++) {
			 optimizerScales[i] = 1;
		 };
		 registration->GetOptimizer()->SetScales( optimizerScales );


		 /*=============================*
		  *	Registration initialization
		  *=============================*/

		 // Set up the pyramid schedule
		 typedef TImage::SizeType	TSize;
		 const TSize				fixedSize = fixedImage->GetLargestPossibleRegion().GetSize();
		 TImagePyramid::Pointer		fauxImagePyramid = TImagePyramid::New();
		 fauxImagePyramid->SetNumberOfLevels(opts.numberOfPyramids);
		 TImagePyramid::ScheduleType  pyramidSchedule = fauxImagePyramid->GetSchedule();
		 if( (fixedSize[0]/pyramidSchedule[0][1] < 64) & (opts.numberOfPyramids > 1) )
		 {
			 opts.numberOfPyramids = opts.numberOfPyramids-1;
			 fauxImagePyramid->SetNumberOfLevels(opts.numberOfPyramids);
			 pyramidSchedule = fauxImagePyramid->GetSchedule();
		 };
		 for(unsigned int i=0; i<opts.numberOfPyramids; i++ )
		 {
			 pyramidSchedule[i][2] = 1; // don't undersample in the z direction
		 };
		 registration->SetSchedules(pyramidSchedule,pyramidSchedule);

		 // Create the Command observer and register it with the optimizer.
		 CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();
		 optimizer->AddObserver( itk::IterationEvent(), observer );
		 observer->SetFileName( opts.historyFile );
		 
		 typedef RegistrationInterfaceCommand<TRegistration> CommandType;
		 CommandType::Pointer command = CommandType::New();
		 command->SetFileName(opts.historyFile);
		 std::cerr << "Percentage: " << opts.numberOfSamples*100 << std::endl;
		 command->SetPixelPercentage( opts.numberOfSamples );
		 registration->AddObserver( itk::IterationEvent(), command );


		 /*=====================*
		  *	Register the images
		  *=====================*/

		 // Perform the rigid registration
		 try {
			 registration->Update();
			 opts.historyOut	<< "Optimizer stop condition: "
								<< registration->GetOptimizer()->GetStopConditionDescription()
								<< std::endl;
			 std::cout	<< "Optimizer stop condition: "
						<< registration->GetOptimizer()->GetStopConditionDescription()
						<< std::endl;
		 }
		 catch( itk::ExceptionObject & err ) {
			 std::cerr	<< "ExceptionObject caught !" << std::endl;
			 std::cerr	<< err << std::endl;
			 return;
		 };


		 /*	Create a new transformation object, setting the values for the final 
		  *	transoformation, matrix, and offset (then display the output) */
		 transform->SetParameters( registration->GetLastTransformParameters() );
		 TTransform::MatrixType		finalMatrix	= transform->GetMatrix();
		 TTransform::OffsetType		offset		= transform->GetOffset();
		 std::cout << "Offset = " << std::endl << offset << std::endl;
		 std::cout << "Final matrix = " << std::endl << finalMatrix << std::endl;

	 };	/*	RegWrapper<> RegWrapper()	*/

}; /*	RegWrapper<TPixel,3,Euler>	*/


int main( int argc, char *argv[] ){

	/*	Before performing any computations, the registration options
	 *	should be generated. The MatlabRegHeader class member "isReady"
	 *	is then called to ensure that certain necessary other members
	 *	have been appropriately imported. Appropriate error messages
	 *	are printed to the command prompt, but the caller is ultimately
	 *	responsible for terminating execution	*/

	/*	Create the options object	*/
	RegOptsFilter	opts(argc, argv);
	if (!opts.isReady(argc)) {
		return	EXIT_FAILURE;
	};

	/*	At this point, it is necessary to being specializing the
	 *	instantiation of ITK data and process objects based on the
	 *	user input as reflected by the current state of the options	*/
	switch (opts.transform) {
	case Euler:
		if (opts.dimensions==2) {
			RegWrapper<double,2,Euler> RegWrapper(opts);
		}
		else if (opts.dimensions==3) {
			RegWrapper<double,3,Euler> RegWrapper(opts);
			
		};
		break;
	default:
		std::cerr << "Unknown or unsupported transformation" << std::endl;
		return EXIT_FAILURE;
	};

	return EXIT_SUCCESS;

//	/*	Determine the number of voxels in the moving image	*/
//	unsigned int numberOfVoxels = mImage->GetLargestPossibleRegion().GetNumberOfPixels();
//

//  if( regOpts.transform==1 ) {
//	  typedef itk::AffineTransform<double,3>	TransformType; //Affine 3D transformation setup
//	  TransformType::Pointer					transform = TransformType::New();
//
//	  // Register the transformation object to the registration object
//	  registration->SetTransform( transform );
//
//	  // Create a transform initializer
//	  typedef itk::CenteredTransformInitializer<TransformType,TImage,TImage> InitializerType;
//	  InitializerType::Pointer initializer = InitializerType::New();
//
//	  // Initialize the registration parameters and link to the registration object
//	  initializer->SetTransform( transform );
//	  initializer->SetFixedImage( fixedImageReader->GetOutput() );
//	  initializer->SetMovingImage( movingImageReader->GetOutput() );
//	  initializer->MomentsOn();
//	  initializer->InitializeTransform();
//	  registration->SetInitialTransformParameters( transform->GetParameters() );
//
//	  // Initialize the optimizer scales
//	  typedef TOptimizer::ScalesType  OptimizerScalesType;
//	  OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() ); // inital scales
//	  optimizer->SetScales( optimizerScales );
//	  optimizer->SetRelaxationFactor( 0.8 );
//
//  };
//
//
//  outFile << "Similarity: " << regOpts.similarity << " - "
//			<< registration->GetMetric()->GetNameOfClass() << std::endl;
// 

//
//  
//
//  //~~~~~~~~~~~~~~~~~~~~~~~~~~~ Write the registered image ~~~~~~~~~~~~~~~~~~~~~~~
//  TOptimizer::ParametersType finalParameters =
//                    registration->GetLastTransformParameters();
//
//  //Debugging code
////  for(int idx=1; idx<=5; idx++)
////  {
////	  if( idx==0 )
////		  finalParameters[idx] = 4.0*3.1416/180.0;
////	  else
////		  finalParameters[idx] = 0.0;
////  }
//
//  typedef itk::ResampleImageFilter<TImage,TImage>    ResampleFilterType;
//  
//  ResampleFilterType::Pointer resampler = ResampleFilterType::New();
//  resampler->SetInput( movingImageReader->GetOutput() );
//  TImage::Pointer fixedImage = fixedImageReader->GetOutput();
//  resampler->SetSize(    fixedImage->GetLargestPossibleRegion().GetSize() );
//  resampler->SetOutputOrigin(  fixedImage->GetOrigin() );
//  resampler->SetOutputSpacing( fixedImage->GetSpacing() );
//  resampler->SetOutputDirection( fixedImage->GetDirection() );
//  resampler->SetDefaultPixelValue( -100 );
//
//  // Get the transformation object from the registration object to display a few final items and update
//  // the resampler
//  if (regOpts.transform==0)
//  {
//	  typedef itk::Euler3DTransform< double > TransformType;
//	  typedef TransformType *                 TransformPointer;
//
//	  // Get the transformation object from the registration object and update to the final parameters
//	  TransformPointer transform = dynamic_cast< TransformPointer >( registration->GetTransform() );
//	  transform->SetParameters( finalParameters );
//
//	  
//	  
//	  // Update the resampler with the new transform
//	  resampler->SetTransform( finalTransform );
//  }
//  if (regOpts.transform==1)
//  {
//	  typedef itk::AffineTransform< double, 3 > TransformType;
//	  typedef TransformType *                   TransformPointer;
//
//	  // Get the transformation object from the registration object and update to the final parameters
//	  TransformPointer transform = dynamic_cast< TransformPointer >( registration->GetTransform() );
//	  transform->SetParameters( finalParameters );
//
//	  // Create a new transformation object, setting the values for the final transoformation, matrix,
//	  // and offset (then display the output)
//	  TransformType::Pointer    finalTransform = TransformType::New();
//	  TransformType::MatrixType finalMatrix    = transform->GetMatrix();
//	  TransformType::OffsetType offset         = transform->GetOffset();
//	  finalTransform->SetCenter( transform->GetCenter() );
//	  finalTransform->SetParameters( finalParameters );
//	  finalTransform->SetFixedParameters( transform->GetFixedParameters() );
//	  std::cout << "Offset = " << std::endl << offset << std::endl;
//	  std::cout << "Final matrix = " << std::endl << finalMatrix << std::endl;
//	  
//	  // Update the resampler with the new transform
//	  resampler->SetTransform( finalTransform );
//  }
//
};


#endif