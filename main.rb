
f = File.open('google-10000-english-no-swears.txt')

words = []

while line = f.gets do
  line = line.chomp
  if line.length in (5..12)
    words.push(line)
  end
end

secret = words.sample