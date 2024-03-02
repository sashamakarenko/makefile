
#ifndef DECLARE_battery_Battery
#define DECLARE_battery_Battery

#include <memory>

namespace battery
{

class Battery
{
    public:

        using Ptr = std::shared_ptr<Battery>;

        Battery( double voltage );

        Battery( const Battery & ) = delete;

        virtual ~Battery();

        double getVoltage() const
        {
            return _voltage;
        }

        double getCharge() const
        {
            return _charge;
        }

    private:

        double _voltage;
        double _charge;
};

} // namespace battery

#endif // DECLARE_battery_Battery
