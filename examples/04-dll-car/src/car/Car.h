#ifndef DECLARE_car_Car
#define DECLARE_car_Car

#include <engine/Engine.h>
#include <computer/Computer.h>

namespace car
{

class Car
{
    public:

        using Ptr = std::shared_ptr<Car>;

        Car( const std::string & model );

        Car( const Car & ) = delete;

        virtual ~Car();

        void setEngine( engine::Engine::Ptr & e )
        {
            _engine = e;
        }

        void setComputer( computer::Computer::Ptr & comp )
        {
            _computer = comp;
        }

    protected:

        const std::string       _model;
        engine::Engine::Ptr     _engine;
        computer::Computer::Ptr _computer;
};

} // namespace car

#endif // DECLARE_car_Car
