// main.cpp
#include "systemc.h"    //< Notice not systemc.h
#include"head1.h"
#include"head2.h"

int sc_main(int argc, char* argv[])
{

  sc_core::sc_fifo<int> fifo(10); //< sc_core namespace specifier

  writer w("writer");
  reader r("reader");
  w.out(fifo);
  r.in(fifo);

  sc_start(1, sc_core::SC_NS); //< Run simulation for a limited time since no stopping condition are provided upfront. Also time is also specified in sc_core namespace.
  sc_start(-1);
  return 0;

}