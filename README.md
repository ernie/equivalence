# Equivalence

Because implementing object equality wasn't easy enough already.

Do your objects recognize their equals? If you have complete control over how
your objects are used, maybe you don't care. If you're writing code for others
to reuse, though, your code might be leaving your users perplexed.

Consider the following situation:

    class Awesomeness
      def initialize(level, description)
        @level = level
        @description = description
      end
    
      def declare_awesomeness
        puts "My awesomeness level is #{@level} (#{@description})!"
      end
    end

    awesome1 = Awesomeness.new(10, 'really awesome')
    awesome2 = Awesomeness.new(10, 'really awesome')
    awesome1.declare_awesomeness
    # => "My awesomeness level is 10 (really awesome)!"
    awesome2.declare_awesomeness
    # => "My awesomeness level is 10 (really awesome)!"
    [awesome1, awesome2].uniq.size # => 2
    awesome1 == awesome2           # => false

Surprised? You shouldn't be. Ruby's default implementation of object equality
considers objects equal only if they are the same object, *not* if they have the
same contents.

This probably isn't what you want for your Awesomeness class. To get equality
behaving as you'd expect, you need to do the following:

    class Awesomeness
      attr_reader :level, :description

      def hash
        [@level, @description].hash
      end

      def eql?(other)
        self.class == other.class &&
          self.level == other.level &&
          self.description == other.description
      end
      alias :== :eql?
    end

Implementing the `==` method gets your comparison to return true, as expected,
and implementing `hash` and `eql?` gets `Array#uniq` to behave as expected, and
also lets you use your values as Hash keys in a way that works properly with
`Hash#[]`, `Hash#[]=`, `Hash#merge` and the like.

Have more instance variables? You'll need to add them to the `hash` and `eql?`
methods. Have other custom objects as instance variables? They'll need to
implement these methods, too.

It can get to feel a lot like busy work, and let's face it, if we liked doing
busy work, we'd be using Java.

## Installation

Add this line to your application's Gemfile:

    gem 'equivalence'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install equivalence

## Usage

### Basic

    class MySpiffyClass
      extend Equivalence
      equivalence :@my, :@instance, :@variables # , [...]
      # Your spiffy class implementation
    end

You'll get the equality methods we "painstakingly" added above, without all that
pesky typing. If you don't implement reader methods (as above), Equivalence will
create some for you, with `protected` access (meaning only other objects within
MySpiffyClass's class hierarchy will be able to call them), since they're
necessary for the `eql?` method to work). Defining your own readers? No problem,
Equivalence won't mess with them.

Let's re-visit the example from above.

    class Awesomeness
      extend Equivalence
      equivalence :@level, :@description

      def initialize(level, description)
        @level = level
        @description = description
      end
    
      def declare_awesomeness
        puts "My awesomeness level is #{@level} (#{@description})!"
      end
    end

    awesome1 = Awesomeness.new(10, 'really awesome')
    awesome2 = Awesomeness.new(10, 'really awesome')
    [awesome1, awesome2].uniq.size # => 1
    awesome1 == awesome2           # => true

Less hassle, same result.

### "Advanced" (if there is such a thing, for such a simple library)

Maybe your attribute readers aren't named the same as your instance variables,
because you like to confuse people. Or maybe, your readers are lazy-loading
certain instance variables or doing some casting of Fixnums to Strings. In that
case, you'll want your `hash` method to be defined with calls to the methods
instead of accessing the ivars directly, to get the expected results. Just omit
the leading @ in each parameter, like so:

    equivalence :level, :description

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
