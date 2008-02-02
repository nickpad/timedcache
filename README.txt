= timedcache

* http://timedcache.rubyforge.org

== DESCRIPTION:

TimedCache implements a cache in which you can place objects
and specify a timeout value.

If you attempt to retrieve the object within the specified timeout
period, the object will be returned. If the timeout period has elapsed,
the TimedCache will return nil.

== FEATURES/PROBLEMS:

* Memory or file-based data stores available.
* Thread safety.

== SYNOPSIS:

  cache = TimedCache.new
  cache.put :my_object_key, "Expensive data", 10 #=> "Expensive data"
  
  cache.get :my_object_key #=> "Expensive data"
  cache[:my_object_key]    #=> "Expensive data"
  
  ... 10 seconds later:
  cache.get :my_object_key #=> nil

== INSTALL:

  sudo gem timedcache

== LICENSE:

(The MIT License)

Copyright (c) 2008 Nicholas Dainty

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
