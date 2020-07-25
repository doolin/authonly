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
