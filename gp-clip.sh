#!/bin/bash

display_help() {
    printf "usage: $0 [options] filename\n"  >&2
    printf "    options:\n"
    printf "        --latitude\n"
    printf "        --longitude\n"
    printf "        --altitude\n"
    exit
}


if [ -z "$1" ]; then
    display_help
fi

# Regular expression to check for valid numbers
re='^-?[0-9]+([.][0-9]+)?$'

# Reset variables that may have been set
FILE=
LATITUDE=
LONGITUDE=
ALTITUDE=

while :; do
    case $1 in
        -s|--start)
            if [[ $2 =~ ^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$ ]];then
                START="$2"
                shift # past argument
            else
                printf 'ERROR: "--start" is the video time to begin the clip and must be a zero padded string in the format HH:MM:SS where HH is hours, MM is minutes and SS is seconds.\n' >&2
                exit 1
            fi
            ;;
        -t|--time)
            if [[ $2 =~ ^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$ ]];then
                TIME="$2"
                shift # past argument
            else
                printf 'ERROR: "--time" is the length of the video clip to cut and must be a zero padded string in the format HH:MM:SS where HH is hours, MM is minutes and SS is seconds.\n' >&2
                exit 1
            fi
            ;;
        --latitude)
            if ! [[ $2 =~ $re ]] ; then
                printf 'ERROR: "--latitude" must be a number.\n' >&2
                exit 1
            else
                LATITUDE="$2"
                shift # past argument
            fi
            ;;
        --longitude)
            if ! [[ $2 =~ $re ]] ; then
                printf 'ERROR: "--longitude" must be a number.\n' >&2
                exit 1
            else
                LONGITUDE="$2"
                shift # past argument
            fi
            ;;
        --altitude)
            if ! [[ $2 =~ $re ]] ; then
                printf 'ERROR: "--altitude" must be a number.\n' >&2
                exit 1
            else
                ALTITUDE="$2"
                shift # past argument
            fi
            ;;
        *)  # Default case: If no more options then break out of the loop.
            if [ -n "$1" ]; then
                FILE="$1"
            else
                printf 'ERROR: filename requires a non-empty argument.\n' >&2
                display_help
                exit 1
            fi
            break
    esac
    shift # past argument or value
done

echo FILE    = "${FILE}"
echo LATITUDE  = "${LATITUDE}"
echo LONGITUDE     = "${LONGITUDE}"
echo ALTITUDE    = "${ALTITUDE}"


echo "\nTrying to Process:" $FILE

# Get filename without path and split into name and extension
filename=$(basename "$FILE")
extension="${filename##*.}"
filename="${filename%.*}"
echo "Filename:" $filename
echo "Extension:" $extension

# Get encoded date of GoPro file
ENCODED_DATE="$(mediainfo --Inform="General;%Encoded_Date%" "$FILE")"
echo "${ENCODED_DATE}"

# Save metadata of GoPro file for re-mapping
avconv -y -i "$FILE" -f ffmetadata metadata.txt 

# Add recorded date to metadata
avconv -y -i "$FILE" -i metadata.txt -map_metadata 1 -codec copy -map 0 -metadata date="${ENCODED_DATE}" intermediate.mov

# Cut video file at start and end points
if ! [ -z ${START+x} ] && ! [ -z ${TIME+x} ]; then
    avconv -y -i intermediate.mov -ss "${START}" -c copy -t "${TIME}" cut.mov;
    FILE_FOR_GPS="cut.mov"
    FILEOUT="${filename}-S${START}-D${TIME}-WITH_METADATA.MOV"
else
    echo "START and/or TIME not set";
    FILE_FOR_GPS="intermediate.mov"
    FILEOUT="${filename}_WITH_METADATA.MOV"
fi

# get GPS coordinates from track file for this track file
GEOPT="+40.57908612-111.62354711+2644\/"
echo "Geo point is: " $GEOPT

# Correctly write gps.info plist file to use as input
sed -e "s/\${geopt}/$GEOPT/" template.plist > metadata.plist

# avmetareadwrite can't overwrite so we delete first if file exists
if [ -f "$FILEOUT" ]; then
    rm "$FILEOUT" 
fi

# Add GPS Info to file
echo "Writing file: ${FILEOUT}"
avmetareadwrite --append-metadata=metadata.plist "$FILE_FOR_GPS" "$FILEOUT"

# Cleanup working files
rm intermediate.mov
rm metadata.txt
rm metadata.plist
if [ -f "cut.mov" ]; then
    rm "cut.mov"
fi
 
