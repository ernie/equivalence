require 'spec_helper'

describe Equivalence do

  it 'requires at least one attribute as an argument' do
    expect {
      klass = Class.new do
        extend Equivalence
        equivalence
      end
    }.to raise_error ArgumentError
  end

  it 'accepts method names as arguments' do
    klass = Class.new do
      extend Equivalence
      attr_accessor :var1, :var2
      equivalence :var1, :var2
    end
    k1 = klass.new
    k1.var1 = 1
    k1.var2 = 2
    k2 = klass.new
    k2.var1 = 1
    k2.var2 = 2
    [k1, k2].uniq.should have(1).item
  end

  it 'accepts instance variable names as arguments' do
    klass = Class.new do
      extend Equivalence
      attr_accessor :var1, :var2
      equivalence :var1, :var2
    end
    k1 = klass.new
    k1.var1 = 1
    k1.var2 = 2
    k2 = klass.new
    k2.var1 = 1
    k2.var2 = 2
    [k1, k2].uniq.should have(1).item
  end

  it 'creates a valid hash method if a keyword is used' do
    klass = Class.new do
      extend Equivalence
      attr_accessor :alias
      equivalence :alias
    end
    k1 = klass.new
    k1.alias = 'bob'
    k2 = klass.new
    k2.alias = 'bob'
    [k1, k2].uniq.should have(1).item
  end

  it 'defines protected attribute readers if not already defined' do
    klass = Class.new do
      extend Equivalence
      equivalence :@var
      def initialize(var)
        @var = var
      end
    end
    klass.protected_method_defined?(:var).should be_true
  end

  it 'does not alter access of already-accessible methods' do
    klass = Class.new do
      extend Equivalence
      attr_reader :var
      equivalence :@var
      def initialize(var)
        @var = var
      end
    end
    klass.public_method_defined?(:var).should be_true
    klass.protected_method_defined?(:var).should be_false
  end

  it 'does not overwrite a private reader method, but makes it protected' do
    # Not that it's likely that you're going to call equivalence in the order
    # shown here. Still, better safe than sorry. What you do *after* you call
    # equivalence is your problem, but we don't want to "unexpectedly" overwrite
    # anything.
    klass = Class.new do
      extend Equivalence
      def initialize(var)
        @var = var
      end
      private
      def var
        'zomg'
      end
      equivalence :@var
    end
    klass.protected_method_defined?(:var).should be_true
    klass.private_method_defined?(:var).should be_false
    klass.new(1).send(:var).should eq 'zomg'
  end

end

