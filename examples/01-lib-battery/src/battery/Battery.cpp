#include <battery/Battery.h>

namespace battery
{

Battery::Battery( double voltage )
: _voltage( voltage )
, _charge( 100 )
{
}

Battery::~Battery()
{
}

}
