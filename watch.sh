 while inotifywait -r -e modify,create,delete src/; do sh build.sh; done;
