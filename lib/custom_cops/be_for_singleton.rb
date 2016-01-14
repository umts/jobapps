require 'pry-byebug'

module RuboCop
  module Cop
    module CustomCops
      class BeForSingleton < Cop
        MSG = 'Prefer `be` matcher to `eq` or `eql` for singleton types.'

        OFFENSE_TYPE_CHECKS = %i(true_type?
                                 false_type?
                                 nil_type?
                                 int_type?
                                 float_type?)

        def on_send(node)
          return unless node.method_name == :to
          return unless node.child_nodes.first.method_name == :expect

          matcher = node.child_nodes[1]
          return unless %i(eq eql).include? matcher.method_name

          args = matcher.child_nodes.first
          if OFFENSE_TYPE_CHECKS.map { |check| args.send check }.any?
            add_offense node, :expression, MSG
          end
        end
      end
    end
  end
end
