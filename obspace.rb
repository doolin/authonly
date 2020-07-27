#!/usr/bin/env ruby

# This file is notes from Aaron Patterson's talk
# Don't @ me about Ruby instance variables:
# https://www.youtube.com/watch?v=HEFBDqly4ms
require 'objspace'

class Foo
  def initialize
    @foo = :bar
    @bar = :baz
  end
end

class Bar
  def initialize
    @foo = :bar
    @bar = :baz
    @baz = :quux
  end
end

p BEFORE: ObjectSpace.memsize_of(Foo)
Foo.new
p AFTER: ObjectSpace.memsize_of(Foo)

p BEFORE: ObjectSpace.memsize_of(Bar)
Bar.new
p AFTER: ObjectSpace.memsize_of(Bar)
