require "equivalence/version"

module Equivalence

  private

  def equivalence(*args)
    raise ArgumentError, 'At least one attribute is required.' if args.empty?
    args.map!(&:to_s)
    method_names = args.map { |arg| arg.sub /^@/, '' }

    __define_equivalence_hash_method(args)
    __define_equivalence_attribute_readers(method_names)
    __define_equivalence_equality_methods(method_names)
  end

  def __define_equivalence_hash_method(ivar_or_method_names)
    # Method names might be keywords. We'll want to prefix them with "self"
    ivar_or_method_names = ivar_or_method_names.map do |name|
      name.start_with?('@') ? name : "self.#{name}"
    end

    class_eval <<-EVAL, __FILE__, __LINE__
      def hash
        [#{ivar_or_method_names.join(', ')}].hash
      end
    EVAL
  end

  def __define_equivalence_attribute_readers(method_names)
    method_names.each do |method|
      unless method_defined?(method)
        class_eval <<-EVAL, __FILE__, __LINE__
          attr_reader :#{method} unless private_method_defined?(:#{method})
          protected   :#{method}
        EVAL
      end
    end
  end

  def __define_equivalence_equality_methods(method_names)
    class_eval <<-EVAL, __FILE__, __LINE__
      def eql?(other)
        self.class == other.class &&
          #{method_names.map {|m| "self.#{m} == other.#{m}"}.join(" &&\n")}
      end
      alias :== :eql?
    EVAL
  end

end
