#pragma once
#ifndef DECLARE_computer_Computer
#define DECLARE_computer_Computer

#include <battery/Battery.h>

namespace computer
{

class Computer
{
    public:

        using Ptr = std::shared_ptr<Computer>;

        Computer();

        Computer( const Computer & ) = delete;

        virtual ~Computer();

        void setBattery( battery::Battery::Ptr & battery )
        {
            _battery = battery;
        }

    private:
    
        battery::Battery::Ptr _battery;
};

} // namespace computer

#endif // DECLARE_computer_Computer
