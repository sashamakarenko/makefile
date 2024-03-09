#ifndef DECLARE_specs_Types
#define DECLARE_specs_Types

namespace specs
{

enum class State: int
{
    NEW,
    TESTING,
    STAGING,
    PROD,
    DECOM
};

} // namespace specs

#endif // DECLARE_specs_Types
