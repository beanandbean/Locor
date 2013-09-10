from PIL import Image

src = Image.open('bg1.png')
dest = Image.new('RGBA', src.size, 'black')
pixels = dest.load()

for i in xrange(0, src.size[0]):
    for j in xrange(0, src.size[1]):
        color = src.getpixel((i, j))
        pixels[i, j] = (0, 0, 0, 256 - color[0])

dest.save('bg1_alpha.png')
dest.show()
