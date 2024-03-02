#include <car/Car.h>

namespace car
{

Car::Car( const std::string & model )
: _model( model )
, _engine()
, _computer()
{
}

Car::~Car()
{
}

}
