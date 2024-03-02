#ifndef DECLARE_engine_Engine
#define DECLARE_engine_Engine

#include <string>
#include <battery/Battery.h>

namespace engine
{

class Engine
{
    public:

        using Ptr = std::shared_ptr<Engine>;

        Engine( const std::string & manufacturer, double maxPower );

        Engine( const Engine & ) = delete;

        virtual ~Engine();

        const std::string & getManufacturer() const
        {
            return _manufacturer;
        }

        double getMaxPower() const
        {
            return _maxPower;
        }

        void setBattery( battery::Battery::Ptr & battery )
        {
            _battery = battery;
        }

    private:

        const std::string      _manufacturer;
        const double           _maxPower;
        battery::Battery::Ptr  _battery;
};

} // namespace engine

#endif // DECLARE_engine_Engine
