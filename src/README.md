# Overview
## CSE379 - Lab 7
### Nathan Fox and Sebastien Bowen 

This is the website that will hold the documentation for Nathan Fox's and Sebastien Bowen's implementation of Atari Video Cube for the Atari 2600.  This is Lab 7 of CSE-379.

In this documentation, various examples of code will be done in Python.  The associated git repository will contain a large number of Python files.  This is because we will be sketching out ideas and algorithms in Python before implementing in ARM assembly, due to the ease of testing.

The project will also be stored in multiple files.  datastructures.s will be used to contain all the subroutines and macros for the main file, rng.s will contain the psuedo-random number generation, and library.s will contain all the small, generic and helpful subroutines that were created throughout the semester.  All of the .s files will be important for the project to work.