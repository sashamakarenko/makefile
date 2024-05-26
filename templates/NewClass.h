#pragma once
#ifndef DECLARE_NAMESPACE_CLASS
#define DECLARE_NAMESPACE_CLASS

namespace NAMESPACE
{

class CLASS
{
    public:

        CLASS();

        CLASS( const CLASS & ) = delete;

        virtual ~CLASS();

    protected:

    private:

};

} // namespace NAMESPACE

#endif // DECLARE_NAMESPACE_CLASS
