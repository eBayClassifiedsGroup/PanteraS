echo "Clean up previous example"
fig stop SimpleWebappPython
fig rm --force SimpleWebappPython
echo "Start a new one"
fig up -d SimpleWebappPython
