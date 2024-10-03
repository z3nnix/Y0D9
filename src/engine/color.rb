def random_color
  "#" + 3.times.map { rand(128..255).to_s(16).rjust(2, '0') }.join
end