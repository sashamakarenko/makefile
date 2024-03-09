#include <engine/Engine.h>
#include <utests/TrivialHelper.h>

int main(int argc, char const *argv[])
{
    engine::Engine e( "Peugeot", 130 );
    std::cout << "Engine manufacturer: " << e.getManufacturer() << " max power: " << e.getMaxPower() << std::endl;
    CHECK( max power > 100, e.getMaxPower(), >100 )
    CHECK( max power > 200, e.getMaxPower(), >200 )
    CHECK( max power > 300, e.getMaxPower(), >300 )
    return 0;
}
