#!/usr/bin/env ruby

obj = Object.new

def obj.new_method
  "do some things"
end

puts obj.new_method
# > "do some things"
