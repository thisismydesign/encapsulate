# Encapsulate

#### A small Ruby framework that enables encapsulating pieces of code within eachother.

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/encapsulate.svg?branch=release)](https://travis-ci.org/thisismydesign/encapsulate)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/encapsulate/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/encapsulate?branch=release)   [![Gem Version](https://badge.fury.io/rb/encapsulate.svg)](https://badge.fury.io/rb/encapsulate)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/encapsulate?type=total)](https://rubygems.org/gems/encapsulate) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/encapsulate.svg?branch=master)](https://travis-ci.org/thisismydesign/encapsulate)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/encapsulate/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/encapsulate?branch=master) |

## What is this?

Ever get tired of writing exception handling blocks? Ever think it's not really DRY (`Don't Repeat Yourself`)?

With Ruby instead of...

```ruby
begin
  read_file
rescue IOError => e
  handle_io_error
ensure
  close_io
end
```

... you can do

```ruby
def handle_io_error
  begin
    yield
  rescue IOError => e
    handle_io_error
  ensure
    close_io
  end
end

handle_io_error do
  read_file
end
```

... and with `Encapsulate` you can do

```ruby
run callback: read_file, with: io_error_handling
```

Not to mention code duplications that are otherwise difficult to get rid of...

```ruby
signal_processing_start
start_time_measurement

process

stop_time_measurement
signal_processing_end
```

How about...

```ruby
lifecycle_signals do
  time_measurement do
    read_file
  end
end
```

... or with `Encapsulate`

```ruby
run callback: process, with: [time_measurement, lifecycle_signals]
```

`Encapsulate` provides an alternaive solution utilizing a function-like syntax instead of nesting.

## How does it work?

We essentially want to create the following structure:
```ruby
encapsulator1
  # ...
  encapsulator2
    # ...
      base_function
        # ...
      end
    # ...
  end
  # ...
end
```

In order to achieve this each encapsulator function must know the next one in the chain (the last one being the base function). Also the parameters of the base function must be carried by the encapsulators. Our pseudocode should look something like this:

```ruby
def encapsulator1(callback:, params: nil)
  # some logic...
  def encapsulator2(callback:, params: nil)
    # some logic...
      base_function(params)
    # some logic...
  end
  # some logic...
end
```

## How to use it?

The [encapsulators](https://github.com/thisismydesign/encapsulators) gem contains a collection of practical functions to be used with Encapsulate. You may check if your use case is already implemented. If not then please consider contributing it.

Below you will find some insight on how to create and structure your call chains but you can also head right to the [unit tests](https://github.com/thisismydesign/encapsulate/blob/master/spec/encapsulate_spec.rb) for hands-on examples.

### Building the chain

```ruby
require 'encapsulate'
```


```ruby
# Single encapsulator
Encapsulate.run callback: base_function, with: [encapsulator]

# Multiple encapsulators
# They will apply in the given order: encapsulator2(encapsulator1(callback))
Encapsulate.run callback: base_function, with: [encapsulator1, encapsulator2]

# Parameters
Encapsulate.run callback: base_function, with: [encapsulator1, encapsulator2], params: {arg: 'something'}
```

### Base function

To sidestep the issue of varying number of parameters we must use [keyword arguments or a single Hash parameter](https://robots.thoughtbot.com/ruby-2-keyword-arguments) in the base function.

```ruby
def self.base_function(my_param:, my_other_param:)
  # ...
end

base_function = self.method(:base_function)
```

### Encapsulators

Encapsulators should be implemented (for reasons detailed in the previous chapter) along the lines of:

```ruby
def self.my_encapsulator(callback:, params: nil)
  # ...
  params.nil? ? callback.call : callback.call(params)
  # ...
end

my_encapsulator = self.method(:my_encapsulator)
```

The base function may take no parameters which is why `params` in our interface must default to nil and we also need to take care of calling the `callback` accordingly. This small piece of logic is implemented in the gem [reflection_utils](https://github.com/thisismydesign/reflection_utils) (as seen below) alongside with other useful reflection related functions.

You may use any objects that respond to `call`. The only difference will be in how you reference these objects.
These are also valid skeletons:

```ruby
my_encapsulator = lambda do |callback:, params: nil|
  # ...
  ReflectionUtils.call(callback, params)
  # ...
end
```

```ruby
my_encapsulator = Proc.new do |callback:, params: nil|
  # ...
  ReflectionUtils.call(callback, params)
  # ...
end
```

Encapsulators will ideally not use any parameters. They do take the base function's parameter hash as second parameter and you could *technically* hide additional parameters there but it's not a good practice. Instead:
- try to keep encapsulators simple
- use their own classes to configure them

This brings us to how to structure encapsulators. You have several options.

#### 1 class per encapsulator

```ruby
class ExceptionEncapsulator
  def self.callback(callback:, params: nil)
    # ...
  end
end
```

#### Collcetor class

```ruby
class Encapsulators
  def self.exception_handling(callback:, params: nil)
    # ...
  end
  
  def self.time_measurement(callback:, params: nil)
    # ...
  end
  
  # ...
end
```

#### In place

```ruby
my_encapsulator = lambda do |callback:, params: nil|
  # ...
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encapsulate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encapsulate

## Feedback

Any feedback is much appreciated.

I can only tailor this project to fit use-cases I know about - which are usually my own ones. If you find that this might be the right direction to solve your problem too but you find that it's suboptimal or lacks features don't hesitate to contact me.

Please let me know if you make use of this project so that I can prioritize further efforts.

## Development

This gem is developed using Bundler conventions. A good overview can be found [here](http://bundler.io/v1.14/guides/creating_gem.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thisismydesign/encapsulate.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
