#!/bin/zsh
# Turns a simulator recording of the PreviewTour test into an App Store app preview for the
# 6.9" iPhone: 886x1920, 30 fps, H.264 with a silent stereo AAC track, at most 30 seconds.
#
#   # 1. record while the test runs (stop the recording with Ctrl-C / kill -INT)
#   xcrun simctl io <udid> recordVideo --codec=h264 rec.mov
#   # 2. convert, then pick the segments (seconds) by looking at <out>.cfr.mp4
#   ./make_preview.sh rec.mov preview.mp4
#   # 3. cut them together
#   ./make_preview.sh rec.mov preview.mp4 "34-41.5 49.5-53.8 55-60.2 64.5-76.6"
#
# The simulator records at a variable frame rate, so everything is first converted to a constant
# 30 fps file; segment times refer to that file.
set -e
raw=$1 out=$2 segments=$3
cfr=${out:r}.cfr.mp4
if [[ ! -f $cfr || $raw -nt $cfr ]]; then
  ffmpeg -v error -y -i $raw -vf "fps=30,scale=886:1925:flags=lanczos,crop=886:1920:0:2,format=yuv420p" \
    -c:v libx264 -preset fast -crf 14 $cfr
  echo "wrote $cfr"
fi
[[ -z $segments ]] && exit 0

filter="" labels="" n=0 total=0
for seg in ${(s: :)segments}; do
  a=${seg%-*} b=${seg#*-}
  filter+="[0:v]trim=start=${a}:end=${b},setpts=PTS-STARTPTS[v${n}];"
  labels+="[v${n}]"
  total=$(( total + b - a ))
  n=$(( n + 1 ))
done
(( total <= 30 )) || { echo "segments add up to ${total}s; App Store previews must be 15-30s" >&2; exit 1 }
fade=$(( total - 0.6 ))
filter+="${labels}concat=n=${n}:v=1:a=0,fade=t=out:st=${fade}:d=0.6,format=yuv420p[v]"
ffmpeg -v error -y -i $cfr -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
  -filter_complex $filter -map "[v]" -map 1:a \
  -c:v libx264 -profile:v high -level 4.0 -preset slow -b:v 10M -maxrate 12M -bufsize 20M -r 30 \
  -c:a aac -b:a 256k -shortest -movflags +faststart $out
ffprobe -v error -show_entries format=duration,size -of compact $out
