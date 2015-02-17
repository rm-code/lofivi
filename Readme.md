#LoFiVi

LoFiVi uses a force-directed graph to visualise folder structures. 

Like its big sister [LoGiVi](https://bitbucket.org/rmcode/logivi), LoFiVi was inspired by other visualisation software like [Gource](https://code.google.com/p/gource/) or [Cytoscape](http://www.cytoscape.org/). I always was quite intrigued by the beautiful graphs they created and therefore wanted to learn how to make use of [force-directed graphs](http://en.wikipedia.org/wiki/Force-directed_graph_drawing) myself.

LoFiVi mainly started as a test bed for LoGiVi. I wanted to be able to play around with the creation of a graph and the physical forces needed to create a decent layout. Since the creation of a graph in LoFiVi is far more simple than in LoGiVi, I can use it to find the best way to represent that graph in code, while making it easy (and efficient) to apply forces and update it. 

### Instructions

LÖVE currently can only read files from LoFiVi's save directory ([according to](https://bitbucket.org/rude/love/issue/985/add-an-open-file-popup-dialog-function#comment-15482823) one of the developers this will be changed in Version 0.10.0 though).

Find the save directory of LÖVE on your system (see the [LÖVE wiki](https://www.love2d.org/wiki/love.filesystem) for more information). Create a folder called ___rmcode_LoFiVi___ and inside of that folder create another folder called ___root___. 

Place the folder structure you want to visualise into the root folder and run LoFiVi.


### License
Copyright (C) 2015 by Robert Machmer                                                       
                                                                                           
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                   
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                     
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,              
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                  
THE SOFTWARE.