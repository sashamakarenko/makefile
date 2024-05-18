#ifdef DECLARE_utests_TrivialHelper_h
#error could not include TrivialHelper.h twice
#endif

#define DECLARE_utests_TrivialHelper_h

#include <iostream>
#include <iomanip>
#include <mutex>
#include <thread>
#include <chrono>
#include <array>

using namespace std::literals::string_literals;

inline void sleep_millis( unsigned millis )
{
    std::this_thread::sleep_for( std::chrono::milliseconds( millis ) );
}

#ifdef EXIT_ON_ERROR
#define CHECK_EXIT  if( not check_isGood_ ) { sleep_millis( 100 ); exit(1); }
#else
#define CHECK_EXIT
#endif


std::mutex utestsLogMutex;

struct LogGuard
{
    LogGuard(): lock( utestsLogMutex )
    {
    }
    std::unique_lock<std::mutex> lock;
};

constexpr const char * const TTY_RESET = "\e[0m";

#define CHECK_PREFIXED( PREFIX, TITLE, EXPR, CONDITION ) {\
    try { \
        const auto & check_res_ = EXPR;\
        bool check_isGood_ = check_res_ CONDITION;\
        {\
            LogGuard g__;\
            if( not check_isGood_ )\
                std::cerr << "\e[33;1m" << __FILE__ << ":" << __LINE__ << TTY_RESET << ": \e[1m" << #TITLE << " : " << "\e[35m<\e[31;1m" << std::boolalpha << check_res_ << "\e[35m>" << TTY_RESET << std::endl;\
            else \
                std::cout << PREFIX << std::setw(4) << __LINE__ << ": \e[1m" << #TITLE << " : " << "\e[34m<\e[32;1m" << std::boolalpha << check_res_ << "\e[34m>" << TTY_RESET << std::endl;\
        }\
        CHECK_EXIT\
    } catch( const std::exception & ex ){\
        LogGuard g__;\
        std::cerr << "\e[33;1m" << __FILE__ << ":" << __LINE__ << " \e[96;1m exception" << TTY_RESET << ": \e[1m" << #TITLE << " : \e[35m<\e[31;1m" << ex.what() << "\e[35m>" << TTY_RESET << std::endl;\
        throw;\
    }\
}

#define CHECK_COMP_PREFIXED( PREFIX, TITLE, OP, EXPR, EXPECTED ) {\
    try { \
        const auto & check_res_ = EXPR;\
        bool check_isGood_ = check_res_ OP EXPECTED;\
        {\
            LogGuard g__;\
            if( not check_isGood_ )\
                std::cerr << "\e[33;1m" << __FILE__ << ":" << __LINE__ << TTY_RESET << ": \e[1m" << #TITLE << " : " << "\e[35m<\e[31;1m" << std::boolalpha << check_res_ << "\e[35m>" << TTY_RESET << " expected <" << EXPECTED << ">" << std::endl;\
            else \
                std::cout << PREFIX << std::setw(4) << __LINE__ << ": \e[1m" << #TITLE << " : " << "\e[34m<\e[32;1m" << std::boolalpha << check_res_ << "\e[34m>" << TTY_RESET << std::endl;\
        }\
        CHECK_EXIT\
    } catch( const std::exception & ex ){\
        LogGuard g__;\
        std::cerr << "\e[33;1m" << __FILE__ << ":" << __LINE__ << " \e[96;1m exception" << TTY_RESET << ": \e[1m" << #TITLE << " : \e[35m<\e[31;1m" << ex.what() << "\e[35m>" << TTY_RESET << std::endl;\
        throw;\
    }\
}

#define HIGHLIGHT_FG( FG, TITLE )\
{\
    LogGuard g__;\
    std::cout << "\n" FG " --- " << #TITLE << " ---" << TTY_RESET << std::endl;\
}

#define HIGHLIGHT_RED(     TITLE ) HIGHLIGHT_FG( "\e[91;1m", TITLE )
#define HIGHLIGHT_GREEN(   TITLE ) HIGHLIGHT_FG( "\e[92;1m", TITLE )
#define HIGHLIGHT_YELLOW(  TITLE ) HIGHLIGHT_FG( "\e[93;1m", TITLE )
#define HIGHLIGHT_BLUE(    TITLE ) HIGHLIGHT_FG( "\e[94;1m", TITLE )
#define HIGHLIGHT_MAGENTA( TITLE ) HIGHLIGHT_FG( "\e[95;1m", TITLE )
#define HIGHLIGHT_CYAN(    TITLE ) HIGHLIGHT_FG( "\e[96;1m", TITLE )
#define HIGHLIGHT_WHITE(   TITLE ) HIGHLIGHT_FG( "\e[97;1m", TITLE )
#define HIGHLIGHT(         TITLE ) HIGHLIGHT_YELLOW( TITLE )

// red, yellow and green are reserved for error, warning and success
constexpr std::array< const char * const, 4 > TTY_FGS =
{
    "\e[94m",
    "\e[95m",
    "\e[96m",
    "\e[97m"
};

#define CHECK(                TITLE, EXPR, CONDITION )  CHECK_PREFIXED(         "", TITLE, EXPR, CONDITION )
#define CHECK_BLUE(           TITLE, EXPR, CONDITION )  CHECK_PREFIXED( TTY_FGS[0], TITLE, EXPR, CONDITION )
#define CHECK_MAGENTA(        TITLE, EXPR, CONDITION )  CHECK_PREFIXED( TTY_FGS[1], TITLE, EXPR, CONDITION )
#define CHECK_CYAN(           TITLE, EXPR, CONDITION )  CHECK_PREFIXED( TTY_FGS[2], TITLE, EXPR, CONDITION )
#define CHECK_WHITE(          TITLE, EXPR, CONDITION )  CHECK_PREFIXED( TTY_FGS[3], TITLE, EXPR, CONDITION )

#define CHECK_EQ(             TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED(         "", TITLE, ==, EXPR, EXPECTED )
#define CHECK_EQ_BLUE(        TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[0], TITLE, ==, EXPR, EXPECTED )
#define CHECK_EQ_MAGENTA(     TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[1], TITLE, ==, EXPR, EXPECTED )
#define CHECK_EQ_CYAN(        TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[2], TITLE, ==, EXPR, EXPECTED )
#define CHECK_EQ_WHITE(       TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[3], TITLE, ==, EXPR, EXPECTED )

#define CHECK_NOT_EQ(         TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED(         "", TITLE, !=, EXPR, EXPECTED )
#define CHECK_NOT_EQ_BLUE(    TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[0], TITLE, !=, EXPR, EXPECTED )
#define CHECK_NOT_EQ_MAGENTA( TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[1], TITLE, !=, EXPR, EXPECTED )
#define CHECK_NOT_EQ_CYAN(    TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[2], TITLE, !=, EXPR, EXPECTED )
#define CHECK_NOT_EQ_WHITE(   TITLE, EXPR, EXPECTED )   CHECK_COMP_PREFIXED( TTY_FGS[3], TITLE, !=, EXPR, EXPECTED )

#define STRINGIFY_(X) #X
#define STRINGIFY(X) STRINGIFY_(X)
