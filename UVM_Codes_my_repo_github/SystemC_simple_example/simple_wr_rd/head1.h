//head1.h
// Notice the HEADER GUARD
#ifndef HEAD1_H_
#define HEAD1_H_

// Changed the header file to systemc instead of systemc.h
#include<systemc>

SC_MODULE(reader) {
  // sc_fifo_in_if is a abstract class from which you cannot create an object.
  // sc_fifo_in is derived from the above class which actually implements the read method.
  sc_core::sc_fifo_in<int> in; 

  void roperation()
  {

    int val;

    while (true)
    {
      wait(10, sc_core::SC_NS); // Time unit is defined in sc_core namespace.
      for (int i = 0; i <= 15; i++)
      {

        in.read(val);

        std::cout << val << std::endl; //< when using the systemc header you need to specify the std namespace.
        // Or you can use the statement after including all the header files:
        // using namespace std

      }
    }

    std::cout << "Availaible : " << in.num_available() << std::endl; //< Instead of num available it is num_available
    //< when using the systemc header you need to specify the std namespace.
    // Or you can use the statement after including all the header files:
    // using namespace std

  }

  SC_CTOR(reader) //< Your code mentions here writer the constructor name should be same as the class name.
  {
    SC_THREAD(roperation); //< Your code mentions woperation

  }

};

#endif // HEAD1_H_