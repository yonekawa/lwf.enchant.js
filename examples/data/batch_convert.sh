for f in *.swf; do
    ruby swf2lwf/swf2lwf.rb -p $f
done
