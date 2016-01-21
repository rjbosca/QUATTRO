#ifndef REGCOMMANDSPECIALIZATIONS_H
#define REGCOMMANDSPECIALIZATIONS_H


template <typename TRegistration,unsigned int VImageDimension>
class RegistrationInterfaceCommand : public itk::Command {

public:
	typedef	RegistrationInterfaceCommand	Self;
	typedef	itk::Command					Superclass;
	typedef	itk::SmartPointer<Self>			Pointer;
	itkNewMacro(Self);

protected:
	RegistrationInterfaceCommand() {};

public:
	typedef	TRegistration	T
#endif