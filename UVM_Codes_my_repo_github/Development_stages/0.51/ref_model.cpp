#include <iostream>

extern "C" {
    // C++ function that mimics the sequential logic of the hardware counter
    int c_counter_predict(int rst, int load, int count_in, int current_count) {
        int next_count = 0;
        
        if (rst) {
            next_count = 0;
        } else if (load) {
            next_count = count_in & 0xF; // Mask to 4-bits
        } else {
            next_count = (current_count + 1) & 0xF; // Increment 4-bits
        }
        
        return next_count;
    }
}

