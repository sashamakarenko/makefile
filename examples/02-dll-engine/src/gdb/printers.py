import gdb
import gdb.printing
import itertools
import re
import os

class EnginePrinter:

    def __init__(self, val):
        self.val = val

    def to_string(self):
        return '%s %f Hp' % ( self.val['_manufacturer']['_M_dataplus']['_M_p'], self.val['_maxPower'] )

    def display_hint(self):
        return 'string'


def build_engine_printers():
    pp = gdb.printing.RegexpCollectionPrettyPrinter( "engine-1.0" )
    pp.add_printer( 'engine::Engine', '^engine::Engine$', EnginePrinter )
    return pp

gdb.printing.register_pretty_printer( gdb.current_objfile(), build_engine_printers() )
