#!/bin/bash
# Example usage: passport_photo.sh photo.jpg

# Specify the output format.
ppi=300
print_width=6
print_height=4
num_photo=2 # Number of photos to be embedded in one print.
format='jpg'

printf "This script requires 'convert' and 'composite' functions from ImageMagick. \n"

# Make sure the file with the given filename exists.
if [ -z $1 ]; then
	echo "The name of image file was not supplied."
	exit 0
elif ! [ -f $1 ]; then
    echo "The file $1 could not be found."
    exit 0
fi
photo_name=$1

# Ask for the desired size of the photo
echo "The photo will be automatically resized, but the photo must already be cropped to the right ratio."
printf "Enter the required size for the passport in mm as 'width'x'height' (e.g. 35x45): "
read photo_size
photo_size=(${photo_size/x/' '})
photo_width=${photo_size[0]}
photo_height=${photo_size[1]}
echo $photo_width $photo_height

# Change the lengths to pixels
photo_width=$(bc -l <<< "scale=3; $photo_width / 25.4")
photo_height=$(bc -l <<< "scale=3; $photo_height / 25.4")
photo_width=$(printf %.0f $(bc -l <<< "$photo_width * $ppi"))
photo_height=$(printf %.0f $(bc -l <<< "$photo_height * $ppi"))
canvas_width=$[$print_width * $ppi / $num_photo]
canvas_height=$[$print_height * $ppi] 

# Embed the photo onto a white canvas.
canvas_name="passport_size_photo.$format"
resized_name="${photo_name%.*}_resized.${format}"
convert -size "${canvas_width}x${canvas_height}" canvas:white $canvas_name
convert $photo_name -resize "${photo_width}x${photo_height}" $resized_name
composite -gravity center $resized_name $canvas_name $canvas_name
convert $canvas_name $canvas_name +append $canvas_name

# Remove the resized_photo.
rm -f $resized_name
