# Encapsulate

#### A small Ruby framework that enables encapsulating pieces of code within eachother.

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/encapsulate.svg?branch=release)](https://travis-ci.org/thisismydesign/encapsulate)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/encapsulate/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/encapsulate?branch=release)   [![Gem Version](https://badge.fury.io/rb/encapsulate.svg)](https://badge.fury.io/rb/encapsulate)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/encapsulate?type=total)](https://rubygems.org/gems/encapsulate) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/encapsulate.svg?branch=master)](https://travis-ci.org/thisismydesign/encapsulate)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/encapsulate/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/encapsulate?branch=master) |

## What is this?

Ever get tired of writing exception handling blocks? Ever think it's not really DRY (Don't Repeat Yourself)?

Wouldn't it be better instead of...

```ruby
begin
  read_file
rescue IOError => e
  handle_io_error
ensure
  close_io
end
```

... to just write

```ruby
run callback: read_file, with: io_error_handling
```

Not to mention code duplications you just can't get rid of

```ruby
signal_processing_start
start_time_measurement

process

stop_time_measurement
signal_processing_end
```

How about

```ruby
run callback: process, with: [time_measurement, lifecycle_signals]
```

Encapsulate enables you to do just that.

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

In order to achieve this each encapsulator function must know the next one in the chain (the last one being the base function). Also the parameters of the base function must be carried by the encapsulators. Our pseudocode should something like this:

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

### Base function

To sidestep the issue of varying number of parameters we must use [keyword arguments or a single Hash parameter](https://robots.thoughtbot.com/ruby-2-keyword-arguments) in the base function.

```ruby
def my_func(my_param:, my_other_param:)
  # ...
end
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

You may use any object that responds to `call`. The only difference will be in how you reference these objects.
These are also a valid skeletons:

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

Encapsulators will ideally not use any parameters. They do take the base function's parameter hash as second parameter and you could technically *hide* additinal parameters there but it's not a good practice. Instead:
- try to keep encapsulators simple
- use their own classes to configurate them

This brings us to how to structure encapsulators.

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/encapsulate.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
