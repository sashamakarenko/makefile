#include <engine/Engine.h>
#include <iostream>

int main(int argc, char const *argv[])
{
    engine::Engine e( "Peugeot", 130 );
    std::cout << "Engine manufacturer: " << e.getManufacturer() << " max power: " << e.getMaxPower() << std::endl;
    return 0;
}
