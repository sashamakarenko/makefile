#include <engine/Engine.h>
#include <engine/PrjInfo.h>
#include <specs/Types.h>

namespace engine
{

Engine::Engine( const std::string & manufacturer, double maxPower )
: _manufacturer( manufacturer )
, _maxPower( maxPower )
, _battery()
{
}

Engine::~Engine()
{
}

}
