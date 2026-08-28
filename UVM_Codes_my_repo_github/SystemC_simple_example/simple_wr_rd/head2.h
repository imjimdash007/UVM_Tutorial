//head2.h
// Refer the head1.h for similar details
#ifndef HEAD2_H_
#define HEAD2_H_


#include<systemc>

SC_MODULE(writer)
{
  // Refer the head1.h for similar details
  sc_core::sc_fifo_out<int> out;

  void woperation()
  {

    int val = 0;
    while (true)
    {
      wait(10, sc_core::SC_NS);
      for (int i = 0; i <= 20; i++)
      {
        out.write(val++);

      }
    }

  }

  SC_CTOR(writer)
  {
    SC_THREAD(woperation);

  }
};
#endif // HEAD2_H_