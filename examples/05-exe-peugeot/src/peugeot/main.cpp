#include <car/Car.h>
#include <iostream>

int main(int argc, char const *argv[])
{
    car::Car peugeot207( "207" );
    battery::Battery::Ptr b12 = std::make_shared<battery::Battery>( 12 );
    engine::Engine::Ptr motor = std::make_shared<engine::Engine>( "peugeot", 130 );
    motor->setBattery( b12 );
    peugeot207.setEngine( motor );
    computer::Computer::Ptr satnav = std::make_shared<computer::Computer>();
    satnav->setBattery( b12 );
    peugeot207.setComputer( satnav );
    std::cout << "207 is out" << std::endl;
    return 0;
}
